import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/event_model.dart';
import '../../models/job_model.dart';
import '../../models/transport_model.dart';
import '../../widget/job_card.dart';
import '../../widget/transport_card.dart';
import '../../widget/event_card.dart';
import '../../widget/auto_banner_slider.dart';
import '../jobs/jobs_screen.dart';
import 'events_list_screen.dart';
import 'transport_job_screen.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Oyon";
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data()?['name'] ?? "Oyon";
  }

  Future<Map<String, int>> _getTotalCounts() async {
    final jobsSnapshot = await FirebaseFirestore.instance.collection('jobs').get();
    final transportSnapshot = await FirebaseFirestore.instance.collection('transport_jobs').get();
    final eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();

    return {
      'Jobs': jobsSnapshot.size,
      'Transport': transportSnapshot.size,
      'Events': eventsSnapshot.size,
    };
  }

  // ================= HEADER =================
  Widget _buildDashboardHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30), // Space after banner
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF081A2F), Color(0xFF0E2A47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFFD9E8D1),
                    backgroundImage: AssetImage('assets/images/avatar.jpg'),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Welcome back,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            Text("${snapshot.data ?? "Oyon"}.",
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        );
                      },
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: const Icon(Icons.notifications_none, color: Colors.white),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AutoBannerSlider(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDashboardHeader(),

            const SizedBox(height: 24), // Gap between header and categories

            // ================= FIXED CATEGORY ROW =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryCard(
                      context,
                      title: "Jobs",
                      icon: Icons.business_center,
                      color: const Color(0xFF4A90E2),
                      screen: const JobsScreen()
                  ),
                  const SizedBox(width: 12),
                  _buildCategoryCard(
                      context,
                      title: "Transport",
                      icon: Icons.local_shipping,
                      color: const Color(0xFFF5A623),
                      screen: const TransportJobScreen()
                  ),
                  const SizedBox(width: 12),
                  _buildCategoryCard(
                      context,
                      title: "Events",
                      icon: Icons.calendar_today,
                      color: const Color(0xFFF05A94),
                      screen: const EventsListScreen()
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: "Active Vacancies"),
                  const JobsList(),

                  const SizedBox(height: 20),
                  const SectionTitle(title: "Upcoming Events"),
                  const EventsList(),

                  const SizedBox(height: 20),
                  const SectionTitle(title: "Transport Jobs"),
                  const TransportJobsList(),

                  const SizedBox(height: 20),
                  const SectionTitle(title: "Portal Activity"),
                  _buildPortalActivityChart(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for the fixed cards
  Widget _buildCategoryCard(BuildContext context, {required String title, required IconData icon, required Color color, required Widget screen}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortalActivityChart() {
    return FutureBuilder<Map<String, int>>(
      future: _getTotalCounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final data = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _legendItem(const Color(0xFF4A90E2), data['Jobs'].toString(), "JOBS FOUND"),
                    _legendItem(const Color(0xFFF5A623), data['Transport'].toString(), "TRIPS AVAILABLE"),
                    _legendItem(const Color(0xFFF05A94), data['Events'].toString(), "EVENTS LIVE"),
                  ],
                ),
              ),
              SizedBox(
                height: 100, width: 100,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(value: 33, color: const Color(0xFF4A90E2), radius: 15, showTitle: false),
                      PieChartSectionData(value: 33, color: const Color(0xFFF5A623), radius: 15, showTitle: false),
                      PieChartSectionData(value: 33, color: const Color(0xFFF05A94), radius: 15, showTitle: false),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _legendItem(Color color, String val, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val.padLeft(2, '0'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

// ================= LIST VIEWS (MODIFIED FOR CLEANER UI) =================
class JobsList extends StatelessWidget {
  const JobsList({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').orderBy('createdAt', descending: true).limit(3).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: JobCard(job: JobModel.fromMap(docs[index].data() as Map<String, dynamic>, docs[index].id)),
          ),
        );
      },
    );
  }
}

class TransportJobsList extends StatelessWidget {
  const TransportJobsList({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('transport_jobs').orderBy('createdAt', descending: true).limit(3).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TransportCard(transport: TransportModel.fromMap(docs[index].data() as Map<String, dynamic>, docs[index].id)),
          ),
        );
      },
    );
  }
}

class EventsList extends StatelessWidget {
  const EventsList({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').orderBy('createdAt', descending: true).limit(3).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: EventCard(event: EventModel.fromMap({...docs[index].data() as Map<String, dynamic>, 'id': docs[index].id})),
          ),
        );
      },
    );
  }
}