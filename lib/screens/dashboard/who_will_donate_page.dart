import 'package:flutter/material.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/models/donation.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/widgets/bottom_nav_bar.dart';

class WhoWillDonatePage extends StatefulWidget {
  final User user;

  const WhoWillDonatePage({super.key, required this.user});

  @override
  State<WhoWillDonatePage> createState() => _WhoWillDonatePageState();
}

class _WhoWillDonatePageState extends State<WhoWillDonatePage> {
  List<Donation> _potentialDonors = [];
  bool _isLoading = true;
  int _currentNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchPotentialDonors();
  }

  Future<void> _fetchPotentialDonors() async {
    try {
      final data = await ApiService.fetchDonationsByHospital(widget.user.nomHospital);
      setState(() {
        _potentialDonors = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      _showErrorSnackBar('Failed to load predicted donors.');
      setState(() => _isLoading = false);
    }
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

  void _handleNavigation(int index) {
    if (index == _currentNavIndex) return;

    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/donations_page', arguments: widget.user);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/add_donor_page', arguments: widget.user);
        break;
      case 2:
        // Already on WhoWillDonatePage
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _backgroundGradient(),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.red[400]))
              : _potentialDonors.isEmpty
                  ? _noResultsWidget()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _potentialDonors.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildDonorCard(_potentialDonors[index]),
                        );
                      },
                    ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        backgroundColor: Colors.red[700],
        child: Icon(Icons.logout, color: Colors.white),
      ),
    );
  }

  BoxDecoration _backgroundGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE3F2FD), // light blue
          Color(0xFFFFEBEE), // light red
        ],
      ),
    );
  }

  Widget _noResultsWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No predicted donors.',
              style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Try again later.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorCard(Donation donor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fullname & blood type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  donor.fullname,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getBloodTypeColor(donor.bloodType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    donor.bloodType,
                    style: TextStyle(
                      color: _getBloodTypeTextColor(donor.bloodType),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // CIN & contact
            _infoRow(Icons.credit_card, donor.cin),
            SizedBox(height: 8),
            _infoRow(Icons.phone, donor.numTel),
            SizedBox(height: 8),
            _infoRow(Icons.email, donor.email),

            SizedBox(height: 16),
            Divider(color: Colors.grey[200]),
            SizedBox(height: 8),

            // Donation prediction info
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.red[300], size: 16),
                SizedBox(width: 6),
                Text(
                  "Predicted to donate soon",
                  style: TextStyle(fontSize: 13, color: Colors.red[400]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.red[400]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
}
