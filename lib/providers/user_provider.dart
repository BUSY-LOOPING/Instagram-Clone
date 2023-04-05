import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/auth_methods.dart';

class UserProvider extends ChangeNotifier {
  model.User? _user;
  final AuthMethods _authMethods = AuthMethods();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? userSubscription;

  model.User? get getUser => _user;

  Future<void> refreshUser() async {
    // model.User user = await _authMethods.getUserDetails();
    // _user = user;
    if (_authMethods.getCurrentUser() != null) {
      userSubscription = _authMethods
          .getUserStream(uid: _authMethods.getCurrentUser()!.uid)
          .listen(((DocumentSnapshot<Map<String, dynamic>> querySnapshot) {
        model.User user = model.User.fromDocSnapshot(querySnapshot);
        _user = user;
        notifyListeners();
      }));
    }
    // notifyListeners();
  }

  void cancelSub() async {
    if (userSubscription != null) await userSubscription?.cancel();
  }
}
