import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/transport_model.dart';
import '../../models/transport_application_model.dart';

class TransportProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= Admin =================

  /// Get all transport jobs posted by a specific admin
  Stream<List<TransportModel>> getAdminTransportJobs(String adminId) {
    return _db
        .collection('transport_jobs')
        .where('adminId', isEqualTo: adminId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransportModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Post a new transport job
  Future<void> postTransportJob(TransportModel transport) async {
    await _db.collection('transport_jobs').add(transport.toMap());
    notifyListeners();
  }

  /// Update an existing transport job
  Future<void> updateTransportJob(TransportModel transport) async {
    await _db.collection('transport_jobs').doc(transport.id).update(transport.toMap());
    notifyListeners();
  }

  /// Delete a transport job
  Future<void> deleteTransportJob(String jobId) async {
    await _db.collection('transport_jobs').doc(jobId).delete();
    notifyListeners();
  }

  /// Get all applications for a specific transport job
  Stream<List<TransportApplicationModel>> getApplications(String jobId) {
    return _db
        .collection('transport_jobs')
        .doc(jobId)
        .collection('applications')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransportApplicationModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Update the status of a transport application (Approve / Reject)
  Future<void> updateApplicationStatus(String jobId, String userId, String status) async {
    await _db
        .collection('transport_jobs')
        .doc(jobId)
        .collection('applications')
        .doc(userId)
        .update({'status': status});
    notifyListeners();
  }

  // ================= Users =================

  /// Get all transport jobs
  Stream<List<TransportModel>> getAllTransportJobs() {
    return _db
        .collection('transport_jobs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransportModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Apply to a transport job
  Future<void> applyTransportJobWithForm(TransportApplicationModel application) async {
    await _db
        .collection('transport_jobs')
        .doc(application.transportJobId)
        .collection('applications')
        .doc(application.userId) // each user can apply only once
        .set(application.toMap());
  }

  /// Get all transport jobs applied by a user (jobId -> status)
  Stream<Map<String, String>> getUserApplicationsWithStatus(String userId) {
    return _db
        .collectionGroup('applications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final Map<String, String> jobsWithStatus = {};
      for (var doc in snapshot.docs) {
        final jobId = doc.reference.parent.parent!.id;
        final status = doc['status'] ?? 'pending';
        jobsWithStatus[jobId] = status;
      }
      return jobsWithStatus;
    });
  }
}
