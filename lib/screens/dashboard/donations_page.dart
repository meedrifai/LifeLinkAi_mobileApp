import 'package:flutter/material.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/models/donation.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/widgets/bottom_nav_bar.dart';

class DonationsPage extends StatefulWidget {
  final User user;

  const DonationsPage({super.key, required this.user});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Donation> _donations = [];
  List<Donation> _filteredDonations = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  final int _itemsPerPage = 9;
  int _currentNavIndex = 0; // For bottom nav bar

  @override
  void initState() {
    super.initState();
    _fetchDonations();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreDonations();
    }
  }

  Future<void> _fetchDonations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Replace with your actual API call
      final data = await ApiService.fetchDonationsByHospital(widget.user.nomHospital);
      
      setState(() {
        _donations = data;
        _applySearch();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching donations: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load donations. Please try again.');
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      if (query.isEmpty) {
        _filteredDonations = _donations;
      } else {
        _filteredDonations = _donations
            .where((donor) => donor.cin.toLowerCase().contains(query))
            .toList();
      }
      _page = 1;
      _hasMore = true;
    });
  }

  void _loadMoreDonations() {
    final endIndex = _page * _itemsPerPage;
    setState(() {
      _page++;
      _hasMore = endIndex < _filteredDonations.length;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Get color for blood type badge
  Color _getBloodTypeColor(String bloodType) {
    switch (bloodType) {
      case 'A+': return Colors.red[100]!;
      case 'A-': return Colors.red[50]!;
      case 'B+': return Colors.blue[100]!;
      case 'B-': return Colors.blue[50]!;
      case 'AB+': return Colors.purple[100]!;
      case 'AB-': return Colors.purple[50]!;
      case 'O+': return Colors.green[100]!;
      case 'O-': return Colors.green[50]!;
      default: return Colors.grey[100]!;
    }
  }

  // Get text color for blood type badge
  Color _getBloodTypeTextColor(String bloodType) {
    switch (bloodType) {
      case 'A+': return Colors.red[800]!;
      case 'A-': return Colors.red[700]!;
      case 'B+': return Colors.blue[800]!;
      case 'B-': return Colors.blue[700]!;
      case 'AB+': return Colors.purple[800]!;
      case 'AB-': return Colors.purple[700]!;
      case 'O+': return Colors.green[800]!;
      case 'O-': return Colors.green[700]!;
      default: return Colors.grey[800]!;
    }
  }

  // Handle navigation between pages
  void _handleNavigation(int index) {
    if (index == _currentNavIndex) return; // Don't navigate if already on the page
    
    setState(() {
      _currentNavIndex = index;
    });
    
    // Navigate to the selected page
    switch (index) {
      case 0:
        // Already on Donors page
        break;
      case 1:
        // Navigate to Add Donation page
        Navigator.pushNamed(context, '/addDonorPage', arguments: widget.user);
        break;
      case 2:
        // Navigate to Who will Donate page
        Navigator.pushNamed(context, '/whoWillDonatePage', arguments: widget.user);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate visible donations based on pagination
    final endIndex = _page * _itemsPerPage;
    final visibleDonations = _filteredDonations.length > endIndex
        ? _filteredDonations.sublist(0, endIndex)
        : _filteredDonations;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFEE2E2), // red-50
              Color(0xFFFCE7F3), // pink-50
              Color(0xFFFEE2E2), // red-100
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: const SizedBox.shrink(), // Empty when expanded
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Only show title when collapsed
                    final bool isCollapsed = constraints.biggest.height <= kToolbarHeight + MediaQuery.of(context).padding.top;
                    
                    // Dynamically update the title
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (isCollapsed && (AppBar().title != Text(widget.user.nomHospital))) {
                        setState(() {
                          (context as Element).markNeedsBuild();
                        });
                      }
                    });
                    
                    return FlexibleSpaceBar(
                      title: isCollapsed 
                        ? Text(
                            "${widget.user.nomHospital}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFDC2626),
                              Color(0xFFB91C1C),
                            ],
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
                              padding: const EdgeInsets.only(left: 16, top: 70),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.water_drop,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Blood Donations",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "${widget.user.nomHospital}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.red[400]),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by CIN',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey[400]),
                            ),
                            onChanged: (_) => _applySearch(),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '${_filteredDonations.length} result${_filteredDonations.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Available Donors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.red[200]!,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // No Results
              if (!_isLoading && visibleDonations.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.opacity,
                            size: 40,
                            color: Colors.red[300],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No results found.',
                            style: TextStyle(
                              color: Colors.red[500],
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Try adjusting your search criteria.',
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Donation Cards
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= visibleDonations.length) {
                        return null;
                      }
                      
                      final donor = visibleDonations[index];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildDonorCard(donor),
                      );
                    },
                    childCount: visibleDonations.length,
                  ),
                ),
              ),

              // Loading Indicator
              if (_isLoading)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red[400]!),
                      ),
                    ),
                  ),
                ),

              // End of Results
              if (!_isLoading && !_hasMore && visibleDonations.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.red[500]!,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'End of results',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom Padding
              SliverToBoxAdapter(
                child: SizedBox(height: 80), // Increased for bottom navigation bar space
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildDonorCard(Donation donor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blood Type Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getBloodTypeColor(donor.bloodType),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.opacity,
                      size: 18,
                      color: _getBloodTypeTextColor(donor.bloodType),
                    ),
                    SizedBox(width: 8),
                    Text(
                      donor.bloodType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getBloodTypeTextColor(donor.bloodType),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 16,
                      color: _getBloodTypeTextColor(donor.bloodType),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${donor.frequence} donations',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _getBloodTypeTextColor(donor.bloodType),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Donor Info
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor.fullname,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
                SizedBox(height: 16),
                
                // Contact Info
                _infoRow(Icons.credit_card, donor.cin),
                SizedBox(height: 8),
                _infoRow(Icons.phone, donor.numTel),
                SizedBox(height: 8),
                _infoRow(Icons.email, donor.email),
                
                SizedBox(height: 16),
                Divider(color: Colors.grey[100]),
                SizedBox(height: 12),
                
                // Donation Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'First Donation',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.red[500],
                              ),
                              SizedBox(width: 4),
                              Text(
                                donor.firstDonationDate,
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Donation',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.red[500],
                              ),
                              SizedBox(width: 4),
                              Text(
                                donor.lastDonationDate,
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.red[500],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}