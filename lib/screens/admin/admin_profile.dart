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

  // Counts
  int jobsPosted = 0;
  int eventsPosted = 0;
  int applicationsReceived = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminInfo();
  }

  // Fetch admin info & counts dynamically
  Future<void> _fetchAdminInfo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // Fetch admin user info
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) admin = UserModel.fromMap(userDoc.data()!);

      // Fetch jobs
      final jobsSnap = await _firestore
          .collection('jobs')
          .where('adminId', isEqualTo: uid)
          .get();
      jobsPosted = jobsSnap.docs.length;

      // Fetch applications for these jobs
      if (jobsSnap.docs.isNotEmpty) {
        final jobIds = jobsSnap.docs.map((doc) => doc.id).toList();
        final applicationsSnap = await _firestore
            .collection('applications')
            .where('jobId', whereIn: jobIds)
            .get();
        applicationsReceived = applicationsSnap.docs.length;
      }

      // Fetch events
      final eventsSnap = await _firestore
          .collection('events')
          .where('adminId', isEqualTo: uid)
          .get();
      eventsPosted = eventsSnap.docs.length;

      setState(() => loading = false);
    } catch (e) {
      debugPrint("Error fetching admin info: $e");
      setState(() => loading = false);
    }
  }

  // Calculate progress dynamically
  double _calculateProgress(int count) {
    if (count >= 10) return 1.0;
    return count / 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Admin Profile"),
        backgroundColor: primaryTeal,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade300,
                    child: Image.asset('assets/images/avatar.jpg')
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin?.name ?? "Admin Name",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        admin?.email ?? "admin@example.com",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Analytics Cards
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _analyticsCard(
                    "Jobs Posted", jobsPosted, Icons.work_outline, Colors.blue),
                _analyticsCard("Events Posted", eventsPosted,
                    Icons.event_note_outlined, Colors.orange),
                _analyticsCard("Applications Received", applicationsReceived,
                    Icons.people, Colors.green),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Bars
            _progressCard("Jobs Posted Progress", _calculateProgress(jobsPosted)),
            const SizedBox(height: 12),
            _progressCard(
                "Events Posted Progress", _calculateProgress(eventsPosted)),
            const SizedBox(height: 12),
            _progressCard("Applications Processed",
                _calculateProgress(applicationsReceived)),
          ],
        ),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Widget _analyticsCard(String title, int count, IconData icon, Color color) {
    final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;
    return SizedBox(
      width: cardWidth,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressCard(String title, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  color: primaryTeal,
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 10,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text("${(progress * 100).toInt()}%",
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
