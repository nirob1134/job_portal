import 'package:flutter/material.dart';

import '../../../models/transport_model.dart';
import 'application_screen.dart';


class TransportDetailScreen extends StatelessWidget {
  final TransportModel job;
  const TransportDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Job Detail'),
        backgroundColor: const Color(0xFF3CC6C6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${job.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Description: ${job.description}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Route: ${job.route}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Salary: ${job.salary}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ApplicationsScreen(jobId: job.id)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3CC6C6)),
              child: const Text('View Applications'),
            ),
          ],
        ),
      ),
    );
  }
}
