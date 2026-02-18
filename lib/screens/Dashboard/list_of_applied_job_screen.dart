import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/job_model.dart';
import '../../models/application_model.dart';
import '../../providers/auth_provider/job_provider.dart';
import '../../providers/auth_provider/application_provider.dart';
import '../home/job_detail_screen.dart';

class ListOfAppliedJobScreen extends StatelessWidget {
  const ListOfAppliedJobScreen({super.key});

  // Modern status color mapping
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF2ECC71); // Material Green
      case 'rejected':
        return const Color(0xFFE74C3C); // Material Red
      default:
        return const Color(0xFFF39C12); // Material Orange
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to see applied jobs')),
      );
    }

    final applicationProvider = Provider.of<ApplicationProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF081A2F),
        title: const Text(
          'Application History',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: applicationProvider.getApplicationsByUser(currentUser.uid),
        builder: (context, appSnapshot) {
          if (appSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF081A2F)));
          }

          final applications = appSnapshot.data ?? [];
          if (applications.isEmpty) {
            return _buildEmptyState();
          }

          return StreamBuilder<List<JobModel>>(
            stream: jobProvider.getJobs(),
            builder: (context, jobSnapshot) {
              final jobs = jobSnapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  // Find job details or use fallback
                  final job = jobs.firstWhere(
                        (j) => j.id == app.jobId,
                    orElse: () => JobModel(
                      id: app.jobId,
                      title: app.jobTitle,
                      description: 'Details no longer available',
                      department: 'General',
                      salary: 'N/A',
                      deadline: DateTime.now(),
                      createdAt: DateTime.now(),
                      adminId: '',
                    ),
                  );

                  return _buildApplicationCard(context, app, job);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, ApplicationModel app, JobModel job) {
    String formattedDeadline = DateFormat('MMM dd, yyyy').format(job.deadline);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF081A2F).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
          ),
          child: Stack(
            children: [
              // Vertical Accent Bar
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 6, color: _getStatusColor(app.status)),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Row ---
                    Row(
                      children: [
                        Container(
                          height: 50, width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset('assets/images/diu_logo.jpg', fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF0E2A47)
                                ),
                              ),
                              Text(
                                job.department,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        // Status Badge
                        _buildStatusBadge(app.status),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),

                    // --- Application Info ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _miniInfo(Icons.payments_outlined, "৳${job.salary}", Colors.green),
                        _miniInfo(Icons.event_available_outlined, "Deadline: $formattedDeadline", Colors.orange),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // --- Resume/Cover Letter Preview ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined, size: 18, color: Color(0xFF4A90E2)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              app.coverLetter.isNotEmpty ? app.coverLetter : "No resume link attached",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0E2A47))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No applications yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Applied jobs will appear here", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}