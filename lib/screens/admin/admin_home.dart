import 'package:flutter/material.dart';
import 'package:job_portal/screens/admin/admin_dashboard.dart';
import 'package:job_portal/screens/admin/events_screen.dart';
import 'package:job_portal/screens/admin/admin_profile.dart';
import 'package:job_portal/screens/admin/transport/admin_transport_screen.dart'; // New import

const Color primaryTeal = Color(0xFF3CC6C6);

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHome();
}

class _AdminHome extends State<AdminHome> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      AdminDashboard(),           // Regular Jobs
          // Transport Jobs (New tab)
      EventsScreen(),
      AdminProfile(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Jobs',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
