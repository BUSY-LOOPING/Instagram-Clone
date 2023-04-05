import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/default_user_profile.dart';
import 'package:instagram_clone/screens/top_snackbar.dart';
import 'package:instagram_clone/utils/color.dart';

import 'package:instagram_clone/widgets/base_gradient_indicator.dart';
import 'package:provider/provider.dart';

import '../resources/firestore_methods.dart';
import '../utils/utils.dart';

class EditProfileScreen extends StatefulWidget {
  static String routeName = '/editProfile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(),
      _usernameController = TextEditingController(),
      _bioController = TextEditingController();
  bool _isUpdating = false,
      _isPrivateProf = false,
      _isCheckActivated = true,
      _showTopSnackBar = false;
  Uint8List? _image;
  String _nameEt = '', _usernameEt = '';

  void selectImage() async {
    Uint8List im = await pickImage(
      ImageSource.gallery,
    );
    setState(() {
      _image = im;
    });
  }

  // void checkValidation() {
  //   if (validateNotEmpty(_nameEt) &&
  //       validateNotEmpty(_usernameEt) &&
  //       !_isCheckActivated) {
  //     setState(() {
  //       print('_isCheckActivated true');
  //       _isCheckActivated = true;
  //     });
  //   } else if (_isCheckActivated) {
  //     setState(() {
  //       print('_isCheckActivated false');
  //       _isCheckActivated = false;
  //     });
  //   }
  //   print('outsisde');
  // }

  @override
  void initState() {
    User user = Provider.of<UserProvider>(context, listen: false).getUser!;
    _isPrivateProf = user.isPrivateProfile;
    _nameController.text = user.name;
    _usernameController.text = user.username;
    _nameEt = user.name;
    _usernameEt = user.username;

    _bioController.text = user.bio == null ? '' : user.bio!;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nameController.addListener(() {
        setState(() {
          _nameEt = _nameController.text;
        });
        // checkValidation();
      });
      _usernameController.addListener(() {
        setState(() {
          _usernameEt = _usernameController.text;
        });
        // checkValidation();
      });
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser!;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              color: _isCheckActivated ? blueColor : blueColor.withAlpha(128),
              onPressed: () async {
                if (_isCheckActivated && !_isUpdating) {
                  await commitChanges(
                    uid: user.uid,
                    prevUsername: user.username,
                  );
                }
              },
              icon: _isUpdating
                  ? SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.done,
                      size: 30,
                    ),
            ),
          ],
          backgroundColor: mobileBgColor,
          title: Text('Edit Profile'),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_sharp,
              size: 30,
            ),
            // icon: SvgPicture.asset(
            //   width: 30,
            //   height: 30,
            //   'assets/svg/ic_ios_close.svg',
            //   color: primaryColor,
            // ),
          ),
        ),
        body: FutureBuilder<Widget>(
          future: buildMainWidget(user),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else {
              print(snapshot.toString());
              return Center(child: BaseGradientIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<Widget> buildMainWidget(User user) async {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: Column(
                children: [
                  DefaultUserProfileView(
                    borderWidth: 1,
                    borderColor: grey1,
                    radius: 60,
                    imagePath: user.photoUrl,
                  ),
                  GestureDetector(
                    onTap: selectImage,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        user.photoUrl != null
                            ? 'Edit picture'
                            : 'Add profile pic',
                        style: TextStyle(
                          color: blueColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  genTextFormField(
                    controller: _nameController,
                    initialText: null,
                    labelText: 'Name',
                  ),
                  genTextFormField(
                    controller: _usernameController,
                    initialText: null,
                    labelText: 'Username',
                  ),
                  genTextFormField(
                      controller: _bioController,
                      initialText: null,
                      labelText: 'Bio (150)',
                      maxLen: 150),
                ],
              ),
            ),
            InkWell(
              highlightColor: highlightColor,
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onPressed: () {},
                    icon: Icon(
                      Icons.lock_outline_rounded,
                    ),
                  ),
                  Text(
                    'Private Account',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Spacer(),
                  Switch(
                    activeColor: blueColor,
                    value: _isPrivateProf,
                    onChanged: (value) {
                      setState(() {
                        _isPrivateProf = !_isPrivateProf;
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget genTextFormField(
      {required String? initialText,
      required String labelText,
      required TextEditingController controller,
      int? maxLen}) {
    // controller.text = initialText ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        maxLines: null,
        maxLength: maxLen,
        controller: controller,
        style: TextStyle(fontSize: 18, decoration: TextDecoration.none),
        decoration: InputDecoration(
          hintStyle: TextStyle(color: secondaryColor.shade400, fontSize: 14),
          disabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          border: UnderlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          floatingLabelStyle: TextStyle(color: secondaryColor.shade400),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelText: labelText,
        ),
        textCapitalization: TextCapitalization.words,
      ),
    );
  }

  Future<void> commitChanges(
      {required String uid, required String prevUsername}) async {
    setState(() {
      _isUpdating = true;
    });
    await FirestoreMethods()
        .updateUserProf(
      name: _nameController.text,
      uid: uid,
      username: _usernameController.text,
      prevUsername: prevUsername,
      profImage: _image,
      bio: _bioController.text.isEmpty ? null : _bioController.text,
      isPrivateAccount: _isPrivateProf,
    )
        .then((value) {
      if (value == 'username-not-available') {
        showSnackBar('Username not available', context);
        setState(() {
          _showTopSnackBar = true;
        });
      }
    });
    setState(() {
      _isUpdating = false;
    });
  }
}
