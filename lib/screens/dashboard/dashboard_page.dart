import 'package:flutter/material.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/screens/dashboard/donations_page.dart';
import 'package:lifelinkai/screens/dashboard/who_will_donate_page.dart';
import 'package:lifelinkai/screens/dashboard/add_donor_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class DashboardPage extends StatefulWidget {
  final User user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      WhoWillDonatePage(user: widget.user),
      DonationsPage(user: widget.user),
      AddDonorPage(user: widget.user),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        color: const Color(0xFFDC2626),
        buttonBackgroundColor: const Color(0xFFDC2626),
        height: 60,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.bloodtype, color: Colors.white),
          Icon(Icons.people, color: Colors.white),
        ],
      ),
    );
  }
} 