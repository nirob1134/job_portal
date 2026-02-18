import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/job_model.dart';

class JobProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  // ========== USER ==========
  Stream<List<JobModel>> getJobs() {
    return db.collection('jobs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return JobModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  Stream<List<JobModel>> searchJobs(String query) {
    return db.collection('jobs').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return JobModel.fromMap(data, doc.id);
      })
          .where((job) => job.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // ========== ADMIN ==========
  Stream<List<JobModel>> getJobsByAdmin({required String adminId}) {
    return db
        .collection('jobs')
        .where('adminId', isEqualTo: adminId)
        .snapshots()
        .map((snapshot) {
      final jobs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return JobModel.fromMap(data, doc.id);
      }).toList();

      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }

  Stream<List<JobModel>> searchJobsByAdmin({required String adminId, required String query}) {
    return db
        .collection('jobs')
        .where('adminId', isEqualTo: adminId)
        .snapshots()
        .map((snapshot) {
      final jobs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return JobModel.fromMap(data, doc.id);
      }).where((job) => job.title.toLowerCase().contains(query.toLowerCase())).toList();

      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }

  // ========== COMMON ==========
  Future<void> postJob(JobModel job) async {
    final currentAdminId = FirebaseAuth.instance.currentUser!.uid;
    await db.collection('jobs').add({
      ...job.toMap(),
      'adminId': currentAdminId,
    });
  }

  // ========== DELETE JOB ==========
  Future<void> deleteJob(String jobId) async {
    await db.collection('jobs').doc(jobId).delete();
  }

  // ========== UPDATE JOB ==========
  Future<void> updateJob(String jobId, Map<String, dynamic> updatedData) async {
    await db.collection('jobs').doc(jobId).update(updatedData);
  }
}
