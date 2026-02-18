import 'package:flutter/material.dart';
import 'package:job_portal/main.dart';
import 'package:job_portal/screens/profile/update_profile_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider/application_provider.dart';
import '../../providers/auth_provider/my_auth_provider.dart';
import '../../models/application_model.dart';



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

  // Fetches from both 'users' and 'user_details' collections
  Future<void> fetchFullProfile() async {
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    final uid = authProvider.auth.currentUser?.uid;

    if (uid != null) {
      try {
        // 1. Fetch Main Account Data
        final userSnap = await authProvider.db.collection('users').doc(uid).get();

        // 2. Fetch Additional Details from separate collection
        final detailsSnap = await authProvider.db.collection('user_details').doc(uid).get();

        if (userSnap.exists) {
          setState(() {
            currentUserData = UserModel.fromMap(userSnap.data()!);
            if (detailsSnap.exists) {
              additionalDetails = detailsSnap.data()!;
            }
            isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);
    final appProvider = Provider.of<ApplicationProvider>(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF0E2A47))));
    }

    final userId = authProvider.auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF081A2F),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 28,color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdateProfileScreen(existingData: additionalDetails),
                ),
              ).then((_) => fetchFullProfile()); // This refreshes the screen after saving
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------- HEADER ----------
            _buildProfileHeader(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- PIE CHART STATS ----------
                  _buildApplicationChart(appProvider, userId),

                  const SizedBox(height: 25),
                  const Text("Academic & Personal Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E2A47))),
                  const SizedBox(height: 15),

                  // Information Rows
                  _infoTile(Icons.fingerprint_rounded, "Student ID", additionalDetails['studentId'] ?? "Not Set"),
                  _infoTile(Icons.school_outlined, "Department", additionalDetails['department'] ?? "Not Set"),
                  _infoTile(Icons.location_on_outlined, "Home Address", additionalDetails['address'] ?? "Not Set"),

                  const Divider(height: 40),

                  _infoTile(Icons.phone_android_rounded, "Phone Number", currentUserData!.phone),
                  _infoTile(Icons.email_outlined, "Registered Email", currentUserData!.email),

                  const SizedBox(height: 30),
                  _buildLogoutButton(authProvider),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF081A2F),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white12,
            child: CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
            ),
          ),
          const SizedBox(height: 15),
          Text(currentUserData?.name ?? "Student",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(currentUserData?.role ?? "User",
              style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildApplicationChart(ApplicationProvider appProvider, String userId) {
    return StreamBuilder<List<ApplicationModel>>(
      stream: appProvider.getApplicationsByUser(userId),
      builder: (context, snapshot) {
        int accepted = 0;
        int rejected = 0;
        int total = 0;
        double percent = 0.0;

        if (snapshot.hasData) {
          final apps = snapshot.data!;
          total = apps.length;
          accepted = apps.where((a) => a.status.toLowerCase() == 'accepted').length;
          rejected = apps.where((a) => a.status.toLowerCase() == 'rejected').length;
          percent = total == 0 ? 0.0 : accepted / total;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
          ),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 55.0,
                lineWidth: 10.0,
                animation: true,
                percent: percent,
                center: Text("${(percent * 100).toInt()}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: const Color(0xFF4A90E2),
                backgroundColor: Colors.redAccent.withOpacity(0.1),
              ),
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Application Status",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0E2A47))),
                    const SizedBox(height: 8),
                    _statRow(Colors.green, "Accepted: $accepted"),
                    _statRow(Colors.redAccent, "Rejected: $rejected"),
                    _statRow(Colors.grey, "Total Applied: $total"),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _statRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF4A90E2).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF4A90E2), size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0E2A47))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(MyAuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => authProvider.logout(),
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text("Logout Account", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.redAccent.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}