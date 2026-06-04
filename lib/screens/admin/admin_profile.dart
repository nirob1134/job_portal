import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? admin;

  int jobsPosted = 0;
  int eventsPosted = 0;
  int applicationsReceived = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminInfo();
  }

  Future<void> _fetchAdminInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        admin = UserModel.fromMap(userDoc.data()!);
      }

      final jobsSnap = await _firestore
          .collection('jobs')
          .where('adminId', isEqualTo: uid)
          .get();

      jobsPosted = jobsSnap.docs.length;

      if (jobsSnap.docs.isNotEmpty) {
        final jobIds = jobsSnap.docs.map((doc) => doc.id).toList();

        final applicationsSnap = await _firestore
            .collection('applications')
            .where('jobId', whereIn: jobIds)
            .get();

        applicationsReceived = applicationsSnap.docs.length;
      }

      final eventsSnap = await _firestore
          .collection('events')
          .where('adminId', isEqualTo: uid)
          .get();

      eventsPosted = eventsSnap.docs.length;

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching admin info: $e");

      setState(() {
        loading = false;
      });
    }
  }

  double _calculateProgress(int count) {
    if (count >= 10) return 1.0;
    return count / 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _analyticsCard(
                        title: "Jobs Posted",
                        count: jobsPosted,
                        icon: Icons.work_outline,
                        color: const Color(0xFF4A90E2),
                      ),
                      const SizedBox(width: 12),
                      _analyticsCard(
                        title: "Events Posted",
                        count: eventsPosted,
                        icon: Icons.event_note_outlined,
                        color: const Color(0xFFF5A623),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _wideAnalyticsCard(
                    title: "Applications Received",
                    count: applicationsReceived,
                    icon: Icons.people_outline,
                    color: const Color(0xFF34A853),
                  ),

                  const SizedBox(height: 22),

                  _sectionTitle("Performance Overview"),

                  const SizedBox(height: 12),

                  _progressCard(
                    title: "Jobs Posted Progress",
                    progress: _calculateProgress(jobsPosted),
                  ),

                  const SizedBox(height: 12),

                  _progressCard(
                    title: "Events Posted Progress",
                    progress: _calculateProgress(eventsPosted),
                  ),

                  const SizedBox(height: 12),

                  _progressCard(
                    title: "Applications Processed",
                    progress: _calculateProgress(applicationsReceived),
                  ),

                  const SizedBox(height: 30),
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
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF081A2F),
            Color(0xFF0E2A47),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFD9E8D1),
            backgroundImage: AssetImage('assets/images/avatar.jpg'),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Admin Profile",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  admin?.name ?? "Admin Name",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  admin?.email ?? "admin@example.com",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.14),
            ),
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF081A2F),
        ),
      ),
    );
  }

  Widget _analyticsCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 135,
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wideAnalyticsCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF081A2F),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),

          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard({
    required String title,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: primaryTeal,
                size: 20,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF081A2F),
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

          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: value,
                  color: primaryTeal,
                  backgroundColor: Colors.grey.shade200,
                  minHeight: 10,
                ),
              );
            },
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
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
}