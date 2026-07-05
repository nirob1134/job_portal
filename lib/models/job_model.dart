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

  // New Fields Added
  final String workType;       // e.g., "Part-Time", "Full-Time", "Internship"
  final List<String> requirements; // List of required skills/qualifications
  final String status;         // e.g., "active", "closed"
  final int vacancy;           // Number of openings

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.salary,
    required this.deadline,
    required this.createdAt,
    required this.adminId,
    required this.workType,
    required this.requirements,
    required this.status,
    required this.vacancy,
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

      // Parsing the new fields safely
      workType: map['workType'] ?? 'Part-Time',
      requirements: List<String>.from(map['requirements'] ?? []),
      status: map['status'] ?? 'active',
      vacancy: map['vacancy'] ?? 1,
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

      // Mapping the new fields for Firestore
      'workType': workType,
      'requirements': requirements,
      'status': status,
      'vacancy': vacancy,
    };
  }
}