import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider/event_provider.dart';
import '../../models/event_model.dart';
import 'post_event.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Posted Events"),
        backgroundColor: primaryTeal,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryTeal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostEvent()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: "Post New Event",
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: context.read<EventProvider>().getAdminEvents(adminId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No events posted yet",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
              return _eventCard(context, e);
            },
          );
        },
      ),
    );
  }

  Widget _eventCard(BuildContext context, EventModel e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event title
          Text(
            e.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Event description
          Text(
            e.description,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
          ),
          const SizedBox(height: 8),

          // Event location & date
          Row(
            children: [
              const Icon(Icons.location_on , size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  e.location,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                e.eventDate.toLocal().toString().split(' ')[0],
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Delete button aligned to the right
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<EventProvider>().deleteEvent(e.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}
