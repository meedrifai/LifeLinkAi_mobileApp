import 'package:flutter/material.dart';
import 'package:lifelinkai/models/donor.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/widgets/blood_stats_dashboard.dart';
import 'package:lifelinkai/widgets/donor_card.dart';

class WhoWillDonatePage extends StatefulWidget {
  final List<Donor> donors;

  const WhoWillDonatePage({Key? key, required this.donors, required User user}) : super(key: key);

  @override
  _WhoWillDonatePageState createState() => _WhoWillDonatePageState();
}

class _WhoWillDonatePageState extends State<WhoWillDonatePage> {
  late List<Donor> donorList;
  bool isLoading = false;
  bool isSending = false;
  String searchQuery = '';
  Map<String, dynamic> bloodStats = {
    'total': 0,
    'byType': {},
    'potentialDonors': 0
  };

  String? notificationMessage;
  bool isSuccess = true;

  @override
  void initState() {
    super.initState();
    donorList = widget.donors.map((donor) {
      return donor.copyWith(
        prediction: "Not defined",
        predictionColor: null,
      );
    }).toList();
    updateBloodStats();
  }

  void updateBloodStats() {
    const int bloodPerDonor = 250; // ml per donor
    final Map<String, dynamic> stats = {
      'total': 0,
      'byType': {},
      'potentialDonors': 0
    };

    // Use the filtered list instead of the complete list
    final donorsToCount = searchQuery.isNotEmpty
        ? donorList.where((donor) =>
            donor.cin != null &&
            donor.cin!.toLowerCase().contains(searchQuery.toLowerCase()))
        : donorList;

    for (final donor in donorsToCount) {
      final willDonate = donor.predictionValue == 1;

      if (willDonate) {
        stats['potentialDonors'] = (stats['potentialDonors'] as int) + 1;
        stats['total'] = (stats['total'] as int) + bloodPerDonor;

        if (!(stats['byType'] as Map).containsKey(donor.bloodType)) {
          (stats['byType'] as Map)[donor.bloodType] = {
            'count': 0,
            'volume': 0
          };
        }

        (stats['byType'] as Map)[donor.bloodType]['count'] += 1;
        (stats['byType'] as Map)[donor.bloodType]['volume'] += bloodPerDonor;
      }
    }

    setState(() {
      bloodStats = stats;
    });
  }

  Map<String, dynamic> computeFeatures(Donor donor) {
    final now = DateTime.now();
    final lastDonationDate = DateTime.parse(donor.lastDonationDate);
    final firstDonationDate = DateTime.parse(donor.firstDonationDate ?? now.toString());
    
    final recency = ((now.difference(lastDonationDate).inDays) / 30.44).floor();
    final time = ((now.difference(firstDonationDate).inDays) / 30.44).floor();
    
    return {
      'recency': recency,
      'frequency': donor.frequency ?? 0,
      'time': time
    };
  }

  Future<void> handlePredict() async {
    setState(() {
      isLoading = true;
    });

    final samples = donorList.map(computeFeatures).toList();

    try {
      final predictions = await ApiService.predictDonors(samples);
      
      final updated = List<Donor>.from(donorList);
      for (int i = 0; i < updated.length; i++) {
        updated[i] = updated[i].copyWith(
          prediction: predictions[i] == 1 ? "Will Donate" : "Will Not Donate",
          predictionValue: predictions[i],
          predictionColor: predictions[i] == 1 ? "green" : "red",
        );
      }

      setState(() {
        donorList = updated;
        isLoading = false;
      });
      
      updateBloodStats();
    } catch (error) {
      setState(() {
        isLoading = false;
        notificationMessage = "Prediction failed";
        isSuccess = false;
      });
    }
  }

  Future<void> sendNotifications(int predictedValue) async {
    setState(() {
      isSending = true;
    });

    final targets = donorList.where((d) => d.predictionValue == predictedValue).toList();

    try {
      await ApiService.sendNotifications(targets);
      
      setState(() {
        isSending = false;
        notificationMessage = "Notifications sent successfully.";
        isSuccess = true;
      });
      
      // Hide notification after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            notificationMessage = null;
          });
        }
      });
    } catch (error) {
      setState(() {
        isSending = false;
        notificationMessage = "Failed to send notifications.";
        isSuccess = false;
      });
      
      // Hide notification after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            notificationMessage = null;
          });
        }
      });
    }
  }

  List<Donor> get filteredDonors {
    if (searchQuery.isEmpty) {
      return donorList;
    }
    return donorList.where((donor) =>
      donor.cin != null &&
      donor.cin!.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              pinned: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.white, size: 28),
                            const SizedBox(width: 8),
                            const Text(
                              'CHU Ibn Rochd Blood Donations',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Smart donor management and prediction system',
                          style: TextStyle(
                            color: Color(0xFFFECACA),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                            updateBloodStats();
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by CIN...',
                            hintStyle: const TextStyle(color: Color(0xFFFECACA)),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFFFECACA)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Blood Stats Dashboard
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BloodStatsDashboard(bloodStats: bloodStats),
              ),
            ),

            // Action Buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: Colors.blue, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Donor Predictions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: isLoading ? null : handlePredict,
                            icon: const Icon(Icons.psychology),
                            label: Text(isLoading ? 'Predicting...' : 'Predict'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: isSending ? null : () => sendNotifications(1),
                            icon: const Icon(Icons.notifications),
                            label: const Text('Notify Who Will Donate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: isSending ? null : () => sendNotifications(0),
                            icon: const Icon(Icons.notifications_off),
                            label: const Text('Notify Who Will Not Donate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Donor List
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: filteredDonors.isNotEmpty
                  ? SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 16.0,
                        childAspectRatio: 1.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final donor = filteredDonors[index];
                          return DonorCard(donor: donor);
                        },
                        childCount: filteredDonors.length,
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFEE2E2),
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.water_drop, size: 40, color: Color(0xFFFCA5A5)),
                              SizedBox(height: 8),
                              Text(
                                'No results found.',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      // Notification Toast
      floatingActionButton: notificationMessage != null
          ? Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                color: isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSuccess ? Icons.check_circle : Icons.error,
                        color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        notificationMessage!,
                        style: TextStyle(
                          color: isSuccess ? const Color(0xFF065F46) : const Color(0xFFB91C1C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        color: Colors.grey,
                        onPressed: () {
                          setState(() {
                            notificationMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}