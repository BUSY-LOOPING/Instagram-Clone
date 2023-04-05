import 'package:avatar_view/avatar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/default_user_profile.dart';
import 'package:instagram_clone/utils/base_holder_screens.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;

import 'select_post_screen.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  late List<GeneralFile> _posts;
  final TextEditingController _captionController = TextEditingController();
  List<Uint8List> _postsUintLst = [];
  int _postTo = 0;
  late FToast fToast;
  bool _posting = false, _fitCover = true;

  void _readFileBytes() async {
    for (GeneralFile f in _posts) {
      Uint8List? uint8list = await readFileByte(f.path);
      if (uint8list != null) {
        setState(() {
          _postsUintLst.add(uint8list);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // final Map<String, Object?> map =
      //     ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;
      // setState(() {
      //   _posts = map['posts'] as List<GeneralFile>;
      //   _postTo = map['postTo'] as int;
      //   _fitCover = map['fitCover'] as bool;
      // });

      _readFileBytes();

      // (() async {
      //   print('inside');
      // });
      // setState(() {
      //   _postsUintLst = _postsUintLst;
      // });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _captionController.dispose();
  }

  void _commitPost({required User? user}) async {
    if (!_posting) {
      setState(() {
        _posting = true;
      });
      try {
        await Future.doWhile(
                () => user == null && _postsUintLst.length == _posts.length)
            .timeout(Duration(minutes: 2), onTimeout: () {
          showToast(
              fToast: fToast, toastMsg: 'Something went wrong. Try again!');
        });
        await FirestoreMethods()
            .uploadPost(
                user: user!,
                files: _postsUintLst,
                caption: _captionController.text,
                fitCover: _fitCover)
            .then((res) => {
                  Navigator.of(context).popUntil(ModalRoute.withName("/home")),
                  if (res != 'success')
                    {
                      showToast(
                          fToast: fToast, toastMsg: 'Something went wrong')
                    }
                  else
                    {showSnackBar('Posted', context)}
                });
      } catch (err) {
        print('err = $err');
      } finally {
        setState(() {
          _posting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object?> map =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;
    _posts = map['posts'] as List<GeneralFile>;
    _postTo = map['postTo'] as int;
    _fitCover = map['fitCover'] as bool;

    final User? user = Provider.of<UserProvider>(context).getUser;
    const marginWidget = SizedBox(
      height: 8,
    );
    return BaseScreen(
      child: Column(
        children: [
          AppBar(
            backgroundColor: mobileBgColor,
            title: Text(
              'New ${_postTo == 0 ? 'Post' : (_postTo == 1 ? 'Story' : 'Reel')}',
            ),
            actions: [
              IconButton(
                // padding: const EdgeInsets.all(12.0),
                onPressed: () => _commitPost(user: user),
                icon: Icon(
                  Icons.done,
                  color: blueColor,
                  size: 30,
                ),
              )
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 100),
            child: SizedBox(
              height: _posting ? 1 : 0,
              child: const LinearProgressIndicator(),
            ),
          ),
          marginWidget,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DefaultUserProfileView(
                      radius: 20,
                      imagePath: user?.photoUrl,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          controller: _captionController,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          autofocus: false,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            hintText: 'Write a caption...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _postsUintLst.isEmpty
                                ? const SizedBox()
                                : Image.memory(
                                    _postsUintLst.last,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          _postsUintLst.length > 1
                              ? Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.rotationY(math.pi),
                                    child: SvgPicture.asset(
                                      'assets/svg/filter_none_rounded_filled.svg',
                                      width: 15,
                                      height: 15,
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
                marginWidget,
                Divider(
                  thickness: 1,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
