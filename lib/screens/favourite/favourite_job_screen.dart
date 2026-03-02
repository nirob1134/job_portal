import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider/favourite_provider.dart';
import '../../models/job_model.dart';
import '../home/job_detail_screen.dart';

const Color primaryTeal = Color(0xFF3CC6C6);
const Color scaffoldBg = Color(0xFFF5F5F5);

class FavouriteJobsScreen extends StatelessWidget {
  const FavouriteJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = context.read<FavouriteProvider>();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          "Favourite Jobs",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder(
        stream: favProvider.favouritesStream(), // Stream of favourite jobs
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No favourite jobs yet"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final job = JobModel.fromMap(data, docs[i].id);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row: Avatar + Title + Delete button
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundImage:
                          AssetImage('assets/images/diu_logo.jpg'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => favProvider.toggleFavourite(job),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Job badges: department, salary, etc.
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (job.department.isNotEmpty)
                          _detailBadge(Icons.apartment, Colors.blueAccent,
                              'Department: ${job.department}'),
                        if (job.salary.isNotEmpty)
                          _detailBadge(Icons.attach_money, Colors.green,
                              'Salary: ${job.salary}'),
                        if (job.createdAt != null)
                          _detailBadge(
                            Icons.schedule,
                            Colors.orange,
                            'Job Date: ${job.createdAt.toLocal().toString().split(' ')[0]}',
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Details button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailScreen(job: job),
                          ),
                        ),
                        icon: const Icon(Icons.info_outline),
                        label: const Text("Details"),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Badge widget with overflow fix
  Widget _detailBadge(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: const BoxConstraints(maxWidth: 280), // optional max width
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
