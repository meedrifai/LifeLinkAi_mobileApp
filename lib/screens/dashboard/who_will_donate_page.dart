import 'package:flutter/material.dart';
import 'package:lifelinkai/models/donor.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/services/donor_prediction_service.dart';
import 'package:lifelinkai/services/notification_service.dart';
import 'package:lifelinkai/widgets/DonorActionButtons.dart';
import 'package:lifelinkai/widgets/DonorFiltersSection.dart';
import 'package:lifelinkai/widgets/EmptyStateWidget.dart';
import 'package:lifelinkai/widgets/blood_stats_dashboard.dart';
import 'package:lifelinkai/widgets/bottom_nav_bar.dart';
import 'package:lifelinkai/widgets/donor_card.dart';
import 'package:lifelinkai/widgets/notification_toast.dart';
import 'package:lifelinkai/widgets/custom_app_bar.dart';
import 'package:lifelinkai/utils/constants.dart';
import 'package:lifelinkai/utils/donor_utils.dart';

class WhoWillDonatePage extends StatefulWidget {
  final User user;

  const WhoWillDonatePage({super.key, required this.user});

  @override
  _WhoWillDonatePageState createState() => _WhoWillDonatePageState();
}

class _WhoWillDonatePageState extends State<WhoWillDonatePage> {
  List<Donor> donorList = [];
  List<Donor> displayedDonors = [];
  bool isLoading = false;
  bool isSending = false;
  bool isLoadingMore = false;
  String searchQuery = '';
  String selectedFilter = 'all';
  Map<String, dynamic> bloodStats = {
    'total': 0,
    'byType': {},
    'potentialDonors': 0,
  };
  int _currentNavIndex = 0;
  String? notificationMessage;
  bool isSuccess = true;
  
  // Pagination variables
  static const int itemsPerPage = 20;
  int currentPage = 0;
  bool hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  late final DonorPredictionService _predictionService;
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _predictionService = DonorPredictionService();
    _notificationService = NotificationService();
    _fetchDonationsAndConvert();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200 && 
        !isLoadingMore && hasMoreData) {
      _loadMoreDonors();
    }
  }

  Future<void> _fetchDonationsAndConvert() async {
    setState(() {
      isLoading = true;
      currentPage = 0;
      hasMoreData = true;
    });

    try {
      final data = await ApiService.fetchDonationsByHospital(
        widget.user.nomHospital,
      );
      final filteredDonations = data.where((donation) {
        final lastDonationDate = DateTime.parse(donation.lastDonationDate);
        final now = DateTime.now();
        final diffMonths = (now.year - lastDonationDate.year) * 12 +
            now.month - lastDonationDate.month;
        return diffMonths > 3;
      }).toList();

      donorList = DonorUtils.convertDonationToDonorList(filteredDonations);
      _applyFiltersAndPagination();
      _updateBloodStats();
    } catch (e) {
      print('Error fetching donations: $e');
      _showErrorSnackBar('Failed to load donations. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFiltersAndPagination() {
    List<Donor> filtered = DonorUtils.getFilteredDonors(
      donorList, 
      searchQuery, 
      selectedFilter
    );
    
    int startIndex = 0;
    int endIndex = (currentPage + 1) * itemsPerPage;
    
    if (endIndex >= filtered.length) {
      endIndex = filtered.length;
      hasMoreData = false;
    } else {
      hasMoreData = true;
    }

    if (currentPage == 0) {
      displayedDonors = filtered.sublist(startIndex, endIndex);
    } else {
      displayedDonors.addAll(filtered.sublist(currentPage * itemsPerPage, endIndex));
    }

    setState(() {});
  }

  void _loadMoreDonors() {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _applyFiltersAndPagination();
      setState(() {
        isLoadingMore = false;
      });
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      currentPage = 0;
      displayedDonors.clear();
    });
    _applyFiltersAndPagination();
    _updateBloodStats();
  }

  void _onFilterChanged(String? value) {
    if (value == null) return;
    setState(() {
      selectedFilter = value;
      currentPage = 0;
      displayedDonors.clear();
    });
    _applyFiltersAndPagination();
    _updateBloodStats();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateBloodStats() {
    final stats = DonorUtils.calculateBloodStats(
      DonorUtils.getFilteredDonors(donorList, searchQuery, selectedFilter)
    );
    setState(() {
      bloodStats = stats;
    });
  }

  Future<void> _handlePredict() async {
    setState(() {
      isLoading = true;
    });

    try {
      final updatedDonors = await _predictionService.predictDonors(donorList);
      
      setState(() {
        donorList = updatedDonors;
        currentPage = 0;
        displayedDonors.clear();
      });

      _applyFiltersAndPagination();
      _updateBloodStats();
      _showSuccessSnackBar("Prediction completed successfully");
    } catch (error) {
      _showNotification("Prediction failed", false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sendNotifications(int predictedValue) async {
    final result = await _notificationService.sendNotifications(
      context,
      donorList,
      predictedValue,
      onLoadingChanged: (loading) => setState(() => isSending = loading),
      onNotification: _showNotification,
    );
  }

  void _showNotification(String message, bool success) {
    setState(() {
      notificationMessage = message;
      isSuccess = success;
    });

    final duration = success ? 4 : 8;
    Future.delayed(Duration(seconds: duration), () {
      if (mounted) {
        setState(() {
          notificationMessage = null;
        });
      }
    });
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/donationsPage', arguments: widget.user);
        break;
      case 1:
        Navigator.pushNamed(context, '/addDonorPage', arguments: widget.user);
        break;
      case 2:
        setState(() {
          _currentNavIndex = index;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: isLoading && donorList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  CustomAppBar(
                    hospitalName: widget.user.nomHospital,
                    title: "Donation Prediction",
                    icon: Icons.psychology,
                  ),
                  _buildStatsSection(),
                  _buildFiltersSection(),
                  _buildDonorsList(),
                  if (isLoadingMore) _buildLoadingMoreIndicator(),
                ],
              ),
            ),
      floatingActionButton: notificationMessage != null 
          ? NotificationToast(
              message: notificationMessage!,
              isSuccess: isSuccess,
            ) 
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: BloodStatsDashboard(bloodStats: bloodStats),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue, size: 20),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Donor Predictions',
                    style: AppTextStyles.heading3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DonorFiltersSection(
              selectedFilter: selectedFilter,
              onFilterChanged: _onFilterChanged,
              onSearchChanged: _onSearchChanged,
            ),

            const SizedBox(height: 12),
            DonorActionButtons(
              donorList: donorList,
              isLoading: isLoading,
              isSending: isSending,
              onPredict: _handlePredict,
              onSendNotifications: _sendNotifications,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorsList() {
    if (displayedDonors.isEmpty && !isLoading) {
      return const SliverToBoxAdapter(child: EmptyStateWidget());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final donor = displayedDonors[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: DonorCard(donor: donor),
            );
          },
          childCount: displayedDonors.length,
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}