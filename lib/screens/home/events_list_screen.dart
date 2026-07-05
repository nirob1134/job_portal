import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider/event_provider.dart';
import '../../models/event_model.dart';
import '../../widget/event_card.dart'; // Using global shared card for uniform UI design

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF081A2F),
        title: const Text(
          'Campus Events',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. Clean Blue Header Block (Search bar extracted)
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

          // 2. Uniform Search Field placed onto the canvas background
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchText = val),
              style: const TextStyle(color: Color(0xFF081A2F)),
              decoration: InputDecoration(
                hintText: 'Search workshops, seminars...',
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

          // 3. Dynamic Events Grid/List Stream
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: searchText.isEmpty
                  ? eventProvider.getAllEvents()
                  : eventProvider.searchEvents(searchText),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF081A2F)));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No upcoming events found',
                      style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.w300),
                    ),
                  );
                }

                final events = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) => EventCard(event: events[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}