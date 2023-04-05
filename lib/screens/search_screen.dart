import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/screens/default_user_profile.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/widgets/base_gradient_indicator.dart';
import 'package:instagram_clone/widgets/general_thumbnail.dart';

import '../models/post.dart';

import 'dart:math' as math;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Stream<QuerySnapshot<Map<String, dynamic>>>? _postsStream;
  bool _isShowUsers = false;
  final List<Object?> idsRemove = [];

  @override
  void initState() {
    super.initState();
    _postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('datePublished', descending: true)
        .snapshots();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
        child: GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                AnimatedSize(
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey('search_screen_back_btn'),
                    width: _isShowUsers ? null : 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Icon(
                      Icons.keyboard_backspace,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff262626),
                      border: Border.all(
                        width: 1,
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            String.fromCharCode(
                                CupertinoIcons.search.codePoint),
                            style: TextStyle(
                              fontFamily: CupertinoIcons.search.fontFamily,
                              package: CupertinoIcons.search.fontPackage,
                              fontWeight: FontWeight.w500,
                              color: _isShowUsers
                                  ? Color(0xff515151)
                                  : Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Focus(
                              onFocusChange: (value) {
                                setState(() {
                                  _isShowUsers = value;
                                });
                              },
                              child: TextFormField(
                                style: TextStyle(fontSize: 16),
                                controller: _searchController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  iconColor: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _isShowUsers
                  ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      key: ValueKey('users_stream_builder'),
                      stream: _searchController.text.isEmpty
                          ? FirebaseFirestore.instance
                              .collection('users')
                              .where('username',
                                  whereNotIn:
                                      idsRemove.isEmpty ? null : idsRemove)
                              .limit(5)
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection('users')
                              .where(
                                'username',
                                isGreaterThanOrEqualTo: _searchController.text,
                              )
                              .snapshots(),
                      builder: ((context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: ((context, index) {
                              print('id = ${snapshot.data!.docs[index].id}');
                              User user = User.fromDocSnapshot(
                                  snapshot.data!.docs[index]);
                              return InkWell(
                                key: ValueKey(user.uid),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    ProfileScreen.routeName,
                                    arguments: <String, Object?>{
                                      'uid': user.uid
                                    },
                                  );
                                },
                                highlightColor: grey1,
                                child: ListTile(
                                  leading: DefaultUserProfileView(
                                    radius: 18,
                                    imagePath: user.photoUrl,
                                  ),
                                  title: Text(
                                    user.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(user.name),
                                  trailing:_searchController.text.isEmpty ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        idsRemove.add(user.username);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Color(0xffa2a2a2),
                                    ),
                                  ) : const SizedBox(),
                                ),
                              );
                            }),
                          );
                        }
                        return Center(
                          child: BaseGradientIndicator(),
                        );
                      }),
                    )
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      key: ValueKey('posts_stream_builder'),
                      stream: _postsStream,
                      builder: ((context, snapshot) {
                        if (snapshot.hasData) {
                          return StaggeredGridView.countBuilder(
                            physics: BouncingScrollPhysics(),
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            itemCount: snapshot.data!.docs.length,
                            crossAxisCount: 3,
                            itemBuilder: ((context, index) {
                              Post post = Post.fromMap(
                                  snapshot.data!.docs[index].data());
                              return ThumbnailWidget(post: post);

                              // return Container(
                              //   key: ValueKey(post.postId),
                              //   color: grey1,
                              //   child: Stack(
                              //     children: [
                              //       Positioned(
                              //         top: 0,
                              //         right: 0,
                              //         left: 0,
                              //         bottom: 0,
                              //         child: CachedNetworkImage(
                              //           fit: post.fitCover
                              //               ? BoxFit.cover
                              //               : BoxFit.contain,
                              //           imageUrl: post.mapIdPost['0'],
                              //         ),
                              //       ),
                              //       post.mapIdPost.length > 1
                              //           ? Positioned(
                              //               top: 4,
                              //               right: 4,
                              //               child: Transform(
                              //                 alignment: Alignment.center,
                              //                 transform:
                              //                     Matrix4.rotationY(math.pi),
                              //                 child: SvgPicture.asset(
                              //                   'assets/svg/filter_none_rounded_filled.svg',
                              //                   width: 15,
                              //                   height: 15,
                              //                   color: Colors.grey[200],
                              //                 ),
                              //               ),
                              //             )
                              //           : const SizedBox()
                              //     ],
                              //   ),
                              // );
                            }),
                            staggeredTileBuilder: ((index) {
                              return StaggeredTile.count(
                                  (index % 7 == 0 && index != 0) ? 2 : 1,
                                  (index % 7 == 0) ? 2 : 1);
                            }),
                          );
                        }
                        return Center(
                          child: BaseGradientIndicator(),
                        );
                      }),
                    ),
            )
          ],
        ),
      ),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
