import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure intl is in your pubspec.yaml
import '../../../models/transport_model.dart';
import 'apply_transport_screen.dart';

class TransportJobDetailsScreen extends StatelessWidget {
  final TransportModel job;

  const TransportJobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Format the createdAt timestamp
    String postedDate = DateFormat('MMM dd, yyyy').format(job.createdAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF081A2F)),
        title: const Text(
          "Transport Details",
          style: TextStyle(color: Color(0xFF081A2F), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION ---
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                    ),
                    child: Image.asset(
                      'assets/images/diu_logo.jpg',
                      height: 80,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.directions_bus, size: 80, color: Color(0xFF4A90E2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0E2A47)
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "DIU Transport Department",
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- QUICK INFO GRID (Route & Salary) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _infoCard(Icons.route_outlined, "Route", job.route),
                  const SizedBox(width: 16),
                  _infoCard(Icons.payments_outlined, "Salary", "৳${job.salary}"),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- DESCRIPTION SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Job Description",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E2A47)
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      job.description,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.7
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Posted Date from createdAt
                  Text(
                    "Posted on: $postedDate",
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120), // Padding for the bottom button
          ],
        ),
      ),

      // --- STICKY APPLY BUTTON ---
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5)
            )
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E2A47),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApplyTransportScreen(
                    jobId: job.id,
                    jobTitle: job.title,
                    route: job.route,
                    // Passing adminId can be helpful for the application logic
                  ),
                ),
              );
            },
            child: const Text(
              "Apply For This Job",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget for Info Boxes
  Widget _infoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4A90E2), size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E2A47)
              ),
            ),
          ],
        ),
      ),
    );
  }
}