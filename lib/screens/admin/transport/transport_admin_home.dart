import 'package:flutter/material.dart';
import 'package:job_portal/screens/admin/transport/post_transport_screen.dart';
import 'package:job_portal/screens/admin/transport/transport_admin_profile.dart';

import 'admin_transport_screen.dart';



const Color primaryTeal = Color(0xFF3CC6C6);

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

      // ================= BODY =================
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // ================= FLOATING BUTTON =================
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        backgroundColor: primaryTeal,
        icon: const Icon(Icons.add),
        label: const Text("Post Transport"),
        onPressed: () {

          Navigator.push(context, MaterialPageRoute(builder: (_)=>PostTransportScreen()));

        },
      )
          : null,

      // ================= BOTTOM NAV =================
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
            )
          ],
        ),

        child: BottomNavigationBar(

          currentIndex: _currentIndex,

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          selectedItemColor: primaryTeal,
          unselectedItemColor: Colors.grey,

          type: BottomNavigationBarType.fixed,

          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined),
              activeIcon: Icon(Icons.directions_bus),
              label: "Transport Jobs",
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
