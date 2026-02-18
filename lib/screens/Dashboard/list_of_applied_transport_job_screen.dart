import 'package:flutter/material.dart';
import 'package:job_portal/screens/home/transport_job_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider/transport_application_provider.dart';

class ListOfAppliedTransportJobScreen extends StatelessWidget {
  const ListOfAppliedTransportJobScreen({super.key});

  // Modern status color mapping
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'accepted':
        return const Color(0xFF2ECC71); // Material Green
      case 'rejected':
        return const Color(0xFFE74C3C); // Material Red
      default:
        return const Color(0xFFF39C12); // Material Orange (Pending)
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to see applied transport jobs')),
      );
    }

    final transportAppProvider = Provider.of<TransportApplicationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF081A2F),
        title: const Text(
          'Transport Applications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<TransportApplicationWithJob>>(
        stream: transportAppProvider.getUserAppliedTransportJobs(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF081A2F)));
          }

          final appliedJobs = snapshot.data ?? [];
          if (appliedJobs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: appliedJobs.length,
            itemBuilder: (context, index) {
              final item = appliedJobs[index];
              final job = item.job;
              final application = item.application;

              return _buildTransportApplicationCard(context, job, application);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransportApplicationCard(BuildContext context, var job, var application) {
    String postedDate = job.createdAt != null
        ? DateFormat('MMM dd, yyyy').format(job.createdAt)
        : 'N/A';
    String status = application.status ?? 'pending';

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
              // Dynamic Status Accent Bar
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 6, color: _getStatusColor(status)),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Row ---
                    Row(
                      children: [
                        Container(
                          height: 50, width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset('assets/images/diu_logo.jpg', fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title ?? 'Transport Job',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF0E2A47)
                                ),
                              ),
                              const Text(
                                "DIU Transport Dept.",
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),

                    // --- Job Info Chips ---
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _miniInfo(Icons.alt_route_outlined, job.route ?? 'N/A', Colors.blue),
                        _miniInfo(Icons.payments_outlined, "৳${job.salary}", Colors.green),
                        _miniInfo(Icons.calendar_today_outlined, postedDate, Colors.orange),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // --- Resume/Link Preview ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link_rounded, size: 18, color: Color(0xFF4A90E2)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (application.coverLetter != null && application.coverLetter!.isNotEmpty)
                                  ? application.coverLetter!
                                  : "No link attached",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
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

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0E2A47))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No transport applications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Your bus job applications will appear here", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}