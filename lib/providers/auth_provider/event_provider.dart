import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';

class EventProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // POST EVENT
  Future<void> postEvent(EventModel event) async {
    final doc = _db.collection('events').doc();
    event.id = doc.id;
    await doc.set(event.toMap());
  }

  // ADMIN EVENTS (REAL TIME)
  Stream<List<EventModel>> getAdminEvents(String adminId) {
    return _db
        .collection('events')
        .where('adminId', isEqualTo: adminId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventModel.fromMap(doc.data()))
        .toList());
  }

  // USER EVENTS (REAL TIME)
  Stream<List<EventModel>> getAllEvents() {
    return _db.collection('events').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList(),
    );
  }

  // DELETE EVENT
  Future<void> deleteEvent(String id) async {
    await _db.collection('events').doc(id).delete();
  }

  Stream<List<EventModel>> searchEvents(String keyword) {
    return getAllEvents().map((events) {
      return events.where((e) {
        final lowerKeyword = keyword.toLowerCase();
        return e.title.toLowerCase().contains(lowerKeyword) ||
            e.description.toLowerCase().contains(lowerKeyword) ||
            e.location.toLowerCase().contains(lowerKeyword);
      }).toList();
    });
  }
}
