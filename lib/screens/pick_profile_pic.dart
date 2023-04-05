import 'dart:math';
import 'dart:ui';

import 'package:avatar_view/avatar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/screens/button.dart';
import 'package:instagram_clone/utils/base_holder_screens.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/utils/utils.dart';

class PickProfilePicScreen extends StatefulWidget {
  const PickProfilePicScreen({super.key});

  @override
  State<PickProfilePicScreen> createState() => _PickProfilePicScreenState();
}

class _PickProfilePicScreenState extends State<PickProfilePicScreen> {
  Uint8List? _image;

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource
        .gallery); //since dynamic can be Uint8List but Uint8 cannot be dynamic
    setState(() {
      _image = im;
    });
  }

  void navigateNext(Map<String, Object?> map) {
    Navigator.pushNamed(
      context,
      '/pickUsername',
      arguments: map,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object?> map =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;

    return BaseScreen(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            const SizedBox(
              height: 30,
            ),
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 64,
              child: _image == null
                  ? CircleAvatar(
                      radius: 63,
                      child: SvgPicture.asset(
                        'assets/svg/ic_camera.svg',
                        color: Colors.white,
                      ),
                    )
                  : CircleAvatar(
                      radius: 64,
                      backgroundImage: MemoryImage(_image!),
                    ),
            ),
            const SizedBox(
              height: 60,
            ),
            Text(
              _image == null ? 'Add profile photo' : 'Profile photo added',
              style: TextStyle(
                fontSize: 21,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              _image == null
                  ? "Add a profile photo so your friends \nknow it's you."
                  : 'Change Photo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            _image == null
                ? const SizedBox()
                : Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: selectImage,
                        child: Text(
                          'Change Photo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: blueColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(
              height: 60,
            ),
            BaseButton(
              text: _image == null ? 'Add a photo' : 'Next',
              onTapAction: () {
                if (_image == null) {
                  selectImage();
                } else {
                  map['profilePic'] = _image;
                  navigateNext(map);
                }
              },
              btnColor: blueColor,
            ),
            const SizedBox(
              height: 30,
            ),
            _image == null
                ? GestureDetector(
                    onTap: () {
                      print('navigateNext');
                      navigateNext(map);
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                          fontSize: 15,
                          color: blueColor,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
