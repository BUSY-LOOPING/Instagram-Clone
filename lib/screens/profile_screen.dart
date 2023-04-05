import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_profile_provider.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/button.dart';
import 'package:instagram_clone/screens/default_user_profile.dart';
import 'package:instagram_clone/screens/edit_profile_screen.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/widgets/general_thumbnail.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../widgets/base_gradient_indicator.dart';

enum FollowingType { follower, notFollower, requested }

class ProfileScreen extends StatefulWidget {
  static String routeName = '/profileScreen';
  final String? uid;

  const ProfileScreen({super.key, this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with
        AutomaticKeepAliveClientMixin<ProfileScreen>,
        TickerProviderStateMixin {
  final TextStyle _numStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  final TextStyle _numDescStyle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
  FollowingType? _secUserFollowingType, _currentUserFollowingType;

  final PageController _pageController = PageController();
  late final TabController _tabController;
  bool _isCurrentUser = true, _isBtnLoading = false;
  String? _uid;
  int _tabIndex = 0;
  Widget _btn = SizedBox();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
        // _pageController.animateToPage(
        //   _tabController.index,
        //   duration: const Duration(milliseconds: 400),
        //   curve: Curves.ease,
        // );
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addData(_uid!);
    });
  }

  @override
  void dispose() {
    print('dispose');
    _pageController.dispose();
    _tabController.dispose();
    disposeStream();
    super.dispose();
  }

  void _navigateNewPost() {
    Navigator.pushNamed(context, '/selectPost');
  }

