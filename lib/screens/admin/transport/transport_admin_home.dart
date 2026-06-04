import 'package:flutter/material.dart';

import 'admin_transport_screen.dart';
import 'transport_admin_profile.dart';

const Color primaryTeal = Color(0xFF3CC6C6);
const Color bgColor = Color(0xFFF8F9FB);

class TransportAdminHome extends StatefulWidget {
  const TransportAdminHome({super.key});

  @override
  State<TransportAdminHome> createState() => _TransportAdminHomeState();
}

class _TransportAdminHomeState extends State<TransportAdminHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminTransportScreen(),
    TransportAdminProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: primaryTeal,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined),
              activeIcon: Icon(Icons.directions_bus),
              label: "Jobs",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}