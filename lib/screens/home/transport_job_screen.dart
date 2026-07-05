import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transport_model.dart';
import '../../providers/auth_provider/transport_provider.dart';
import '../../widget/transport_card.dart';

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
        title: const Text(
          'DIU Transport Careers',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. Blue Header Container (No nested components)
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

          // 2. Search Field moved onto the background canvas
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchText = val),
              style: const TextStyle(color: Color(0xFF081A2F)),
              decoration: InputDecoration(
                hintText: 'Search routes or titles...',
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

          // 3. Main Data Stream
          Expanded(
            child: StreamBuilder<List<TransportModel>>(
              stream: transportProvider.getAllTransportJobs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF081A2F)));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No transport jobs found',
                      style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.w300),
                    ),
                  );
                }

                final jobs = snapshot.data!
                    .where((job) =>
                job.title.toLowerCase().contains(searchText.toLowerCase()) ||
                    job.route.toLowerCase().contains(searchText.toLowerCase()))
                    .toList();

                if (jobs.isEmpty) {
                  return Center(
                    child: Text(
                      'No matching results found',
                      style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.w300),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) => TransportCard(transport: jobs[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}