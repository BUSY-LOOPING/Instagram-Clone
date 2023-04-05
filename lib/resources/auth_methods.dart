// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //sign in user
  Future<String> signInUser(
      {required String email, required String password}) async {
    String res = 'Some error occured';
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      res = 'success';
    } catch (err) {
      res += err.toString();
    }
    return res;
  }

  Future<model.User> getUserDetails({required String uid}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();
    model.User res = model.User.fromQuerySnapshot(snapshot);
    return res;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(
      {required String uid}) {
    return _firebaseFirestore
        .collection('users')
        .doc(uid).snapshots();
  }

  Future<bool> checkUsernameAvailable(String username) async {
    bool res = false;
    try {
      await _firebaseFirestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get()
          .then((value) => res = value.docs.isEmpty);
    } catch (err) {
      res = false;
    }
    return res;
  }

  //sign up user
  Future<String> signUpUser(
      {required String name,
      required String email,
      required String password,
      required String username,
      required Object? file,
      String? phoneNo}) async {
    String res = 'Some error occured';
    try {
      if (!await checkUsernameAvailable(username)) {
        res = 'username-not-available';
        return res;
      }

      AuthCredential authCredential =
          EmailAuthProvider.credential(email: email, password: password);

      User? currentUser = getCurrentUser();
      if (currentUser != null) {
        UserCredential cred =
            await currentUser.linkWithCredential(authCredential);
        currentUser = cred.user;
      } else {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        currentUser = cred.user;
      }
      assert(currentUser != null);

      String? photoUrl;
      if (file != null) {
        photoUrl = await StorageMethods()
            .uploadProfileImageToStorage(currentUser!.uid, file as Uint8List);
      }
      String? token;
      await FirestoreMethods().requestMessagingPermission();
      token = await FirebaseMessaging.instance.getToken();

      await _firebaseFirestore
          .collection('users')
          // .doc(getCurrentUser()!.uid)
          .doc(currentUser!.uid)
          .set({
        //doc(id)
        'name': name,
        'username': username,
        'uid': getCurrentUser()!.uid,
        'email': email,
        'followers': null,
        'following': null,
        'photoUrl': photoUrl,
        'phoneNo': phoneNo,
        'token': token
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<Map<String, Object>> authenticatePhNo(
      {required final String phoneCode_phoneNo,
      required Function otpEntered}) async {
    Map<String, Object> res = {};
    final completer = Completer<bool>();

    await _auth.verifyPhoneNumber(
      // timeout: Duration(seconds: 199),
      phoneNumber: phoneCode_phoneNo,
      verificationCompleted: (_) {},
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
        print(e.toString());
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        res['verificationId'] = verificationId;
        res['resendToken'] = '$resendToken';
        print('verificationId $verificationId');
        completer.complete(true);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('timeout');
        completer.complete(false);
      },
    );
    try {
      await completer.future;
    } catch (e) {
      print(e.toString());
    }
    return res;
  }

  Future<bool> verificationComplete(AuthCredential credential) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.linkWithCredential(credential);
        print("User Successfully Linked");
        return true;
      } catch (e) {
        print("Linking Error : ${e.toString()}");
        return false;
      }
    }
    return false;
  }

  Future<void> verifyOTP(
      {required otp,
      required veritificationID,
      required Function(UserCredential) successCallback}) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: veritificationID, smsCode: otp);

    await _auth
        .signInWithCredential(credential)
        .then((UserCredential value) => successCallback(value));
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> logout() async {
    /// Method to Logout the `FirebaseUser` (`_firebaseUser`)
    try {
      // signout code
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
