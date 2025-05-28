import 'package:flutter/material.dart';
import 'package:lifelinkai/models/donation.dart';
import 'package:lifelinkai/models/donor.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/widgets/blood_stats_dashboard.dart';
import 'package:lifelinkai/widgets/bottom_nav_bar.dart';
import 'package:lifelinkai/widgets/donor_card.dart';

class WhoWillDonatePage extends StatefulWidget {
  final User user;

  const WhoWillDonatePage({super.key, required this.user});

  @override
  _WhoWillDonatePageState createState() => _WhoWillDonatePageState();
}

class _WhoWillDonatePageState extends State<WhoWillDonatePage> {
  List<Donor> donorList = [];
  bool isLoading = false;
  bool isSending = false;
  String searchQuery = '';
  Map<String, dynamic> bloodStats = {
    'total': 0,
    'byType': {},
    'potentialDonors': 0,
  };
  int _currentNavIndex = 0; // For bottom nav bar
  String? notificationMessage;
  bool isSuccess = true;

  @override
  void initState() {
    super.initState();
    _fetchDonationsAndConvert();
  }

  Future<void> _fetchDonationsAndConvert() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiService.fetchDonationsByHospital(
        widget.user.nomHospital,
      );
      final filteredDonations =
          data.where((donation) {
            final lastDonationDate = DateTime.parse(donation.lastDonationDate);
            final now = DateTime.now();
            final diffMonths =
                (now.year - lastDonationDate.year) * 12 +
                now.month -
                lastDonationDate.month;
            return diffMonths > 3;
          }).toList();

      donorList = _convertDonationToDonorList(filteredDonations);
      updateBloodStats();
    } catch (e) {
      print('Error fetching donations: $e');
      _showErrorSnackBar('Failed to load donations. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Donor> _convertDonationToDonorList(List<Donation> donations) {
    return donations.map((donation) {
      return Donor(
        id: donation.id,
        fullname: donation.fullname,
        cin: donation.cin,
        bloodType: donation.bloodType,
        email: donation.email,
        lastDonationDate: donation.lastDonationDate,
        firstDonationDate: donation.firstDonationDate,
        frequency: donation.frequence,
        prediction: "Not defined",
        predictionColor: null,
      );
    }).toList();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void updateBloodStats() {
    const int bloodPerDonor = 250;
    final Map<String, dynamic> stats = {
      'total': 0,
      'byType': {},
      'potentialDonors': 0,
    };

    final donorsToCount =
        searchQuery.isNotEmpty
            ? donorList.where(
              (donor) =>
                  donor.cin.isNotEmpty &&
                  donor.cin.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            : donorList;

    for (final donor in donorsToCount) {
      final willDonate = donor.predictionValue == 1;

      if (willDonate) {
        stats['potentialDonors'] = (stats['potentialDonors'] as int) + 1;
        stats['total'] = (stats['total'] as int) + bloodPerDonor;

        if (!(stats['byType'] as Map).containsKey(donor.bloodType)) {
          (stats['byType'] as Map)[donor.bloodType] = {'count': 0, 'volume': 0};
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
    final firstDonationDate =
        donor.firstDonationDate.isNotEmpty
            ? DateTime.parse(donor.firstDonationDate)
            : now;

    final recency = ((now.difference(lastDonationDate).inDays) / 30.44).floor();
    final time = ((now.difference(firstDonationDate).inDays) / 30.44).floor();

    return {'recency': recency, 'frequency': donor.frequency, 'time': time};
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

      _showSuccessSnackBar("Prediction completed successfully");
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      _showNotification("Prediction failed", false);
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotification(String message, bool success) {
    setState(() {
      notificationMessage = message;
      isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          notificationMessage = null;
        });
      }
    });
  }

  Future<void> sendNotifications(int predictedValue) async {
    setState(() {
      isSending = true;
    });

    final targets =
        donorList.where((d) => d.predictionValue == predictedValue).toList();

    try {
      await ApiService.sendNotifications(targets);

      setState(() {
        isSending = false;
      });

      _showNotification("Notifications sent successfully.", true);
    } catch (error) {
      setState(() {
        isSending = false;
      });

      _showNotification("Failed to send notifications.", false);
    }
  }

  List<Donor> get filteredDonors {
    if (searchQuery.isEmpty) {
      return donorList;
    }
    return donorList
        .where(
          (donor) =>
              donor.cin.isNotEmpty &&
              donor.cin.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  // Handle navigation between pages
  void _handleNavigation(int index) {
    // Update index after navigation to avoid sync issues
    switch (index) {
      case 0:
        // Navigate to Donors page (main page)
        Navigator.pushNamed(
          context,
          '/donationsPage',
          arguments: widget.user,
        );
        break;
      case 1:
        // Navigate to Add Donation page
        Navigator.pushNamed(
          context,
          '/addDonorPage',
          arguments: widget.user,
        );
        break;
      case 2:
        // Already on Who Will Donate page
        setState(() {
          _currentNavIndex = index;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading && donorList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFDC2626)),
            )
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 160,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    pinned: true,
                    centerTitle: true,
                    title: Text(
                      widget.user.nomHospital,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    actions: [
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'logout') {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/',
                              (route) => false,
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -50,
                              bottom: -20,
                              child: Icon(
                                Icons.water_drop,
                                size: 200,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 60, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.psychology,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Donation Prediction",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 40,
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          searchQuery = value;
                                        });
                                        updateBloodStats();
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search by CIN...',
                                        hintStyle: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white24,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 0,
                                        ),
                                        isDense: true,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
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
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: BloodStatsDashboard(bloodStats: bloodStats),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.psychology,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Donor Predictions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver:
                        filteredDonors.isNotEmpty
                            ? SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final donor = filteredDonors[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: DonorCard(donor: donor),
                                  );
                                }, childCount: filteredDonors.length),
                              )
                            : SliverToBoxAdapter(child: _buildEmptyState()),
                  ),
                ],
              ),
            ),
      floatingActionButton:
          notificationMessage != null ? _buildNotificationToast() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _buildActionButton(
          onPressed: isLoading ? null : handlePredict,
          icon: Icons.psychology,
          label: isLoading ? 'Predicting...' : 'Predict',
          color: Colors.blue,
        ),
        _buildActionButton(
          onPressed: isSending ? null : () => sendNotifications(1),
          icon: Icons.notifications,
          label: 'Notify Donors',
          color: Colors.green,
        ),
        _buildActionButton(
          onPressed: isSending ? null : () => sendNotifications(0),
          icon: Icons.notifications_off,
          label: 'Notify Non-Donors',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
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
    );
  }

  Widget _buildNotificationToast() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        color: isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color:
                    isSuccess
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  notificationMessage!,
                  style: TextStyle(
                    color:
                        isSuccess
                            ? const Color(0xFF065F46)
                            : const Color(0xFFB91C1C),
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    notificationMessage = null;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                customBorder: const CircleBorder(),
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
