import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider/job_provider.dart';
import '../../providers/auth_provider/favourite_provider.dart';
import '../home/job_detail_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF081A2F),
        title: const Text(
          'DIU Career Portal',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. Clean Blue Header Block
          Container(
            width: double.infinity,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFF081A2F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),

          // 2. Extracted Uniform Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchText = val),
              style: const TextStyle(color: Color(0xFF081A2F)),
              decoration: InputDecoration(
                hintText: 'Search roles, skills, or dept...',
                hintStyle: TextStyle(color: const Color(0xFF081A2F).withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
                ),
              ),
            ),
          ),

          // 3. Main Data Stream List
          Expanded(
            child: StreamBuilder<List<JobModel>>(
              stream: searchText.isEmpty
                  ? jobProvider.getJobs()
                  : jobProvider.searchJobs(searchText),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF081A2F)));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No open career choices found',
                      style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.w300),
                    ),
                  );
                }

                final jobs = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) => _modernJobCard(context, jobs[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernJobCard(BuildContext context, JobModel job) {
    return Consumer<FavouriteProvider>(
      builder: (context, favProvider, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10, left: 2, right: 2), // Tight architectural spacing
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
              ),
              splashColor: const Color(0xFF081A2F).withOpacity(0.05),
              child: Stack(
                children: [
                  Positioned(
                    left: 0, top: 0, bottom: 0,
                    child: Container(width: 4, color: const Color(0xFF4A90E2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/diu_logo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF081A2F),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                job.department,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _softChip(Icons.paid_outlined, "৳${job.salary}", const Color(0xFF10B981)),
                                  _softChip(Icons.timer_outlined, "Full-time", const Color(0xFF4A90E2)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        StreamBuilder<bool>(
                          stream: favProvider.isFavourite(job.id),
                          builder: (context, snapshot) {
                            final isFav = snapshot.data ?? false;
                            return IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isFav ? Icons.bookmark : Icons.bookmark_border_rounded,
                                color: isFav ? const Color(0xFF4A90E2) : const Color(0xFF94A3B8),
                                size: 22,
                              ),
                              onPressed: () => favProvider.toggleFavourite(job),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _softChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}