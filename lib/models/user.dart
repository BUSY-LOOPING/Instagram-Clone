import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  String? bio;
  final String username;
  final String uid;
  final String? email;
  final String? photoUrl;
  final String? phoneNo;
  final List<String>? followers;
  final List<String>? following;
  final bool isPrivateProfile;
  final List<String>? followReq;
  final String? token;

  User({
    required this.name,
    required this.username,
    required this.uid,
    required this.email,
    required this.photoUrl,
    required this.phoneNo,
    required this.followers,
    required this.following,
    required this.bio,
    this.isPrivateProfile = false,
    this.followReq,
    this.token,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "phoneNo": phoneNo,
        "bio": bio,
        "followers": followers,
        "following": following,
        "followReq": followReq,
        "token": token,
      };

  static User fromDocSnapshot(DocumentSnapshot snap) {
    var snapShot = snap.data() as Map<String, dynamic>;

    return User(
        name: snapShot['name'],
        username: snapShot['username'],
        uid: snapShot['uid'],
        email: snapShot['email'],
        photoUrl: snapShot['photoUrl'] != null
            ? snapShot['photoUrl'] as String
            : null,
        phoneNo: snapShot['phoneNo'],
        bio: snapShot['bio'],
        followers: snapShot['followers'] != null ? (snapShot['followers'] as List).map((item) => item as String).toList() : null,
        following: snapShot['following']!= null ? (snapShot['following'] as List).map((item) => item as String).toList() : null,
        isPrivateProfile: snapShot['isPrivateProfile'] ?? false,
        followReq: snapShot['followReq'] != null ? (snapShot['followReq'] as List).map((item) => item as String).toList() : null,
        token: snapShot['token']);
  }

  static User fromQuerySnapshot(QuerySnapshot snap) {
    var snapShot = snap.docs[0].data() as Map<String, dynamic>;
    return User(
        name: snapShot['name'],
        username: snapShot['username'],
        uid: snapShot['uid'],
        email: snapShot['email'],
        photoUrl: snapShot['photoUrl'],
        phoneNo: snapShot['phoneNo'],
        bio: snapShot['bio'],
        followers: snapShot['followers'],
        following: snapShot['following'],
        isPrivateProfile: snapShot['isPrivateProfile'] ?? false,
        followReq: snapShot['followReq'],
        token: snapShot['token']);
  }
}
