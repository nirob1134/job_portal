import 'package:flutter/material.dart';

import '../../models/job_model.dart';
import '../../utils/route_helper.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class JobDetailsAdmin extends StatelessWidget {
  final JobModel job;

  const JobDetailsAdmin({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _detailsCard(context),
                ],
              ),
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
      child: Row(
        children: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.14),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Job Details",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  job.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.14),
            child: const Icon(
              Icons.work_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
                radius: 26,
                backgroundColor: primaryTeal.withOpacity(0.15),
                child: const Icon(
                  Icons.business_center,
                  color: primaryTeal,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF081A2F),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Updated Chip wrap metadata structure
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (job.department.isNotEmpty)
                _chip(
                  Icons.apartment,
                  job.department,
                  const Color(0xFF4A90E2),
                ),

              if (job.workType.isNotEmpty)
                _chip(
                  Icons.schedule,
                  job.workType,
                  const Color(0xFFE24A8A),
                ),

              if (job.salary.isNotEmpty)
                _chip(
                  Icons.payments,
                  job.salary,
                  Colors.green,
                ),

              _chip(
                Icons.groups_outlined,
                "${job.vacancy} Vacancies",
                Colors.blueGrey,
              ),

              _chip(
                Icons.toggle_on_outlined,
                job.status.toUpperCase(),
                job.status == "active" ? Colors.teal : Colors.red,
              ),

              _chip(
                Icons.calendar_month,
                job.deadline.toLocal().toString().split(' ')[0],
                Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            "Job Description",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF081A2F),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            job.description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
              height: 1.6,
            ),
          ),

          // Dynamically displays Requirements array list if populated
          if (job.requirements.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              "Requirements",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF081A2F),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: job.requirements.map((req) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: primaryTeal,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          req,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RouteHelper.jobApplication,
                  arguments: job.id,
                );
              },
              icon: const Icon(Icons.people_outline),
              label: const Text(
                "View Applications",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}