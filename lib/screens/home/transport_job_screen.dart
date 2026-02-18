import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transport_model.dart';
import '../../providers/auth_provider/transport_provider.dart';
import 'transport_job_details_screen.dart';

class TransportJobScreen extends StatefulWidget {
  const TransportJobScreen({super.key});

  @override
  State<TransportJobScreen> createState() => _TransportJobScreenState();
}

class _TransportJobScreenState extends State<TransportJobScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final transportProvider = Provider.of<TransportProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF081A2F),
        title: const Text('DIU Transport Careers',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Premium Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
            decoration: const BoxDecoration(
              color: Color(0xFF081A2F),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchText = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search routes or titles...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<TransportModel>>(
              stream: transportProvider.getAllTransportJobs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF081A2F)));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No transport jobs found'));
                }

                final jobs = snapshot.data!
                    .where((job) =>
                job.title.toLowerCase().contains(searchText.toLowerCase()) ||
                    job.route.toLowerCase().contains(searchText.toLowerCase()))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) => _transportJobCard(context, jobs[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _transportJobCard(BuildContext context, TransportModel job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF081A2F).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TransportJobDetailsScreen(job: job)),
          ),
          child: Stack(
            children: [
              // Blue Accent Strip
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 6, color: const Color(0xFF4A90E2)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🚍 Centered Logo/Icon
                    Container(
                      height: 54, width: 54,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/images/diu_logo.jpg', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Content
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0E2A47)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Route: ${job.route}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _softChip(Icons.paid_outlined, "৳${job.salary}", Colors.green),
                              _softChip(Icons.directions_bus_outlined, "Transport", Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _softChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}