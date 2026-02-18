import 'package:flutter/material.dart';
import 'package:job_portal/screens/home/event_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Add to pubspec.yaml for date formatting
import '../../providers/auth_provider/event_provider.dart';
import '../../models/event_model.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  TextEditingController searchController = TextEditingController();
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Premium Navy Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
            decoration: const BoxDecoration(
              color: Color(0xFF081A2F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchText = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search workshops, seminars...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📅 Event List
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: searchText.isEmpty
                  ? eventProvider.getAllEvents()
                  : eventProvider.searchEvents(searchText),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF081A2F)));
                }

                final events = snapshot.data!;
                if (events.isEmpty) {
                  return const Center(child: Text('No upcoming events found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: events.length,
                  itemBuilder: (context, index) => _eventCard(events[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventCard(EventModel event) {
    // Format date for the UI
    String formattedDate = event.eventDate != null
        ? DateFormat('MMM dd, yyyy').format(event.eventDate)
        : 'TBA';

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
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_)=>EventDetailsScreen(event: event)));
          },
          child: Stack(
            children: [
              // Blue Vertical Accent
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 6, color: const Color(0xFF4A90E2)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // DIU Logo (Vertically Centered)
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

                    // Event Content
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0E2A47),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "By ${event.organizer}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Responsive Badges using Wrap to prevent 17px overflow
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _softChip(Icons.calendar_today_outlined, formattedDate, Colors.orange),
                              _softChip(Icons.location_on_outlined, event.location, Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
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
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}