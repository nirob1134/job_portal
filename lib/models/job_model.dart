import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String description;
  final String department;
  final String salary;
  final DateTime deadline;
  final DateTime createdAt;
  final String adminId;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.salary,
    required this.deadline,
    required this.createdAt,
    required this.adminId,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      department: map['department'] ?? '',
      salary: map['salary'] ?? '',
      deadline: (map['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adminId: map['adminId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'department': department,
      'salary': salary,
      'deadline': deadline,
      'createdAt': createdAt,
      'adminId': adminId,
    };
  }
}
