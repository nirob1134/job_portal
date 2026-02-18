import 'package:flutter/material.dart';
import 'package:job_portal/screens/home/events_list_screen.dart';
import 'package:job_portal/screens/home/menu_screen.dart';
import 'transport_job_screen.dart';
import 'user_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    UserDashboard(),
    EventsListScreen(),
    TransportJobScreen(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),

          // Styling
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0E2A47), // Matching your dark header
          unselectedItemColor: Colors.grey.shade400,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),

          type: BottomNavigationBarType.fixed,
          elevation: 0, // We use the Container's shadow instead

          items: [
            _buildNavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Home', 0),
            _buildNavItem(Icons.event_available_rounded, Icons.event_available_outlined, 'Events', 1),
            _buildNavItem(Icons.local_shipping_rounded, Icons.local_shipping_outlined, 'Transport', 2),
            _buildNavItem(Icons.menu_open_rounded, Icons.menu_rounded, 'Menu', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          // Subtle pill background for the active item
          color: isSelected ? const Color(0xFF0E2A47).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(isSelected ? activeIcon : inactiveIcon),
      ),
      label: label,
    );
  }
}