  Column genStatsColumn({required String title, required int num}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$num',
          style: _numStyle,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Text(
            title,
            style: _numDescStyle,
          ),
        )
      ],
    );
  }

  Future<bool> init(UserA? user, User? currentUser) async {
    print('init');
    if (widget.uid == null) {
      final Map<String, Object?> map =
          ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;
      _uid = map['uid'] as String;
    } else {
      _uid = widget.uid!;
    }
    if (user == null || currentUser == null) {
      return false;
    }

    // await Future.doWhile(() => user == null).timeout(
    //   const Duration(minutes: 1),
    //   onTimeout: () {
    //     return false;
    //   },
    // );
    // await Future.doWhile(() => currentUser == null).timeout(
    //   const Duration(minutes: 1),
    //   onTimeout: () {
    //     return false;
    //   },
    // );

    _isCurrentUser = _uid! == currentUser.uid;
    if (!_isCurrentUser) {
      //profile is not ours
      if (user.followers?.contains(currentUser.uid) ?? false) {
        _currentUserFollowingType =
            FollowingType.follower; //we are sec user's follower
      } else {
        if (user.followReq?.contains(currentUser.uid) ?? false) {
          _currentUserFollowingType = FollowingType
              .requested; //display requested button  => we have requested to follow sec user
        } else {
          _currentUserFollowingType = FollowingType.notFollower;
        }
      }

      if (currentUser.followers?.contains(user.uid) ?? false) {
        _secUserFollowingType =
            FollowingType.follower; //sec user is our follower
      } else {
        if (currentUser.followReq?.contains(user.uid) ?? false) {
          _secUserFollowingType = FollowingType
              .requested; //display accept or reject button  => sec user has requested to follow us
        } else {
          _secUserFollowingType = FollowingType.notFollower;
        }
      }

      if (_currentUserFollowingType == FollowingType.follower &&
          _secUserFollowingType != FollowingType.requested) {
        _btn = Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          width: double.infinity,
          child: BaseButton(
            borderRadius: 8,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            text: 'Following',
            onTapAction: () {},
            btnColor: grey1,
          ),
        );
      } else if (_currentUserFollowingType == FollowingType.requested) {
        _btn = Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          width: double.infinity,
          child: BaseButton(
            borderRadius: 8,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            text: 'Requested',
            onTapAction: () {},
            btnColor: grey1,
          ),
        );
      } else if (_currentUserFollowingType == FollowingType.notFollower &&
          _secUserFollowingType == FollowingType.follower) {
        _btn = Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          width: double.infinity,
          child: BaseButton(
            btnLoading: _isBtnLoading,
            borderRadius: 8,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            text: 'Follow back',
            onTapAction: () {
              setState(() {
                _isBtnLoading = true;
              });
              FirestoreMethods()
                  .commitFollow(
                currentUserUID: currentUser.uid,
                currentUserUsername: currentUser.username,
                secUserUsername: user.username,
                isPrivateProf: user.isPrivateProfile,
                doesSecUserFollow: true,
                secUserUID: user.uid,
                secUserToken: user.token,
              )
                  .then((value) {
                _isBtnLoading = false;
              });
            },
            btnColor: blueColor,
          ),
        );
      } else if (_currentUserFollowingType == FollowingType.notFollower &&
          _secUserFollowingType == FollowingType.notFollower) {
        _btn = Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          width: double.infinity,
          child: BaseButton(
            btnLoading: _isBtnLoading,
            borderRadius: 8,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            text: 'Follow',
            onTapAction: () {
              setState(() {
                _isBtnLoading = true;
              });
              FirestoreMethods()
                  .commitFollow(
                currentUserUID: currentUser.uid,
                currentUserUsername: currentUser.username,
                secUserUsername: user.username,
                isPrivateProf: user.isPrivateProfile,
                doesSecUserFollow: false,
                secUserUID: user.uid,
                secUserToken: user.token,
              )
                  .then((value) {
                _isBtnLoading = false;
              });
            },
            btnColor: blueColor,
          ),
        );
      } else if (_secUserFollowingType == FollowingType.requested) {
        _btn = Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          width: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: BaseButton(
                  borderRadius: 8,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  text: 'Accept',
                  onTapAction: () {
                    setState(() {
                      _isBtnLoading = true;
                    });
                    FirestoreMethods()
                        .commitAcceptFollowReq(
                            currentUserUID: currentUser.uid,
                            secUserUID: user.uid)
                        .then((value) {
                      setState(() {
                        _isBtnLoading = true;
                      });
                    });
                  },
                  btnColor: blueColor,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: BaseButton(
                  borderRadius: 8,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  text: 'Cancel',
                  onTapAction: () {
                    setState(() {
                      _isBtnLoading = true;
                    });
                    FirestoreMethods()
                        .commitRemoveFollowReq(
                            currentUserUID: currentUser.uid,
                            secUserUID: user.uid)
                        .then((value) {
                      setState(() {
                        _isBtnLoading = false;
                      });
                    });
                  },
                  btnColor: grey1,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      _btn = Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: double.infinity,
        child: BaseButton(
          borderRadius: 8,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          text: 'Edit Profile',
          onTapAction: navigateEditProfile,
          btnColor: grey1,
        ),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    User? currentUser = Provider.of<UserProvider>(context).getUser;

    List<Post>? lst = Provider.of<UserProfileProvider>(context).getLstPost;
    UserA? user = Provider.of<UserProfileProvider>(context).getUser;
    print(user?.username ?? 'null still');
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        shadowColor: Colors.grey,
        backgroundColor: mobileBgColor,
        centerTitle: false,
        title: Text(
          user?.username ?? '',
        ),
        actions: _isCurrentUser
            ? [
                IconButton(
                  onPressed: _navigateNewPost,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.menu_rounded,
                    size: 28,
                  ),
                ),
              ]
            : [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.more_vert,
                    size: 28,
                  ),
                ),
              ],
      ),
      body: FutureBuilder<bool>(
        future: init(user, currentUser),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          DefaultUserProfileView(
                            radius: 50,
                            imagePath: user?.photoUrl,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  genStatsColumn(
                                      title: 'Posts', num: lst?.length ?? 0),
                                  genStatsColumn(
                                      title: 'Followers',
                                      num: user?.followers?.length ?? 0),
                                  genStatsColumn(
                                      title: 'Following',
                                      num: user?.following?.length ?? 0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          user?.name ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      user?.bio == null
                          ? const SizedBox()
                          : Text(
                              user!.bio!,
                              style: _numDescStyle,
                            ),
                      _btn,
                    ],
                  ),
                ),

                DecoratedBox(
                  decoration: BoxDecoration(
                    //This is for background color
                    // color: Colors.green.withOpacity(0.0),
                    //This is for bottom border that is needed
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.2,
                      ),
                    ),
                  ),
                  // width: double.maxFinite,
                  // color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
                    splashFactory: NoSplash.splashFactory,
                    isScrollable: false,
                    enableFeedback: false,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(
                        icon: Icon(Icons.grid_3x3),
                      ),
                      Tab(
                        icon: Icon(Icons.person),
                      ),
                    ],
                  ),
                ),
                // Container(
                //   height: MediaQuery.of(context).size.height,
                //   child: PageView(
                //     // physics: NeverScrollableScrollPhysics(),
                //     controller: _pageController,
                //     onPageChanged: (value) {
                //       _tabController.animateTo(value);
                //     },
                //     children: [
                //       //first child
                //       StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                //         stream: _postsStream,
                //         builder: (context, snapshot) {
                //           if (snapshot.hasData) {
                //             return GridView.builder(
                //               physics: NeverScrollableScrollPhysics(),
                //               shrinkWrap: true,
                //               itemCount: snapshot.data!.docs.length,
                //               gridDelegate:
                //                   SliverGridDelegateWithFixedCrossAxisCount(
                //                       crossAxisSpacing: 2,
                //                       crossAxisCount: 3,
                //                       childAspectRatio: 1,
                //                       mainAxisSpacing: 2),
                //               itemBuilder: ((context, index) {
                //                 Post post = Post.fromMap(
                //                   snapshot.data!.docs[index].data(),
                //                 );
                //                 return ThumbnailWidget(key: ValueKey(post.postId), post: post);
                //               }),
                //             );
                //           } else if (snapshot.connectionState ==
                //               ConnectionState.waiting) {
                //             return Center(
                //               child: BaseGradientIndicator(),
                //             );
                //           }
                //           return Container();
                //         },
                //       ),

                //       //second child
                //       Container(),
                //     ],
                //   ),
                // ),

                Builder(
                  builder: ((context) {
                    if (_tabIndex == 0) {
                      if (user == null) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 80,
                            // horizontal: 50,
                          ),
                          child: Center(child: BaseGradientIndicator()),
                        );
                      }
                      if (lst != null) {
                        if (lst.isNotEmpty) {
                          print('list not empty');
                          return GridView.builder(
                            addAutomaticKeepAlives: true,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: lst.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: 2,
                                    crossAxisCount: 3,
                                    childAspectRatio: 1,
                                    mainAxisSpacing: 2),
                            itemBuilder: ((context, index) {
                              return ThumbnailWidget(
                                  key: ValueKey(lst[index].postId),
                                  post: lst[index]);
                            }),
                          );
                        } else {
                          print('LIST EMPTY');
                          return FractionallySizedBox(
                            widthFactor: 0.75,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              padding: const EdgeInsets.symmetric(
                                vertical: 80,
                                // horizontal: 50,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Profile',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 23,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, bottom: 8),
                                    child: Text(
                                      "When you share photos and videos, they'll appear on your profile.",
                                      style: TextStyle(
                                        color: secondaryColor,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _navigateNewPost,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        "Share your first photo or video",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: blueColor,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 80),
                          child: Center(child: BaseGradientIndicator()),
                        );
                      }
                    }
                    return Container();
                  }),
                ),

                const SizedBox(
                  height: 100,
                )
              ],
            );
          }
          return Center(
            child: BaseGradientIndicator(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;

  void navigateEditProfile() {
    Navigator.pushNamed(context, EditProfileScreen.routeName);
  }

  void addData(String uid) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    userProfileProvider.refreshPostsForUserID(uid);
    userProfileProvider.refreshUser(uid);
  }

  Widget getBtn(User currentUser, User? user) {
    return FutureBuilder<String>(
        future: getBtnFuture(currentUser, user),
        builder: ((context, AsyncSnapshot<String> snapshot) {
          print('snapshot ${snapshot}');
          if (snapshot.hasData) {
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: InkWell(
                      highlightColor: grey1.withAlpha(128),
                      onTap: navigateEditProfile,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          color: snapshot.data!.contains('Follow')
                              ? blueColor
                              : grey1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Center(
                          child: Text(
                            snapshot.data!,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Container();
        }));
  }

  Future<String> getBtnFuture(User currentUser, User? user) async {
    await Future.doWhile(() => user == null);
    String res = '';
    if (currentUser.uid == user!.uid) {
      res = 'Edit profile';
      return res;
    }

    if (currentUser.followers?.contains(user.uid) ?? false) {
      if (currentUser.following?.contains(user.uid) ?? false) {
        res = 'Following';
      } else {
        res = 'Follow back';
      }
    } else {
      if (currentUser.following?.contains(user.uid) ?? false) {
        res = 'Following';
      } else {
        res = 'Follow';
      }
    }

    return res;
  }

  String getFormattedBtnString(User currentUser, User? user) {
    String res = '';
    if (user != null && currentUser.uid == user.uid) {
      res = 'Edit profile';
      return res;
    }

    if (currentUser.followers?.contains(user?.uid) ?? false) {
      if (currentUser.following?.contains(user?.uid) ?? false) {
        res = 'Following';
      } else {
        res = 'Follow back';
      }
    } else {
      if (currentUser.following?.contains(user?.uid) ?? false) {
        res = 'Following';
      } else {
        res = 'Follow';
      }
    }
    return res;
  }

  Future<void> commitUnfollow() async {}

  void disposeStream() {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    userProfileProvider.disposePostLstStream();
    userProfileProvider.disposeUserStream();
    userProfileProvider.dispose();
  }
}
