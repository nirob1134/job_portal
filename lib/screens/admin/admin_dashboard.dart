import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider/job_provider.dart';
import 'post_job_screen.dart';
import 'job_details_admin.dart';
import 'update_job_screen.dart';

const Color primaryTeal = Color(0xFF3CC6C6);
const Color scaffoldBg = Color(0xFFF5F5F5);

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final currentAdminId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
      ),
      body: StreamBuilder<List<JobModel>>(
        stream: jobProvider.getJobsByAdmin(adminId: currentAdminId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final jobs = snapshot.data!;
          if (jobs.isEmpty) return const Center(child: Text('No jobs posted yet.'));

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
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    if (job.department.isNotEmpty)
                      Text('Department: ${job.department}'),
                    if (job.salary.isNotEmpty) Text('Salary: ${job.salary}'),
                    const SizedBox(height: 4),
                    Text('Deadline: ${job.deadline.toLocal().toString().split(' ')[0]}'),
                    Text('Posted on: ${job.createdAt.toLocal().toString().split(' ')[0]}'),
                    const SizedBox(height: 12),

                    // Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Details
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => JobDetailsAdmin(job: job)),
                            );
                          },
                          child: const Text('Details'),
                        ),
                        const SizedBox(width: 8),

                        // Update
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => UpdateJobScreen(job: job)),
                            );
                          },
                          child: const Text('Update'),
                        ),
                        const SizedBox(width: 8),

                        // Delete
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            bool confirmed = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text('Are you sure you want to delete this job?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed) {
                              await jobProvider.deleteJob(job.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Job deleted successfully')),
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
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const PostJobScreen()));
        },
        backgroundColor: primaryTeal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
