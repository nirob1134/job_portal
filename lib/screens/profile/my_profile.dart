import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import '../../models/application_model.dart';
import '../../providers/auth_provider/application_provider.dart';
import '../../providers/auth_provider/my_auth_provider.dart';
import '../profile/update_profile_screen.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  UserModel? currentUserData;
  Map<String, dynamic> additionalDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFullProfile();
  }

  Future<void> fetchFullProfile() async {
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    final uid = authProvider.auth.currentUser?.uid;

    if (uid == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      // Fetch user document safely
      final userDoc = await authProvider.db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;

        // Provide defaults if fields missing
        final safeData = {
          'uid': data['uid'] ?? uid,
          'name': data['name'] ?? "Student",
          'phone': data['phone'] ?? "Not Set",
          'email': data['email'] ?? "Not Set",
          'role': data['role'] ?? "User",
          'createdAt': data['createdAt'] ?? Timestamp.now(),
        };

        currentUserData = UserModel.fromMap(safeData);
      }

      // Fetch user_details safely
      final detailsDoc = await authProvider.db.collection('user_details').doc(uid).get();
      if (detailsDoc.exists) {
        additionalDetails = detailsDoc.data()!;
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);
    final appProvider = Provider.of<ApplicationProvider>(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final firebaseUser = authProvider.auth.currentUser;
    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: Text("Session expired. Please login again.")),
      );
    }

    final userId = firebaseUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF081A2F),
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdateProfileScreen(existingData: additionalDetails),
                ),
              ).then((_) => fetchFullProfile());
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildApplicationChart(appProvider, userId),
                  const SizedBox(height: 25),
                  const Text(
                    "Academic & Personal Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E2A47),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _infoTile(Icons.badge, "Student ID", additionalDetails['studentId'] ?? "Not Set"),
                  _infoTile(Icons.school, "Department", additionalDetails['department'] ?? "Not Set"),
                  _infoTile(Icons.location_on, "Address", additionalDetails['address'] ?? "Not Set"),
                  const Divider(height: 40),
                  _infoTile(Icons.phone, "Phone", currentUserData?.phone ?? "Not Set"),
                  _infoTile(Icons.email, "Email", currentUserData?.email ?? "Not Set"),
                  const SizedBox(height: 30),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20, top: 15), // smaller padding
      decoration: const BoxDecoration(
        color: Color(0xFF081A2F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40, // smaller avatar
            backgroundImage: AssetImage('assets/images/avatar.jpg'),
          ),
          const SizedBox(height: 10),
          Text(
            currentUserData?.name ?? "Student",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20, // slightly smaller text
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            currentUserData?.role ?? "User",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13, // smaller text
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildApplicationChart(ApplicationProvider appProvider, String userId) {
    return StreamBuilder<List<ApplicationModel>>(
      stream: appProvider.getApplicationsByUser(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final apps = snapshot.data!;
        final total = apps.length;
        final accepted = apps.where((e) => e.status.toLowerCase() == 'accepted').length;
        final rejected = apps.where((e) => e.status.toLowerCase() == 'rejected').length;
        final percent = total == 0 ? 0.0 : (accepted / total).toDouble();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              // Circular Percent Indicator
              CircularPercentIndicator(
                radius: 50,
                lineWidth: 10,
                percent: percent,
                animation: true,
                center: Text(
                  "${(percent * 100).toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey.withOpacity(0.2),
                circularStrokeCap: CircularStrokeCap.round,
              ),

              const SizedBox(width: 20),

              // Status Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusRow("Accepted", accepted, Colors.green),
                    _statusRow("Rejected", rejected, Colors.redAccent),
                    _statusRow("Total Applied", total, Colors.blue),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Helper Widget for colored rows
  Widget _statusRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            "$label: $value",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }


  Widget _infoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
