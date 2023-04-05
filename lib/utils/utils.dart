import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource imageSource) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: imageSource);
  if (file != null) {
    return await file.readAsBytes();
  }
  print('No image selected');
}

Future<String> pickImagePath(ImageSource imageSource) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: imageSource);
  if (file != null) {
    return file.path;
  }
  print('No image selected');
  return 'no-image-selected';
}

showSnackBar(String content, BuildContext buildContext) {
  ScaffoldMessenger.of(buildContext)
      .showSnackBar(SnackBar(content: Text(content)));
}

Future<Uint8List> readFileByte(String filePath) async {
  Uri myUri = Uri.parse(filePath);
  File audioFile = File.fromUri(myUri);
  Uint8List bytes = Uint8List(0);
  await audioFile.readAsBytes().then((value) {
    bytes = Uint8List.fromList(value);
    print('reading of bytes is completed');
  }).catchError((onError) {
    print('Exception Error while reading audio from path:$onError');
  });
  return bytes;
}

showToast({required FToast fToast, required String toastMsg}) {
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.grey[800],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon(Icons.check),
        // SizedBox(
        //   width: 12.0,
        // ),
        Text(toastMsg),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 2),
  );

  // Custom Toast Position
  //   fToast.showToast(
  //       child: toast,
  //       toastDuration: Duration(seconds: 2),
  //       positionedToastBuilder: (context, child) {
  //         return Positioned(
  //           top: 16.0,
  //           left: 16.0,
  //           child: child,
  //         );
  //       });
}

String readableTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  if (duration.inHours != 0) {
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  } else {
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

String beatifiedReadableTime(DateTime dateTime) {
  String res = 'Moments ago';
  final Duration diff = DateTime.now().difference(dateTime);
  if (diff.inDays > 30) {
    res = '${diff.inDays ~/ 30} month${diff.inDays == 1 ? '' : 's'} ago';
  } else if (diff.inDays > 0) {
    res = '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  } else if (diff.inHours > 0) {
    res = '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  } else if (diff.inMinutes > 0) {
    res = '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
  }
  return res;
}

String beatifiedMiniReadableTime(DateTime dateTime) {
  String res = '1s';
  final Duration diff = DateTime.now().difference(dateTime);
  if (diff.inDays > 30) {
    res = '${diff.inDays ~/ 30}m';
  } else if (diff.inDays > 0) {
    res = '${diff.inDays}d';
  } else if (diff.inHours > 0) {
    res = '${diff.inHours}h';
  } else if (diff.inMinutes > 0) {
    res = '${diff.inMinutes}m';
  } else if (diff.inSeconds > 0) {
    res = '${diff.inSeconds}s';
  }
  return res;
}

bool validateNotEmpty(String? input) {
  return input != null && input.isNotEmpty;
}
