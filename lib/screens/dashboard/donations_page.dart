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
  final PageController _pageController = PageController();
  
  List<Donation> _donations = [];
  List<Donation> _filteredDonations = [];
  bool _isLoading = true;
  int _currentPage = 1;
  final int _itemsPerPage = 6;  // Reduced for better UX
  int _totalPages = 1;
  int _currentNavIndex = 0;
  String _selectedBloodType = 'All';
  String _sortBy = 'name'; // 'name', 'date', 'frequency'

  final List<String> _bloodTypes = ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _sortOptions = ['name', 'date', 'frequency'];

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDonations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.fetchDonationsByHospital(widget.user.nomHospital);
      
      setState(() {
        _donations = data;
        _applyFiltersAndSort();
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

  void _applyFiltersAndSort() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      // Apply search filter
      List<Donation> filtered = _donations;
      
      if (query.isNotEmpty) {
        filtered = filtered
            .where((donor) => 
                donor.cin.toLowerCase().contains(query) ||
                donor.fullname.toLowerCase().contains(query) ||
                donor.email.toLowerCase().contains(query))
            .toList();
      }
      
      // Apply blood type filter
      if (_selectedBloodType != 'All') {
        filtered = filtered
            .where((donor) => donor.bloodType == _selectedBloodType)
            .toList();
      }
      
      // Apply sorting
      switch (_sortBy) {
        case 'name':
          filtered.sort((a, b) => a.fullname.compareTo(b.fullname));
          break;
        case 'date':
          filtered.sort((a, b) => b.lastDonationDate.compareTo(a.lastDonationDate));
          break;
        case 'frequency':
          filtered.sort((a, b) => b.frequence.compareTo(a.frequence));
          break;
      }
      
      _filteredDonations = filtered;
      _totalPages = (_filteredDonations.length / _itemsPerPage).ceil();
      if (_totalPages == 0) _totalPages = 1;
      
      // Reset to first page when filters change
      _currentPage = 1;
    });
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
      });
      _pageController.animateToPage(
        page - 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Donation> _getCurrentPageDonations() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    
    if (startIndex >= _filteredDonations.length) return [];
    
    return _filteredDonations.sublist(
      startIndex, 
      endIndex > _filteredDonations.length ? _filteredDonations.length : endIndex
    );
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

  void _handleNavigation(int index) {
    if (index == _currentNavIndex) return;
    
    setState(() {
      _currentNavIndex = index;
    });
    
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/addDonorPage', arguments: widget.user);
        break;
      case 2:
        Navigator.pushNamed(context, '/whoWillDonatePage', arguments: widget.user);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFEE2E2),
              Color(0xFFFCE7F3),
              Color(0xFFFEE2E2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              _buildModernHeader(),
              
              // Filters and Search Section
              _buildFiltersSection(),
              
              // Results Info
              _buildResultsInfo(),
              
              // Main Content
              Expanded(
                child: _isLoading ? _buildLoadingState() : _buildContentWithPagination(),
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

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
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
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Blood Donations",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.user.nomHospital,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white),
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
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, CIN, or email...',
                prefixIcon: Icon(Icons.search, color: Colors.red[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              onChanged: (_) => _applyFiltersAndSort(),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Filter Row
          Row(
            children: [
              // Blood Type Filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blood Type',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedBloodType,
                          isExpanded: true,
                          items: _bloodTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedBloodType = newValue!;
                            });
                            _applyFiltersAndSort();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(width: 16),
              
              // Sort By Filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sort By',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(value: 'name', child: Text('Name')),
                            DropdownMenuItem(value: 'date', child: Text('Latest Donation')),
                            DropdownMenuItem(value: 'frequency', child: Text('Most Donations')),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _sortBy = newValue!;
                            });
                            _applyFiltersAndSort();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${_getCurrentPageDonations().length} of ${_filteredDonations.length} donors',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_totalPages > 1)
            Text(
              'Page $_currentPage of $_totalPages',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red[400]!),
          ),
          SizedBox(height: 16),
          Text(
            'Loading donors...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWithPagination() {
    final currentDonations = _getCurrentPageDonations();
    
    if (currentDonations.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Donor Cards
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page + 1;
              });
            },
            itemCount: _totalPages,
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * _itemsPerPage;
              final endIndex = startIndex + _itemsPerPage;
              final pageDonations = _filteredDonations.sublist(
                startIndex,
                endIndex > _filteredDonations.length ? _filteredDonations.length : endIndex,
              );
              
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: pageDonations.map((donor) => 
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: _buildModernDonorCard(donor),
                    )
                  ).toList(),
                ),
              );
            },
          ),
        ),
        
        // Pagination Controls
        if (_totalPages > 1) _buildPaginationControls(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              'No donors found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria or filters',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedBloodType = 'All';
                  _sortBy = 'name';
                });
                _applyFiltersAndSort();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          IconButton(
            onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            icon: Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: _currentPage > 1 ? Colors.red[50] : Colors.grey[100],
              foregroundColor: _currentPage > 1 ? Colors.red[600] : Colors.grey[400],
            ),
          ),
          
          SizedBox(width: 20),
          
          // Page Numbers
          ...List.generate(
            _totalPages > 5 ? 5 : _totalPages,
            (index) {
              int pageNum;
              if (_totalPages <= 5) {
                pageNum = index + 1;
              } else {
                if (_currentPage <= 3) {
                  pageNum = index + 1;
                } else if (_currentPage > _totalPages - 3) {
                  pageNum = _totalPages - 4 + index;
                } else {
                  pageNum = _currentPage - 2 + index;
                }
              }
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _goToPage(pageNum),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: pageNum == _currentPage ? Colors.red[400] : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: pageNum == _currentPage ? null : Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        pageNum.toString(),
                        style: TextStyle(
                          color: pageNum == _currentPage ? Colors.white : Colors.grey[600],
                          fontWeight: pageNum == _currentPage ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(width: 20),
          
          // Next Button
          IconButton(
            onPressed: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
            icon: Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: _currentPage < _totalPages ? Colors.red[50] : Colors.grey[100],
              foregroundColor: _currentPage < _totalPages ? Colors.red[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDonorCard(Donation donor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Blood Type
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getBloodTypeColor(donor.bloodType),
                  _getBloodTypeColor(donor.bloodType).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.opacity,
                        size: 20,
                        color: _getBloodTypeTextColor(donor.bloodType),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donor.bloodType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: _getBloodTypeTextColor(donor.bloodType),
                          ),
                        ),
                        Text(
                          'Blood Type',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getBloodTypeTextColor(donor.bloodType).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 16,
                        color: _getBloodTypeTextColor(donor.bloodType),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${donor.frequence}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getBloodTypeTextColor(donor.bloodType),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Donor Information
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor.fullname,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                
                // Contact Info Grid
                Row(
                  children: [
                    Expanded(child: _buildInfoItem(Icons.credit_card, 'CIN', donor.cin)),
                    SizedBox(width: 16),
                    Expanded(child: _buildInfoItem(Icons.phone, 'Phone', donor.numTel)),
                  ],
                ),
                SizedBox(height: 12),
                _buildInfoItem(Icons.email, 'Email', donor.email),
                
                SizedBox(height: 20),
                
                // Donation Dates
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDateInfo('First Donation', donor.firstDonationDate),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildDateInfo('Last Donation', donor.lastDonationDate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.red[500],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String label, String date) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: Colors.red[500],
            ),
            SizedBox(width: 4),
            Text(
              date,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}