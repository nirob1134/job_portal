import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/transport_model.dart';
import '../../../providers/auth_provider/transport_provider.dart';
import 'post_transport_screen.dart';
import 'update_transport_screen.dart';
import 'transport_details_screen.dart';

const Color primaryTeal = Color(0xFF3CC6C6);
const Color scaffoldBg = Color(0xFFF5F5F5);

class AdminTransportScreen extends StatelessWidget {
  const AdminTransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final provider = Provider.of<TransportProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'My Transport Jobs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
      ),
      body: StreamBuilder<List<TransportModel>>(
        stream: provider.getAdminTransportJobs(user.uid),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading transport jobs: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final jobs = snapshot.data ?? [];

          // Empty state
          if (jobs.isEmpty) {
            return const Center(
              child: Text('No transport jobs posted yet.'),
            );
          }

          // Jobs list
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
                    // Job Title
                    Text(
                      job.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 6),

                    // Job Description
                    Text(
                      job.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),

                    // Route & Salary
                    if (job.route.isNotEmpty) Text('Route: ${job.route}'),
                    if (job.salary.isNotEmpty) Text('Salary: ${job.salary}'),
                    const SizedBox(height: 4),

                    // Posted date
                    Text(
                        'Posted on: ${job.createdAt.toLocal().toString().split(' ')[0]}'),
                    const SizedBox(height: 12),

                    // Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Details Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      TransportDetailScreen(job: job)),
                            );
                          },
                          child: const Text('Details'),
                        ),
                        const SizedBox(width: 8),

                        // Update Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      UpdateTransportScreen(job: job)),
                            );
                          },
                          child: const Text('Update'),
                        ),
                        const SizedBox(width: 8),

                        // Delete Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            bool confirmed = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                    'Are you sure you want to delete this transport job?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed) {
                              await provider.deleteTransportJob(job.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Transport job deleted successfully')),
                              );
                            }
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryTeal,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostTransportScreen()),
          );
        },
      ),
    );
  }
}
