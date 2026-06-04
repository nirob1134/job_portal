import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/job_model.dart';
import '../../providers/auth_provider/job_provider.dart';
import 'job_details_admin.dart';
import 'post_job_screen.dart';
import 'update_job_screen.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final currentAdminId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryTeal,
        elevation: 6,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PostJobScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: StreamBuilder<List<JobModel>>(
              stream: jobProvider.getJobsByAdmin(
                adminId: currentAdminId,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final jobs = snapshot.data!;

                if (jobs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No jobs posted yet",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];

                    return _jobCard(
                      context,
                      job,
                      jobProvider,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        55,
        20,
        30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF081A2F),
            Color(0xFF0E2A47),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.work,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Portal",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage Posted Jobs",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(
      BuildContext context,
      JobModel job,
      JobProvider jobProvider,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.06,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                primaryTeal.withOpacity(
                  0.15,
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: primaryTeal,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  job.title,
                  style:
                  const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xFF081A2F),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            job.description,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color:
              Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (job.department
                  .isNotEmpty)
                _chip(
                  Icons.apartment,
                  job.department,
                  const Color(
                    0xFF4A90E2,
                  ),
                ),

              if (job.salary
                  .isNotEmpty)
                _chip(
                  Icons.payments,
                  job.salary,
                  Colors.green,
                ),

              _chip(
                Icons.calendar_month,
                job.deadline
                    .toLocal()
                    .toString()
                    .split(' ')[0],
                Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _button(
                  "Details",
                  primaryTeal,
                  Icons.visibility,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            JobDetailsAdmin(
                              job: job,
                            ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _button(
                  "Update",
                  Colors.orange,
                  Icons.edit,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            UpdateJobScreen(
                              job: job,
                            ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _button(
                  "Delete",
                  Colors.red,
                  Icons.delete,
                      () async {
                    final confirm =
                    await showDialog<bool>(
                      context: context,
                      builder:
                          (context) =>
                          AlertDialog(
                            title:
                            const Text(
                              "Delete Job",
                            ),
                            content:
                            const Text(
                              "Are you sure?",
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () {
                                  Navigator.pop(
                                    context,
                                    false,
                                  );
                                },
                                child:
                                const Text(
                                  "Cancel",
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    () {
                                  Navigator.pop(
                                    context,
                                    true,
                                  );
                                },
                                child:
                                const Text(
                                  "Delete",
                                  style:
                                  TextStyle(
                                    color:
                                    Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirm ==
                        true) {
                      await jobProvider
                          .deleteJob(
                        job.id,
                      );

                      if (context
                          .mounted) {
                        ScaffoldMessenger.of(
                            context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Job deleted successfully",
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(
      IconData icon,
      String text,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
        color.withOpacity(0.12),
        borderRadius:
        BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight:
              FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(
      String title,
      Color color,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(title),
      style:
      ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor:
        Colors.white,
        elevation: 0,
        padding:
        const EdgeInsets.symmetric(
          vertical: 12,
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
      ),
    );
  }
}