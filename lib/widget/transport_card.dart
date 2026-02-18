import 'package:flutter/material.dart';
import '../models/transport_model.dart';
import '../screens/home/transport_job_details_screen.dart';

class TransportCard extends StatelessWidget {
  final TransportModel transport;
  const TransportCard({super.key, required this.transport});

  @override
  Widget build(BuildContext context) {
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
              MaterialPageRoute(
                builder: (_) => TransportJobDetailsScreen(job: transport),
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.center, // Centers logo vertically
                  children: [
                    // 2. DIU Logo with Border
                    Container(
                      height: 54,
                      width: 54,
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

                    // 3. Main Content Section
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transport.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0E2A47),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "DIU Transport Department",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 4. Quick Badges (Route & Salary)
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _miniChip(Icons.alt_route_outlined, transport.route, Colors.blue),
                              _miniChip(Icons.paid_outlined, "৳${transport.salary}", Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Small Arrow indicator
                    const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey
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

  // Mini Chip Helper for consistency
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
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }
}