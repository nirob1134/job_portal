import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/user_model.dart';

const Color primaryTeal = Color(0xFF3CC6C6);
const Color darkNavy = Color(0xFF081A2F);
const Color navy = Color(0xFF0E2A47);
const Color bgColor = Color(0xFFF8F9FB);

class TransportAdminProfile extends StatefulWidget {
  const TransportAdminProfile({super.key});

  @override
  State<TransportAdminProfile> createState() => _TransportAdminProfileState();
}

class _TransportAdminProfileState extends State<TransportAdminProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? admin;

  int transportJobsPosted = 0;
  int applicationsReceived = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransportAdminInfo();
  }

  Future<void> _fetchTransportAdminInfo() async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        admin = UserModel.fromMap(userDoc.data()!);
      }

      final transportSnap = await _firestore
          .collection('transport_jobs')
          .where('adminId', isEqualTo: uid)
          .get();

      transportJobsPosted = transportSnap.docs.length;

      int totalApplications = 0;

      for (final jobDoc in transportSnap.docs) {
        final subAppSnap = await _firestore
            .collection('transport_jobs')
            .doc(jobDoc.id)
            .collection('applications')
            .get();

        totalApplications += subAppSnap.docs.length;
      }

      applicationsReceived = totalApplications;

      if (mounted) {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Error fetching transport admin info: $e");
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  double _calculateProgress(int count) {
    if (count >= 10) return 1.0;
    return count / 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _analyticsCard(
                          "Transport Jobs",
                          transportJobsPosted,
                          Icons.directions_bus,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _analyticsCard(
                          "Applications",
                          applicationsReceived,
                          Icons.people_alt_outlined,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _progressCard(
                    "Transport Jobs Progress",
                    _calculateProgress(transportJobsPosted),
                    Icons.trending_up,
                  ),
                  const SizedBox(height: 14),
                  _progressCard(
                    "Applications Received",
                    _calculateProgress(applicationsReceived),
                    Icons.assignment_turned_in_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [darkNavy, navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin?.name ?? "Transport Admin",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      admin?.email ?? _auth.currentUser?.email ?? "No email found",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _showLogoutDialog(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: primaryTeal),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Transport Administrator",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _analyticsCard(
      String title,
      int count,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(String title, double progress, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryTeal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkNavy,
                  ),
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                  color: primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: primaryTeal,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                      (route) => false,
                );
              }
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}