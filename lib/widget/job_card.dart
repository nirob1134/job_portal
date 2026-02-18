import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job_model.dart';
import '../screens/home/job_detail_screen.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Logic for the Urgent badge (less than 3 days left)
    bool isUrgent = job.deadline.isBefore(DateTime.now().add(const Duration(days: 3)));
    String formattedDeadline = DateFormat('MMM dd, yyyy').format(job.deadline);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF081A2F).withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
            );
          },
          splashColor: const Color(0xFF4A90E2).withOpacity(0.1),
          child: Stack(
            children: [
              // 1. Blue Side Accent
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 5, color: const Color(0xFF4A90E2)),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // Vertically center the logo
                  children: [
                    // 2. DIU Logo
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/diu_logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // 3. Main Content
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  job.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF0E2A47),
                                  ),
                                ),
                              ),
                              if (isUrgent) _urgentBadge(),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.department,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 4. Info Chips (Salary & Deadline)
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _miniChip(Icons.paid_outlined, "৳${job.salary}", Colors.green),
                              _miniChip(Icons.event_outlined, formattedDeadline, Colors.orange),
                            ],
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

  // Urgent Badge Widget
  Widget _urgentBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: const Text(
        "URGENT",
        style: TextStyle(
          color: Colors.red,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Mini Chip Helper
  Widget _miniChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}