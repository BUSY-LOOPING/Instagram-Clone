import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //adding image to firebase storage
  Future<String> uploadProfileImageToStorage(
      String uid, Uint8List file) async {
    Reference ref = _storage
        .ref()
        .child(uid)
        // .child(_auth.currentUser!.uid)
        .child('profilePic');
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<List<String>> uploadPostToStorage(
      String uid, List<Uint8List> files) async {
    Reference ref = _storage
        .ref()
        .child(uid)
        // .child(_auth.currentUser!.uid)
        .child('posts');
    List<String> res = [];
    for (var i = 0; i < files.length; i++) {
      String id = Uuid().v1();
      UploadTask uploadTask = ref.child(id).putData(files[i]);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      res.add(downloadUrl);
    }

    assert(res.length == files.length);
    return res;
  }
}
