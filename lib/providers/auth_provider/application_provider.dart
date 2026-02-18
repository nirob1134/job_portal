import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/application_model.dart';
import '../../models/user_model.dart';

class ApplicationProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  // Get applications by jobId
  Stream<List<ApplicationModel>> getApplicationsByJob(String jobId) {
    return db
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return ApplicationModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  // ✅ New: Get all applications of a user
  Stream<List<ApplicationModel>> getApplicationsByUser(String userId) {
    return db
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return ApplicationModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  // Apply for a job
  Future<void> applyJob(ApplicationModel app) async {
    await db.collection('applications').add(app.toMap());
  }

  // Update application status
  Future<void> updateStatus(String id, String status) async {
    await db.collection('applications').doc(id).update({'status': status});
  }

  // Fetch user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await db.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return UserModel(
      data['id'] ?? '',
      data['name'] ?? '',
      data['phone'] ?? '',
      data['email'] ?? '',
      data['role'] ?? '',
      DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
