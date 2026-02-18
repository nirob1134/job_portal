import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_portal/screens/Dashboard/list_of_applied_job_screen.dart';
import 'package:job_portal/screens/Dashboard/list_of_applied_transport_job_screen.dart';
import 'package:job_portal/screens/home/transport_job_screen.dart';
import 'package:job_portal/screens/jobs/jobs_screen.dart';
import '../auth/login_screen.dart';
import '../profile/my_profile.dart';
import '../favourite/favourite_job_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  // ================= GET USER DATA FROM FIRESTORE =================
  Future<Map<String, dynamic>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {"name": "Student", "email": ""};

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return {
      "name": doc.data()?['name'] ?? user.displayName ?? "Student",
      "email": user.email ?? "",
    };
  }

  Future<void> logout(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // ---------- COMPACT DARK HEADER ----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF081A2F), Color(0xFF0E2A47)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _getUserData(),
              builder: (context, snapshot) {
                final userData = snapshot.data;
                return Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white24,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/avatar.jpg'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            userData?['name'] ?? "Loading...",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userData?['email'] ?? "",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => logout(context),
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    ),
                  ],
                );
              },
            ),
          ),

          // ---------- MENU SECTION ----------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                _sectionLabel("Account Settings"),
                _buildMenuCard(context, Icons.person_rounded, "My Profile", const Color(0xFF4A90E2), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProfile()));
                }),
                _buildMenuCard(context, Icons.favorite_rounded, "Favourite Jobs", const Color(0xFFF05A94), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FavouriteJobsScreen()));
                }),

                const SizedBox(height: 20),
                _sectionLabel("Job Dashboard"),
                _buildMenuCard(context, Icons.business_center_rounded, "Department Jobs", const Color(0xFF4A90E2), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const JobsScreen()));
                }),
                _buildMenuCard(context, Icons.assignment_turned_in_rounded, "Applied Dept. Jobs", Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ListOfAppliedJobScreen()));
                }),
                _buildMenuCard(context, Icons.local_shipping_rounded, "Transport Jobs", const Color(0xFFF5A623), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportJobScreen()));
                }),
                _buildMenuCard(context, Icons.fact_check_rounded, "Applied Transport Jobs", Colors.teal, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ListOfAppliedTransportJobScreen()));
                }),

                const SizedBox(height: 10),
                _buildMenuCard(context, Icons.help_outline_rounded, "Help Center", Colors.indigo, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2D3142)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
      ),
    );
  }
}