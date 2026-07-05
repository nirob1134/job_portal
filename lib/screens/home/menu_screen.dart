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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out of your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), // Professional red accent
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Sign Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    const themeColor = Color(0xFF081A2F);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          // ---------- COMPACT DARK HEADER ----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [themeColor, Color(0xFF0E2A47)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _getUserData(),
              builder: (context, snapshot) {
                final userData = snapshot.data;
                return Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 28,
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
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
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
                  ],
                );
              },
            ),
          ),

          // ---------- MENU SECTION ----------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _sectionLabel("Account Settings"),
                _buildMenuCard(context, Icons.person_outlined, "My Profile", const Color(0xFF4A90E2), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProfile()));
                }),
                _buildMenuCard(context, Icons.favorite_outline_rounded, "Favourite Jobs", const Color(0xFFF05A94), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FavouriteJobsScreen()));
                }),

                const SizedBox(height: 24),
                _sectionLabel("Job Dashboard"),
                _buildMenuCard(context, Icons.business_center_outlined, "Department Jobs", const Color(0xFF4A90E2), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const JobsScreen()));
                }),
                _buildMenuCard(context, Icons.assignment_turned_in_outlined, "Applied Dept. Jobs", const Color(0xFF10B981), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ListOfAppliedJobScreen()));
                }),
                _buildMenuCard(context, Icons.local_shipping_outlined, "Transport Jobs", const Color(0xFFF5A623), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportJobScreen()));
                }),
                _buildMenuCard(context, Icons.fact_check_outlined, "Applied Transport Jobs", Colors.teal, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ListOfAppliedTransportJobScreen()));
                }),

                const SizedBox(height: 24),
                _sectionLabel("Session"),

                // Professional Logout Option
                _buildMenuCard(
                  context,
                  Icons.logout_rounded,
                  "Sign Out",
                  const Color(0xFFEF4444),
                      () => logout(context),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context,
      IconData icon,
      String title,
      Color color,
      VoidCallback onTap,
      {bool isDestructive = false}
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 12,
          color: isDestructive ? const Color(0xFFEF4444).withOpacity(0.4) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}