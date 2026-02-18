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
    DateTime created;
    if (map['createdAt'] is String) {
      created = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else if (map['createdAt'] is Timestamp) {
      created = (map['createdAt'] as Timestamp).toDate();
    } else {
      created = DateTime.now();
    }

    return UserModel(
      map['uid'] ?? map['id'] ?? "unknown",
      map['name'] ?? "Student",
      map['phone'] ?? "Not Set",
      map['email'] ?? "Not Set",
      map['role'] ?? "User",
      created,
    );
  }

}
