// lib/models/login_detail.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class LoginDetail {
  final String id;
  final String category;
  final String friendlyName;
  final String website;
  final String username;
  final String loginPassword;
  final String administratorPassword;
  final String authorizerPassword;
  final String profilePassword;
  final String additionalPassword;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const LoginDetail({
    required this.id,
    required this.category,
    required this.friendlyName,
    required this.website,
    required this.username,
    required this.loginPassword,
    required this.administratorPassword,
    required this.authorizerPassword,
    required this.profilePassword,
    required this.additionalPassword,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoginDetail.fromMap(Map<String, dynamic> map) {
    return LoginDetail(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      friendlyName: map['friendlyName'] ?? '',
      website: map['website'] ?? '',
      username: map['username'] ?? '',
      loginPassword: map['loginPassword'] ?? '',
      administratorPassword: map['administratorPassword'] ?? '',
      authorizerPassword: map['authorizerPassword'] ?? '',
      profilePassword: map['profilePassword'] ?? '',
      additionalPassword: map['additionalPassword'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt']
          : (map['createdAt'] != null
          ? Timestamp.fromDate(DateTime.parse(map['createdAt'].toString()))
          : Timestamp.now()),
      updatedAt: map['updatedAt'] is Timestamp
          ? map['updatedAt']
          : (map['updatedAt'] != null
          ? Timestamp.fromDate(DateTime.parse(map['updatedAt'].toString()))
          : Timestamp.now()),
    );
  }

  Map<String, dynamic> toMapForCreate() {
    final now = Timestamp.fromDate(DateTime.now());
    return {
      'category': category,
      'friendlyName': friendlyName,
      'website': website,
      'username': username,
      'loginPassword': loginPassword,
      'administratorPassword': administratorPassword,
      'authorizerPassword': authorizerPassword,
      'profilePassword': profilePassword,
      'additionalPassword': additionalPassword,
      'createdAt': now,
      'updatedAt': now,
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    return {
      'category': category,
      'friendlyName': friendlyName,
      'website': website,
      'username': username,
      'loginPassword': loginPassword,
      'administratorPassword': administratorPassword,
      'authorizerPassword': authorizerPassword,
      'profilePassword': profilePassword,
      'additionalPassword': additionalPassword,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }
}
