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
      final userDoc = await authProvider.db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;

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
        body: Center(child: CircularProgressIndicator(color: Color(0xFF081A2F))),
      );
    }

    final firebaseUser = authProvider.auth.currentUser;
    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: Text("Session expired. Please login again.", style: TextStyle(color: Colors.grey))),
      );
    }

    final userId = firebaseUser.uid;
    const themeColor = Color(0xFF081A2F);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeColor,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
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
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(themeColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildApplicationChart(appProvider, userId, themeColor),
                  const SizedBox(height: 30),
                  const Text(
                    "Academic & Personal Details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoTile(Icons.badge_outlined, "Student ID", additionalDetails['studentId'] ?? "Not Set", themeColor),
                  _infoTile(Icons.school_outlined, "Department", additionalDetails['department'] ?? "Not Set", themeColor),
                  _infoTile(Icons.location_on_outlined, "Address", additionalDetails['address'] ?? "Not Set", themeColor),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Color(0xFFE2E8F0), height: 30),
                  ),
                  _infoTile(Icons.phone_outlined, "Phone", currentUserData?.phone ?? "Not Set", themeColor),
                  _infoTile(Icons.email_outlined, "Email", currentUserData?.email ?? "Not Set", themeColor),
                  const SizedBox(height: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 3),
            ),
            child: const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            currentUserData?.name ?? "Student",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (currentUserData?.role ?? "User").toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationChart(ApplicationProvider appProvider, String userId, Color themeColor) {
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 46,
                lineWidth: 8,
                percent: percent,
                animation: true,
                center: Text(
                  "${(percent * 100).toInt()}%",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: themeColor),
                ),
                progressColor: const Color(0xFF10B981), // Professional green success accent
                backgroundColor: const Color(0xFFF1F5F9),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusRow("Accepted", accepted, const Color(0xFF10B981)),
                    _statusRow("Rejected", rejected, const Color(0xFFEF4444)),
                    _statusRow("Total Applied", total, themeColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            "$value",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: themeColor.withOpacity(0.7), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)
                ),
                const SizedBox(height: 2),
                Text(
                    value,
                    style: TextStyle(fontWeight: FontWeight.w600, color: themeColor, fontSize: 14)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}