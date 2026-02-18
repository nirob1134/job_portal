import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  String uid;
  String name;
  String phone;
  String email;
  String role;
  DateTime createdAt;

  UserModel(
      this.uid,
      this.name,
      this.phone,
      this.email,
      this.role,
      this.createdAt,
      );

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      map['uid'],
      map['name'],
      map['phone'],
      map['email'],
      map['role'],
      (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
