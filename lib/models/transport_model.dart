import 'package:cloud_firestore/cloud_firestore.dart';

class TransportModel {
  final String id;
  final String title;
  final String description;
  final String route;
  final String salary;
  final DateTime createdAt;
  final String adminId;

  TransportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.route,
    required this.salary,
    required this.createdAt,
    required this.adminId,
  });

  factory TransportModel.fromMap(Map<String, dynamic> map, String id) {
    return TransportModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      route: map['route'] ?? '',
      salary: map['salary'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adminId: map['adminId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'route': route,
      'salary': salary,
      'createdAt': createdAt,
      'adminId': adminId,
    };
  }
}
