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
  List<Donor> displayedDonors = [];
  bool isLoading = false;
  bool isSending = false;
  bool isLoadingMore = false;
  String searchQuery = '';
  String selectedFilter = 'all'; // all, predicted, not_predicted, will_donate, wont_donate
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

  @override
  void initState() {
    super.initState();
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

      donorList = _convertDonationToDonorList(filteredDonations);
      _applyFiltersAndPagination();
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

  void _applyFiltersAndPagination() {
    List<Donor> filtered = _getFilteredDonors();
    
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
      // Add more items to existing list
      displayedDonors.addAll(filtered.sublist(currentPage * itemsPerPage, endIndex));
    }

    setState(() {});
  }

  List<Donor> _getFilteredDonors() {
    List<Donor> filtered = donorList;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((donor) =>
          donor.cin.isNotEmpty &&
          donor.cin.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    // Apply prediction filter
    switch (selectedFilter) {
      case 'predicted':
        filtered = filtered.where((donor) => 
            donor.prediction != "Not defined").toList();
        break;
      case 'not_predicted':
        filtered = filtered.where((donor) => 
            donor.prediction == "Not defined").toList();
        break;
      case 'will_donate':
        filtered = filtered.where((donor) => 
            donor.predictionValue == 1).toList();
        break;
      case 'wont_donate':
        filtered = filtered.where((donor) => 
            donor.predictionValue == 0).toList();
        break;
      case 'all':
      default:
        // No additional filtering
        break;
    }

    return filtered;
  }

  void _loadMoreDonors() {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    // Simulate network delay for better UX
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
    updateBloodStats();
  }

  void _onFilterChanged(String? value) {
    if (value == null) return;
    setState(() {
      selectedFilter = value;
      currentPage = 0;
      displayedDonors.clear();
    });
    _applyFiltersAndPagination();
    updateBloodStats();
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

    final donorsToCount = _getFilteredDonors();

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
    final firstDonationDate = donor.firstDonationDate.isNotEmpty
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
        currentPage = 0;
        displayedDonors.clear();
      });

      _applyFiltersAndPagination();
      updateBloodStats();
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

    final targets = donorList.where((d) => d.predictionValue == predictedValue).toList();

    try {
      await ApiService.sendNotifications(targets);
      _showNotification("Notifications sent successfully.", true);
    } catch (error) {
      _showNotification("Failed to send notifications.", false);
    } finally {
      setState(() {
        isSending = false;
      });
    }
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: isLoading && donorList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFDC2626)),
            )
          : SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildSliverAppBar(),
                  _buildStatsSection(),
                  _buildFiltersSection(),
                  _buildDonorsList(),
                  if (isLoadingMore) _buildLoadingMoreIndicator(),
                ],
              ),
            ),
      floatingActionButton: notificationMessage != null ? _buildNotificationToast() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
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
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'logout') {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
                padding: const EdgeInsets.only(left: 16, top: 80, right: 16, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Donation Prediction",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildSummaryRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 40,
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by CIN...',
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          isDense: true,
        ),
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final filteredCount = _getFilteredDonors().length;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Total: ${donorList.length}',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Filtered: $filteredCount',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Showing: ${displayedDonors.length}',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
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
                Text(
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
            _buildFilterDropdown(),
            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: selectedFilter,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        hint: const Text('Filter donors'),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('All Donors')),
          DropdownMenuItem(value: 'predicted', child: Text('Predicted Donors')),
          DropdownMenuItem(value: 'not_predicted', child: Text('Not Predicted')),
          DropdownMenuItem(value: 'will_donate', child: Text('Will Donate')),
          DropdownMenuItem(value: 'wont_donate', child: Text('Won\'t Donate')),
        ],
        onChanged: _onFilterChanged,
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

  Widget _buildDonorsList() {
    if (displayedDonors.isEmpty && !isLoading) {
      return SliverToBoxAdapter(child: _buildEmptyState());
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
          child: CircularProgressIndicator(color: Color(0xFFDC2626)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
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
              'No donors found.',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try adjusting your filters or search criteria.',
              style: TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 12,
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  notificationMessage!,
                  style: TextStyle(
                    color: isSuccess ? const Color(0xFF065F46) : const Color(0xFFB91C1C),
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