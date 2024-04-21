// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String uid;
  final GeoPoint? location;

  UserModel({
    required this.email,
    required this.uid,
    required this.location,
  });

  UserModel copyWith({
    String? email,
    String? uid,
  }) {
    return UserModel(
      email: email ?? this.email,
      uid: uid ?? this.uid,
      location: location,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'uid': uid,
      'location': location,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      uid: map['uid'] as String,
      location: map['location'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'UserModel(email: $email, uid: $uid, location: $location)';

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.email == email &&
        other.uid == uid &&
        other.location == location;
  }

  @override
  int get hashCode => email.hashCode ^ uid.hashCode ^ location.hashCode;
}
