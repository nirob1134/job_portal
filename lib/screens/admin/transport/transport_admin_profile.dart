import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/user_model.dart';


const Color primaryTeal = Color(0xFF3CC6C6);

class TransportAdminProfile extends StatefulWidget {
  const TransportAdminProfile({super.key});

  @override
  State<TransportAdminProfile> createState() =>
      _TransportAdminProfileState();
}

class _TransportAdminProfileState
    extends State<TransportAdminProfile> {

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

  // ✅ Fetch data
  Future<void> _fetchTransportAdminInfo() async {

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {

      /// USER INFO
      final userDoc =
      await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        admin = UserModel.fromMap(userDoc.data()!);
      }

      /// TRANSPORT JOBS
      final transportSnap = await _firestore
          .collection('transport_jobs')
          .where('transportAdminId', isEqualTo: uid)
          .get();

      transportJobsPosted = transportSnap.docs.length;

      /// APPLICATIONS
      if (transportSnap.docs.isNotEmpty) {

        final jobIds =
        transportSnap.docs.map((doc) => doc.id).toList();

        final appSnap = await _firestore
            .collection('transport_applications')
            .where('jobId', whereIn: jobIds)
            .get();

        applicationsReceived = appSnap.docs.length;
      }

      setState(() => loading = false);

    } catch (e) {
      debugPrint("Error fetching transport admin info: $e");
      setState(() => loading = false);
    }
  }

  double _calculateProgress(int count) {
    if (count >= 10) return 1.0;
    return count / 10;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Transport Admin Profile"),
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

            /// PROFILE CARD
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
                    child: Image.asset(
                        'assets/images/avatar.jpg'),
                  ),

                  const SizedBox(width: 16),

                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        admin?.name ?? "Transport Admin",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        admin?.email ??
                            "transport@admin.com",
                        style: const TextStyle(
                            color: Colors.grey),
                      ),
                    ],
                  ),

                  const Spacer(),

                  IconButton(
                    icon: const Icon(Icons.logout,
                        color: Colors.red),
                    onPressed: () =>
                        _showLogoutDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ANALYTICS
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [

                _analyticsCard(
                  "Transport Jobs",
                  transportJobsPosted,
                  Icons.directions_bus,
                  Colors.blue,
                ),

                _analyticsCard(
                  "Applications",
                  applicationsReceived,
                  Icons.people,
                  Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// PROGRESS
            _progressCard(
              "Transport Jobs Progress",
              _calculateProgress(transportJobsPosted),
            ),

            const SizedBox(height: 12),

            _progressCard(
              "Applications Received",
              _calculateProgress(applicationsReceived),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LOGOUT =================
  void _showLogoutDialog(BuildContext context) {

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content:
        const Text("Are you sure you want to log out?"),
        actions: [

          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () async {

              await FirebaseAuth.instance.signOut();

              Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                  '/login', (route) => false);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  // ================= UI CARDS =================

  Widget _analyticsCard(
      String title,
      int count,
      IconData icon,
      Color color,
      ) {

    final cardWidth =
        (MediaQuery.of(context).size.width - 48) / 2;

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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: TextAlign.center,
              style:
              const TextStyle(color: Colors.grey),
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
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              color: primaryTeal,
              backgroundColor: Colors.grey.shade300,
              minHeight: 10,
            ),
          ),

          const SizedBox(height: 4),

          Text("${(progress * 100).toInt()}%",
              style:
              const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
