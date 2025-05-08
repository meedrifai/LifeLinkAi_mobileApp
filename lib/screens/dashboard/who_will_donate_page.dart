import 'package:flutter/material.dart';
import 'package:lifelinkai/models/donor.dart';
import 'package:lifelinkai/providers/donor_provider.dart';
import 'package:lifelinkai/widgets/blood_stats_dashboard.dart';
import 'package:lifelinkai/widgets/donor_card.dart';
import 'package:lifelinkai/widgets/notification_popup.dart';
import 'package:provider/provider.dart';

class WhoWillDonatePage extends StatefulWidget {
  const WhoWillDonatePage({Key? key}) : super(key: key);

  @override
  State<WhoWillDonatePage> createState() => _WhoWillDonatePageState();
}

class _WhoWillDonatePageState extends State<WhoWillDonatePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSending = false;
  NotificationInfo? _notification;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handlePredict() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<DonorProvider>(context, listen: false).predictDonors();
      _showNotification('Prediction completed successfully', NotificationType.success);
    } catch (error) {
      _showNotification('Prediction failed', NotificationType.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendNotifications(int predictionValue) async {
    setState(() {
      _isSending = true;
    });

    try {
      await Provider.of<DonorProvider>(context, listen: false)
          .sendNotifications(predictionValue);
      _showNotification('Notifications sent successfully', NotificationType.success);
    } catch (error) {
      _showNotification('Failed to send notifications', NotificationType.error);
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showNotification(String message, NotificationType type) {
    setState(() {
      _notification = NotificationInfo(
        message: message,
        type: type,
      );
    });

    // Hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _notification = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final donorProvider = Provider.of<DonorProvider>(context);
    final filteredDonors = donorProvider.getFilteredDonors(_searchController.text);
    final bloodStats = donorProvider.bloodStats;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar - Fixed height and vertical constraints
            SliverAppBar(
              expandedHeight: 90, // Reduced height to prevent overflow
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0), // Reduced padding
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Important to prevent vertical overflow
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.white, size: 20), // Smaller icon
                            const SizedBox(width: 8),
                            // Use Flexible to prevent overflow
                            Flexible(
                              child: Text(
                                'CHU Ibn Rochd Blood Donations',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15, // Even smaller font
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2), // Reduced spacing
                        const Text(
                          'Smart donor management and prediction system',
                          style: TextStyle(
                            color: Color(0xFFFECACA),
                            fontSize: 11, // Smaller subtitle
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40), // Reduced height
                child: Container(
                  height: 40, // Fixed height for search field
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4), // Tighter padding
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {}); // Trigger rebuild to update filtered list
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by CIN...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 18),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Smaller radius
                        borderSide: BorderSide.none,
                      ),
                      isDense: true, // Important for minimizing height
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.blue[700], size: 22),
                        const SizedBox(width: 8),
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
                    // Fixed-height container with horizontally scrollable buttons
                    SizedBox(
                      height: 40, // Reduced height
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handlePredict,
                            icon: const Icon(Icons.psychology, size: 16),
                            label: Text(
                              _isLoading ? 'Wait...' : 'Predict',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(0, 36), // Smaller height
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _isSending ? null : () => _sendNotifications(1),
                            icon: const Icon(Icons.notifications_active, size: 16),
                            label: const Text(
                              'Notify Will Donate',
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(0, 36), // Smaller height
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _isSending ? null : () => _sendNotifications(0),
                            icon: const Icon(Icons.notifications_active, size: 16),
                            label: const Text(
                              'Notify Won\'t Donate',
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(0, 36), // Smaller height
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Donor List - Changed from SliverGrid to SliverList to prevent fixed height constraints
            filteredDonors.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.water_drop, size: 40, color: Colors.red[300]),
                            const SizedBox(height: 8),
                            Text(
                              'No results found.',
                              style: TextStyle(
                                color: Colors.red[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final donor = filteredDonors[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: DonorCard(donor: donor),
                          );
                        },
                        childCount: filteredDonors.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      // Show notification if needed
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _notification != null
          ? NotificationPopup(
              notification: _notification!,
              onDismiss: () {
                setState(() {
                  _notification = null;
                });
              },
            )
          : null,
    );
  }
}