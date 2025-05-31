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

  // Enhanced sendNotifications method
  Future<void> sendNotifications(int predictedValue) async {
    // Get the target donors based on prediction
    final targets = donorList.where((d) => d.predictionValue == predictedValue).toList();
    
    if (targets.isEmpty) {
      _showNotification(
        predictedValue == 1 
          ? "No donors predicted to donate found." 
          : "No donors predicted not to donate found.", 
        false
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(
      'Send Notifications',
      'Send notifications to ${targets.length} donors?',
    );
    
    if (!confirmed) return;

    setState(() {
      isSending = true;
    });

    try {
      print('🚀 Starting notification process for ${targets.length} donors...');
      
      // Call the improved API method that returns detailed results
      final result = await ApiService.sendNotifications(targets);
      
      // Parse results
      final successful = result['successful'] as int;
      final failed = result['failed'] as int;
      final invalid = result['invalid'] as int;
      final total = result['total'] as int;

      // Show appropriate success/error message based on results
      if (successful == total) {
        // All notifications sent successfully
        _showNotification(
          "🎉 All $successful notifications sent successfully!", 
          true
        );
      } else if (successful > 0) {
        // Partial success
        String message = "📊 Mixed results:\n";
        message += "✅ Successful: $successful\n";
        if (failed > 0) message += "❌ Failed: $failed\n";
        if (invalid > 0) message += "⚠️ Invalid emails: $invalid\n";
        message += "\nCheck console for details.";
        
        _showNotification(message, successful > failed);
      } else {
        // All failed
        _showNotification(
          "❌ All notifications failed to send.\nPlease check your internet connection and try again.", 
          false
        );
      }

      // Log detailed results for debugging
      if (result['failedEmails'] != null && (result['failedEmails'] as List).isNotEmpty) {
        print('❌ Failed notifications details:');
        for (String failure in result['failedEmails'] as List<String>) {
          print('  - $failure');
        }
      }

      if (result['invalidEmails'] != null && (result['invalidEmails'] as List).isNotEmpty) {
        print('⚠️ Invalid emails details:');
        for (String invalid in result['invalidEmails'] as List<String>) {
          print('  - $invalid');
        }
      }

    } catch (error) {
      print('💥 Notification error: $error');
      
      String errorMessage = "Failed to send notifications.";
      
      // Parse different types of errors for better user feedback
      String errorStr = error.toString().toLowerCase();
      if (errorStr.contains('network') || errorStr.contains('connection')) {
        errorMessage = "Network error. Please check your internet connection and try again.";
      } else if (errorStr.contains('timeout')) {
        errorMessage = "Request timeout. The server is taking too long to respond.";
      } else if (errorStr.contains('server') || errorStr.contains('500')) {
        errorMessage = "Server error. Please try again later.";
      } else if (errorStr.contains('all notifications failed')) {
        errorMessage = "All notifications failed to send. Please check your email configuration.";
      }
      
      _showNotification(errorMessage, false);

    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  // Enhanced confirmation dialog
  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.email, color: Color(0xFFDC2626), size: 24),
              const SizedBox(width: 8),
              Flexible(child: Text(title)),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Enhanced notification display with better styling
  void _showNotification(String message, bool success) {
    setState(() {
      notificationMessage = message;
      isSuccess = success;
    });

    // Auto-dismiss after appropriate time
    final duration = success ? 4 : 8; // Success messages shorter, error messages longer
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
        overflow: TextOverflow.ellipsis, // Added overflow handling
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
              SafeArea( // Added SafeArea to prevent overflow into status bar
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 60, right: 16, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Flexible( // Added Flexible to prevent text overflow
                            child: Text(
                              "Donation Prediction",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          isDense: true,
        ),
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final filteredCount = _getFilteredDonors().length;
    return SingleChildScrollView( // Added to handle horizontal overflow
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryChip('Total: ${donorList.length}'),
          const SizedBox(width: 8),
          _buildSummaryChip('Filtered: $filteredCount'),
          const SizedBox(width: 8),
          _buildSummaryChip('Showing: ${displayedDonors.length}'),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white, 
          fontSize: 12, 
          fontWeight: FontWeight.w500
        ),
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
                Flexible( // Added Flexible to prevent text overflow
                  child: Text(
                    'Donor Predictions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    overflow: TextOverflow.ellipsis,
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

  // Updated action buttons with better responsive handling
  Widget _buildActionButtons() {
    final willDonateCount = donorList.where((d) => d.predictionValue == 1).length;
    final wontDonateCount = donorList.where((d) => d.predictionValue == 0).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use column layout on smaller screens to prevent overflow
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildActionButton(
                onPressed: (isLoading || isSending) ? null : handlePredict,
                icon: isLoading ? Icons.hourglass_empty : Icons.psychology,
                label: isLoading ? 'Predicting...' : 'Predict Donations',
                color: Colors.blue,
                isFullWidth: true,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                onPressed: (isSending || willDonateCount == 0) ? null : () => sendNotifications(1),
                icon: isSending ? Icons.hourglass_empty : Icons.notifications,
                label: isSending ? 'Sending...' : 'Notify Will Donate ($willDonateCount)',
                color: willDonateCount > 0 ? Colors.green : Colors.grey,
                isFullWidth: true,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                onPressed: (isSending || wontDonateCount == 0) ? null : () => sendNotifications(0),
                icon: isSending ? Icons.hourglass_empty : Icons.notifications_off,
                label: isSending ? 'Sending...' : 'Notify Won\'t Donate ($wontDonateCount)',
                color: wontDonateCount > 0 ? Colors.orange : Colors.grey,
                isFullWidth: true,
              ),
            ],
          );
        } else {
          // Use wrap layout on larger screens
          return Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildActionButton(
                onPressed: (isLoading || isSending) ? null : handlePredict,
                icon: isLoading ? Icons.hourglass_empty : Icons.psychology,
                label: isLoading ? 'Predicting...' : 'Predict Donations',
                color: Colors.blue,
              ),
              _buildActionButton(
                onPressed: (isSending || willDonateCount == 0) ? null : () => sendNotifications(1),
                icon: isSending ? Icons.hourglass_empty : Icons.notifications,
                label: isSending ? 'Sending...' : 'Notify Will Donate ($willDonateCount)',
                color: willDonateCount > 0 ? Colors.green : Colors.grey,
              ),
              _buildActionButton(
                onPressed: (isSending || wontDonateCount == 0) ? null : () => sendNotifications(0),
                icon: isSending ? Icons.hourglass_empty : Icons.notifications_off,
                label: isSending ? 'Sending...' : 'Notify Won\'t Donate ($wontDonateCount)',
                color: wontDonateCount > 0 ? Colors.orange : Colors.grey,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isFullWidth = false,
  }) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Flexible( // Added Flexible to prevent text overflow
        child: Text(
          label, 
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        visualDensity: VisualDensity.compact,
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
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