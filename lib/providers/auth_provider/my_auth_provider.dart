import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/user_model.dart';
import '../../utils/route_helper.dart';
import '../../utils/showMessage.dart';
import '../../utils/roles.dart';

class MyAuthProvider with ChangeNotifier {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  bool loading = false;
  String? userRole; // cached role

  void _loading(bool value){
    loading = value;
    notifyListeners();
  }


  Future<void> registration(
      String name,
      String email,
      String password,
      String phone,
      ) async {

    if (!email.trim().toLowerCase().endsWith('@diu.edu.bd')) {
      showMsg('Only DIU student email addresses are allowed.');
      return;
    }

    _loading(true);

    try {

      final result = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      UserModel user = UserModel(
        result.user!.uid,
        name,
        phone,
        email,
        Roles.student,
        DateTime.now(),
      );

      await db.collection('users')
          .doc(result.user!.uid)
          .set(user.toMap());

      Navigator.pushNamedAndRemoveUntil(
        navigatorKey.currentContext!,
        RouteHelper.roleGate,
            (value) => false,
      );

    } on FirebaseAuthException catch(e){
      showMsg(e.message ?? "Registration failed");
    } catch(e){
      showMsg(e.toString());
    } finally{
      _loading(false);
    }
  }


  Future<void> login(String email,String password) async {

    _loading(true);

    try {

      final result = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );


      await loadUserRole(result.user!.uid);

      Navigator.pushNamedAndRemoveUntil(
        navigatorKey.currentContext!,
        RouteHelper.roleGate,
            (value) => false,
      );

    } on FirebaseAuthException catch(e){
      showMsg(e.message ?? "Login failed");
    } catch(e){
      showMsg(e.toString());
    } finally{
      _loading(false);
    }
  }


  Future<void> loadUserRole(String uid) async {

    final snap = await db.collection('users').doc(uid).get();

    if (!snap.exists) {
      showMsg("User data not found");
      return;
    }

    final data = snap.data() as Map<String, dynamic>;

    userRole = data['role'];

    notifyListeners();
  }


  Future<void> forgotPassword(String email) async {
    _loading(true);

    try {
      await auth.sendPasswordResetEmail(
        email: email.trim(),
      );
      print("Reset email sent");

      showMsg(
        "Password reset link has been sent to your email.",
      );
    } on FirebaseAuthException catch (e) {
      showMsg(e.message ?? "Failed to send reset email");
    } catch (e) {
      showMsg(e.toString());
    } finally {
      _loading(false);
    }
  }


  Future<void> logout() async {

    try {

      await auth.signOut();

      Navigator.pushNamedAndRemoveUntil(
        navigatorKey.currentContext!,
        RouteHelper.login,
            (value)=>false,
      );

    } catch(e){
      showMsg(e.toString());
    }
  }

  // ================= UPDATE EXTRA DETAILS =================
  Future<void> updateAdditionalDetails({
    required String studentId,
    required String department,
    required String address,
  }) async {

    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    _loading(true);

    try {

      await db.collection('user_details').doc(uid).set({
        'studentId': studentId,
        'department': department,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      showMsg("Profile Details Updated!");

    } catch (e) {
      showMsg("Error: ${e.toString()}");
    } finally {
      _loading(false);
    }
  }
}
