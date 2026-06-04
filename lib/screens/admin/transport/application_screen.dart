import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider/transport_application_provider.dart';
import '../../../models/transport_application_model.dart';

const Color primaryTeal = Color(0xFF3CC6C6);
const Color darkNavy = Color(0xFF081A2F);
const Color navy = Color(0xFF0E2A47);
const Color bgColor = Color(0xFFF8F9FB);

class ApplicationsScreen extends StatelessWidget {
  final String jobId;

  const ApplicationsScreen({
    super.key,
    required this.jobId,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransportApplicationProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<List<TransportApplicationModel>>(
              stream: provider.getApplicationsByJob(jobId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final applications = snapshot.data ?? [];

                if (applications.isEmpty) {
                  return const Center(
                    child: Text(
                      "No applications yet",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    return _applicationCard(context, app, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 20, 30),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Transport Applications",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage Applicants",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.people_alt_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _applicationCard(
      BuildContext context,
      TransportApplicationModel app,
      TransportApplicationProvider provider,
      ) {
    final status = app.status ?? "pending";
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryTeal.withOpacity(0.15),
                child: const Icon(Icons.person, color: primaryTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  app.userName ?? "Unknown Applicant",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkNavy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _statusChip(status, statusColor),
            ],
          ),
          const SizedBox(height: 14),
          _info(Icons.email_outlined, "Email", app.userEmail ?? "-"),
          _info(Icons.phone, "Phone", app.userPhone ?? "-"),
          _info(Icons.badge_outlined, "Student ID", app.studentId ?? "-"),
          _info(Icons.school_outlined, "Semester", app.runningSemester ?? "-"),
          _info(Icons.grade_outlined, "CGPA", app.cgpa ?? "-"),
          _info(Icons.route, "Route", app.route ?? "-"),
          _info(Icons.description_outlined, "Resume", app.coverLetter ?? "-"),
          const SizedBox(height: 14),
          if (status.toLowerCase() == "pending")
            Row(
              children: [
                Expanded(
                  child: _button(
                    "Approve",
                    Colors.green,
                    Icons.check,
                        () async {
                      await provider.updateApplicationStatus(
                        jobId,
                        app.userId,
                        "approved",
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _button(
                    "Reject",
                    Colors.red,
                    Icons.close,
                        () async {
                      await provider.updateApplicationStatus(
                        jobId,
                        app.userId,
                        "rejected",
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: primaryTeal),
          const SizedBox(width: 8),
          SizedBox(
            width: 85,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _button(String title, Color color, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}