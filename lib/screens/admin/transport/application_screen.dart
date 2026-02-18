import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider/transport_application_provider.dart';
import '../../../models/transport_application_model.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class ApplicationsScreen extends StatelessWidget {
  final String jobId;
  const ApplicationsScreen({super.key, required this.jobId});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange; // pending
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransportApplicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        backgroundColor: primaryTeal,
      ),
      body: StreamBuilder<List<TransportApplicationModel>>(
        stream: provider.getApplicationsByJob(jobId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No applications yet.'));
          }

          final applications = snapshot.data!;

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: primaryTeal,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              app.userName ?? 'Unknown',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(app.status ?? 'pending'),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (app.status ?? 'pending').toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Email: ${app.userEmail ?? '-'}'),
                      Text('Phone: ${app.userPhone ?? '-'}'),
                      Text('Student ID: ${app.studentId ?? '-'}'),
                      Text('Semester: ${app.runningSemester ?? '-'}'),
                      Text('CGPA: ${app.cgpa ?? '-'}'),
                      Text('Route: ${app.route ?? '-'}'),
                      Text('Resume Link: ${app.coverLetter ?? '-'}'),
                      const SizedBox(height: 8),

                      if ((app.status ?? 'pending') == 'pending')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () async {
                                  await provider.updateApplicationStatus(
                                      jobId, app.userId, 'approved');
                                },
                                child: const Text('Approve'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () async {
                                  await provider.updateApplicationStatus(
                                      jobId, app.userId, 'rejected');
                                },
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
