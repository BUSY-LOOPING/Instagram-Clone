import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/notification.dart';
import 'package:instagram_clone/private_keys.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

import '../models/post.dart';
import '../models/user.dart';

import 'package:http/http.dart' as http;

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String> uploadPost(
      {required User user,
      required List<Uint8List> files,
      required String? caption,
      bool fitCover = true}) async {
    String res = 'some error occured';
    try {
      String postId = const Uuid().v1();
      List<String> listUrls =
          await StorageMethods().uploadPostToStorage(user.uid, files);

      Map<String, dynamic> map = {};
      for (int i = 0; i < listUrls.length; i++) {
        map[i.toString()] = listUrls[i];
      }

      Post post = Post(
          postId: postId,
          caption: caption,
          profImage: user.photoUrl,
          uid: user.uid,
          username: user.username,
          datePublished: DateTime.now().toString(),
          mapIdPost: map,
          likes: [],
          fitCover: fitCover,
          noComments: 0);

      await _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );
      print('ok here\n\n\n');
      res = 'success';
    } catch (err) {
      print('err = $err');
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(
      {required String postId,
      required String? uid,
      required List likes}) async {
    try {
      await Future.doWhile(() => uid == null);
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (err) {
      print('likePost err = ${err.toString()}');
    }
  }

  Future<void> commentPost(
      {required String content,
      required String username,
      required String uid,
      required String postId,
      String? profImage}) async {
    try {
      String commentId = Uuid().v1();
      Comment comment = Comment(
          commentId: commentId,
          content: content,
          username: username,
          uid: uid,
          datePublished: DateTime.now().toString(),
          likes: [],
          profImage: profImage);

      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(comment.commentId)
          .set(comment.toMap())
          .then(
            (value) => _firestore.collection('posts').doc(postId).update(
              {"noComments": FieldValue.increment(1)},
            ),
          )
          .onError((error, stackTrace) => print('commentPost error = $error'));
    } catch (err) {
      print('commentPost error = $err');
    }
  }

  Future<String> updateUserProf(
      {required String name,
      required String uid,
      required String username,
      required String prevUsername,
      required Uint8List? profImage,
      required String? bio,
      required bool isPrivateAccount}) async {
    String res = 'some error';
    try {
      AuthMethods authMethods = AuthMethods();
      if (prevUsername != username) {
        bool usernameCheck = await authMethods.checkUsernameAvailable(username);
        if (!usernameCheck) {
          res = 'username-not-available';
          return res;
        }
      }
      String? profImageUrl;
      if (profImage != null) {
        profImageUrl =
            await StorageMethods().uploadProfileImageToStorage(uid, profImage);
      }

      //updating posts collection
      CollectionReference<Map<String, dynamic>> postsCollectionRef =
          _firestore.collection('posts');

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await postsCollectionRef.where('uid', isEqualTo: uid).get();
      for (QueryDocumentSnapshot<Map<String, dynamic>> element
          in querySnapshot.docs) {
        await element.reference.update(<String, Object?>{
          'username': username,
          'profImage': profImageUrl,
        });

        //updating comments collection in posts collection
        CollectionReference<Map<String, dynamic>> commentsCollectionRef =
            postsCollectionRef.doc(element.id).collection('comments');
        await commentsCollectionRef
            .where('uid', isEqualTo: uid)
            .get()
            .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) async {
          for (QueryDocumentSnapshot<Map<String, dynamic>> commentElem
              in querySnapshot.docs) {
            await commentElem.reference.update(<String, Object?>{
              'username': username,
              'profImage': profImageUrl
            });
          }
        });
      }

      //updating users collection
      querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      for (QueryDocumentSnapshot<Map<String, dynamic>> element
          in querySnapshot.docs) {
        await element.reference.update(<String, Object?>{
          'username': username,
          'profImage': profImageUrl,
          'bio': bio,
          'name': name,
          'isPrivateProfile': isPrivateAccount
        });
      }
    } catch (err) {
      res = err.toString();
      print('updateUserProf err = ${err.toString()}');
    }
    return res;
  }

  Future<void> commitFollow(
      //we are requesting/ following someone
      {required String currentUserUID,
      required String currentUserUsername,
      required String secUserUsername,
      required bool isPrivateProf,
      required bool doesSecUserFollow,
      required String secUserUID,
      String? currentUserProfImage,
      String? secUserProfImage,
      String? secUserToken}) async {
    
    if (isPrivateProf) {
      if (secUserToken != null) {
        await pushMessage(
            token: secUserToken,
            body: '$currentUserUsername requested to follow you.',
            title: 'Follow Request');
      }
      await _firestore.collection('users').doc(secUserUID).update({
        'followReq': FieldValue.arrayUnion([currentUserUID])
      });
      String notifId = Uuid().v1();
      Notification notification = Notification(
        notifId: notifId,
        notifType: NotifType.followReq,
        datePublished: DateTime.now().toString(),
        doWeFollow: doesSecUserFollow,
        profImage: currentUserProfImage,
        personId: currentUserUID,
        personUsername: currentUserUsername,
      );

      await _firestore
          .collection('users')
          .doc(secUserUID)
          .collection('notifications')
          .doc(notifId)
          .set(notification.toMap());
    } else {
      await _firestore.collection('users').doc(secUserUID).update({
        'followers': FieldValue.arrayUnion([currentUserUID])
      });

      await _firestore.collection('users').doc(currentUserUID).update({
        'following': FieldValue.arrayUnion([secUserUID])
      });

      if (secUserToken != null) {
        await pushMessage(
            token: secUserToken,
            body: '$currentUserUsername started following you.',
            title: 'Following');
      }

      //notification to other user
      String notifId = Uuid().v1();
      Notification notification = Notification(
        notifId: notifId,
        notifType: NotifType.startedFollowingUs,
        datePublished: DateTime.now().toString(),
        doWeFollow: doesSecUserFollow,
        profImage: currentUserProfImage,
        personId: currentUserUID,
        personUsername: currentUserUsername,
      );

      await _firestore
          .collection('users')
          .doc(secUserUID)
          .collection('notifications')
          .doc(notifId)
          .set(notification.toMap());

      //notification to ourselves
      String notifId2 = Uuid().v1();
      Notification notification2 = Notification(
        notifId: notifId2,
        notifType: NotifType.weStartedFollowing,
        datePublished: DateTime.now().toString(),
        doWeFollow: true,
        profImage: secUserProfImage,
        personId: secUserUID,
        personUsername: secUserUsername,
      );

      await _firestore
          .collection('users')
          .doc(currentUserUID)
          .collection('notifications')
          .doc(notifId)
          .set(notification2.toMap());
    }
  }

  Future<void> requestMessagingPermission() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    NotificationSettings notificationSettings =
        await _firebaseMessaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            sound: false,
            provisional: false);

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('AuthorizationStatus.authorized');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('AuthorizationStatus.provisional');
    } else {
      print('user declined permission');
    }
  }

  Future<String> pushMessage(
      {required String token,
      required String body,
      required String title}) async {
    String res = 'successful';
    try {
      http.Response response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$SERVER_KEY'
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title
            },
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
              'android_channel_id': 'notif_1'
            },
            'to': token
          }));
      if (response.statusCode == 200) {
        print('successful');
      } else {
        print('not successful');
      }
    } catch (e) {
      print('error in pushMessage ${e.toString()}');
      res = e.toString();
    }
    return res;
  }

  Future<void> commitAcceptFollowReq(
      {required String currentUserUID, required String secUserUID}) async {
    try {
      await _firestore.collection('users').doc(currentUserUID).update({
        'followReq': FieldValue.arrayRemove([secUserUID]),
        'followers': FieldValue.arrayUnion([secUserUID])
      });
      await _firestore.collection('users').doc(secUserUID).update({
        'following': FieldValue.arrayUnion([currentUserUID])
      });
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> commitRemoveFollowReq(
      {required String currentUserUID, required String secUserUID}) async {
    try {
      await _firestore.collection('users').doc(currentUserUID).update({
        'followReq': FieldValue.arrayRemove([secUserUID]),
      });
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> commitRemovePost({required String postId}) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }
}
