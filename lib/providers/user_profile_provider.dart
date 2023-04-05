import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';

import '../models/post.dart';

class UserA{
  final String name;
  String? bio;
  final String username;
  final String uid;
  final String? email;
  final String? photoUrl;
  final String? phoneNo;
  final List? followers;
  final List? following;
  final bool isPrivateProfile;
  final List? followReq;
  final String? token;

  UserA({
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

  
  static UserA fromDocSnapshot(DocumentSnapshot snap) {
    var snapShot = snap.data() as Map<String, dynamic>;

    return UserA(
        name: snapShot['name'],
        username: snapShot['username'],
        uid: snapShot['uid'],
        email: snapShot['email'],
        photoUrl: snapShot['photoUrl'] != null
            ? snapShot['photoUrl'] as String
            : null,
        phoneNo: snapShot['phoneNo'],
        bio: snapShot['bio'],
        followers: snapShot['followers'],
        following: snapShot['following'],
        isPrivateProfile: snapShot['isPrivateProfile'] ?? false,
        followReq: snapShot['followReq'],
        token: snapShot['token']);
  }
}


class UserProfileProvider extends ChangeNotifier {
  UserA? _user;
  List<Post>? _lstPost;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _lstPostStream;

  UserA? get getUser => _user;
  List<Post>? get getLstPost => _lstPost;

  void refreshPostsForUserID(String uid) {
    _lstPost = null;
    notifyListeners();

    _lstPostStream = FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .orderBy('datePublished', descending: true)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      _lstPost = [];
      for (var q in querySnapshot.docs) {
        _lstPost!.add(Post.fromMap(q.data()));
      }
      notifyListeners();
    });
  }

  void refreshUser(String uid) {
    _user = null;
    notifyListeners();

    _userStream = AuthMethods()
        .getUserStream(uid: uid)
        .listen((DocumentSnapshot<Map<String, dynamic>> querySnapshot) {
      _user= UserA.fromDocSnapshot(querySnapshot);
      notifyListeners();
    });
  }

  void disposeUserStream() async {
    _user = null;
    notifyListeners();

    if (_userStream != null) {
      await _userStream!.cancel();
    }
  }

  void disposePostLstStream() async {
    _lstPost = null;
    notifyListeners();

    if (_lstPostStream != null) {
      await _lstPostStream!.cancel();
    }
  }
}
