import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/job_model.dart';

class FavouriteProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> favouritesStream() {
    return _db
        .collection('favourites')
        .doc(_uid)
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<bool> isFavourite(String jobId) {
    return _db
        .collection('favourites')
        .doc(_uid)
        .collection('jobs')
        .doc(jobId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> toggleFavourite(JobModel job) async {
    final ref = _db
        .collection('favourites')
        .doc(_uid)
        .collection('jobs')
        .doc(job.id);

    final snap = await ref.get();

    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'jobId': job.id,
        'title': job.title,
        'department': job.department,
        'salary': job.salary,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    notifyListeners();
  }
}
