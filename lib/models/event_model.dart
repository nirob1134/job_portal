import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String id;
  String adminId;
  String title;
  String description;
  String location;
  String organizer;
  DateTime eventDate;
  DateTime createdAt;

  EventModel({
    required this.id,
    required this.adminId,
    required this.title,
    required this.description,
    required this.location,
    required this.organizer,
    required this.eventDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'title': title,
      'description': description,
      'location': location,
      'organizer': organizer,
      'eventDate': Timestamp.fromDate(eventDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      adminId: map['adminId'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      organizer: map['organizer'],
      eventDate: (map['eventDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
