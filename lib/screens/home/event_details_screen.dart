import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Formatting your Firebase timestamps
    String formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(event.eventDate);
    String formattedTime = DateFormat('hh:mm a').format(event.eventDate);
    String postedDate = DateFormat('MMM dd').format(event.createdAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF081A2F)),
        title: const Text(
          "Event Details",
          style: TextStyle(color: Color(0xFF081A2F), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION ---
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade100, width: 2),
                    ),
                    child: Image.asset(
                      'assets/images/diu_logo.jpg',
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      event.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0E2A47)
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Organizer Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "By ${event.organizer}",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- INFO GRID (Date, Time, Location) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      _infoCard(Icons.calendar_today_outlined, "Date", formattedDate),
                      const SizedBox(width: 12),
                      _infoCard(Icons.access_time, "Time", formattedTime),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoCard(Icons.location_on_outlined, "Venue", event.location, isFullWidth: true),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- DESCRIPTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About Event",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E2A47)
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      event.description,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.7
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Posted on $postedDate",
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),


    );
  }

  // Helper Widget for Information Cards
  Widget _infoCard(IconData icon, String label, String value, {bool isFullWidth = false}) {
    Widget card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A90E2), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E2A47)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return isFullWidth ? card : Expanded(child: card);
  }
}