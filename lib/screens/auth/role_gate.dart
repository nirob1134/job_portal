import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:job_portal/screens/admin/transport/transport_admin_home.dart';
import 'package:job_portal/screens/home/home_screen.dart';

import '../admin/admin_home.dart';

class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(),

      builder: (context, snap) {

        // Loading
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If no document exists
        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("User data not found")),
          );
        }

        // ✅ Convert safely
        final data = snap.data!.data() as Map<String, dynamic>;
        final role = data['role'];

        switch (role) {

          case 'admin':
            return const AdminHome();

          case 'transport_admin':
            return const TransportAdminHome();

          default:
            return const HomeScreen();
        }
      },
    );
  }
}
