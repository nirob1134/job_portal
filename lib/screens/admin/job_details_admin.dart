import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../utils/route_helper.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class JobDetailsAdmin extends StatelessWidget {
  final JobModel job;

  const JobDetailsAdmin({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(job.title),
        backgroundColor: primaryTeal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Department
              if (job.department.isNotEmpty)
                _infoRow("Department", job.department),

              // Salary
              if (job.salary.isNotEmpty) _infoRow("Salary", job.salary),

              // Deadline
              if (job.deadline != null)
                _infoRow(
                  "Deadline",
                  job.deadline!.toLocal().toString().split(' ')[0],
                ),

              // Posted on
              if (job.createdAt != null)
                _infoRow(
                  "Posted on",
                  job.createdAt!.toLocal().toString().split(' ')[0],
                ),

              const SizedBox(height: 16),

              // Description
              const Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                job.description,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
              ),

              const SizedBox(height: 24),

              // View Applications Button
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RouteHelper.jobApplication,
                      arguments: job.id,
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text(
                    "View Applications",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Small helper widget for info rows
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: "$title: ",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade800,
                  fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
