import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/application_model.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class JobApplicationsScreen extends StatelessWidget {
  final String jobId;

  const JobApplicationsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Job Applications'),
        backgroundColor: primaryTeal,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('jobId', isEqualTo: jobId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No applications yet',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final applications = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ApplicationModel.fromMap(data, doc.id);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              return _applicationCard(app);
            },
          );
        },
      ),
    );
  }

  Widget _applicationCard(ApplicationModel app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Applicant Name
          Text(
            app.userName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          // Basic info rows
          _infoRow("Email", app.userEmail),
          _infoRow("Phone", app.userPhone),
          _infoRow("Student ID", app.studentId),
          _infoRow("Semester", app.runningSemester),
          _infoRow("CGPA", app.cgpa),

          const SizedBox(height: 8),

          // Cover Letter
          const Text(
            "Cover Letter",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            app.coverLetter,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => updateStatus(app.id, 'accepted'),
                icon: const Icon(Icons.check),
                label: const Text("Accept",style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => updateStatus(app.id, 'rejected'),
                icon: const Icon(Icons.close),
                label: const Text("Reject",style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Status
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(app.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                app.status.isNotEmpty ? app.status.toUpperCase() : 'PENDING',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for basic info rows
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: "$title: ",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Status color helper
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Update Firestore status
  void updateStatus(String docId, String status) {
    FirebaseFirestore.instance
        .collection('applications')
        .doc(docId)
        .update({'status': status}).catchError((error) {
      debugPrint('Failed to update status: $error');
    });
  }
}
