import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/transport_application_model.dart';
import '../../models/transport_model.dart';
import 'transport_provider.dart';

class TransportApplicationProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TransportProvider transportProvider;

  TransportApplicationProvider({required this.transportProvider});

  /// Fetch all applications of the current user along with job details
  Stream<List<TransportApplicationWithJob>> getUserAppliedTransportJobs(String userId) {
    // Get all transport jobs
    return _db.collection('transport_jobs').snapshots().asyncMap((jobsSnapshot) async {
      List<TransportApplicationWithJob> appliedList = [];

      for (var jobDoc in jobsSnapshot.docs) {
        final job = TransportModel.fromMap(jobDoc.data(), jobDoc.id);

        // Check if current user has applied for this job
        final appDoc = await jobDoc.reference.collection('applications').doc(userId).get();
        if (!appDoc.exists) continue;

        final application = TransportApplicationModel.fromMap(appDoc.data()!, appDoc.id);
        appliedList.add(TransportApplicationWithJob(job: job, application: application));
      }

      return appliedList;
    });
  }

  /// Fetch all applications for a specific job (Admin view)
  Stream<List<TransportApplicationModel>> getApplicationsByJob(String jobId) {
    return _db
        .collection('transport_jobs')
        .doc(jobId)
        .collection('applications')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransportApplicationModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Apply for a transport job
  Future<void> applyTransportJob(TransportApplicationModel application) async {
    await _db
        .collection('transport_jobs')
        .doc(application.transportJobId)
        .collection('applications')
        .doc(application.userId) // one application per user
        .set(application.toMap());
  }

  /// Update the status of a transport application
  Future<void> updateApplicationStatus(
      String transportJobId, String userId, String status) async {
    await _db
        .collection('transport_jobs')
        .doc(transportJobId)
        .collection('applications')
        .doc(userId)
        .update({'status': status});
    notifyListeners();
  }
}

/// Helper class to combine job + user's application
class TransportApplicationWithJob {
  final TransportModel job;
  final TransportApplicationModel application;

  TransportApplicationWithJob({required this.job, required this.application});
}
