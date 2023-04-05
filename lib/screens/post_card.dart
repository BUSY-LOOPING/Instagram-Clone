import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comments_screen.dart';
import 'package:instagram_clone/screens/default_user_profile.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/widgets/base_gradient_indicator.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'dart:math' as math;
import 'dart:ui' as ui;

import '../models/post.dart';
import '../utils/utils.dart';

class PostCard extends StatefulWidget {
  final Post snap;

  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<PostCard> {
  late AnimationController _bottomSheetAnimController;
  final Map<String, Completer<ui.Image>> _map = {};
  late double _carouselHeight = 300.0;
  int _activePageIdx = 0;
  bool _isLikeAnimating = false;
  Widget _notLikedWidget = Icon(
    Icons.favorite_border,
    color: Colors.white,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _carouselHeight = MediaQuery.of(context).size.height * 0.6;
      });

      _map['0']!.future.then((value) {
        setState(() {
          _carouselHeight = math.min(value.height.toDouble(),
              MediaQuery.of(context).size.height * 0.6);
        });
      });
    });

    _bottomSheetAnimController = BottomSheet.createAnimationController(this);
    _bottomSheetAnimController.duration = Duration(microseconds: 250);
    _bottomSheetAnimController.drive(CurveTween(curve: Curves.easeIn));

    widget.snap.mapIdPost.forEach((key, value) {
      Completer<ui.Image> completer = Completer<ui.Image>();

      CachedNetworkImageProvider cachedNetworkImageProvider =
          CachedNetworkImageProvider(value.toString());
      Image postImg = Image(
        image: cachedNetworkImageProvider,
        fit: widget.snap.fitCover ? BoxFit.cover : BoxFit.contain,
      );

      // Image postImg = Image.network(
      //   value.toString(),
      //   fit: widget.snap.fitCover ? BoxFit.cover : BoxFit.contain,
      // );

      postImg.image.resolve(ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo info, bool synchronousCall) =>
              completer.complete(info.image)));
      _map[key] = completer;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final User? user = Provider.of<UserProvider>(context).getUser;
    // setState(() {
    //     _carouselHeight = MediaQuery.of(context).size.height * 0.6;
    //   });
    // _map['0']!.future.then((value) {
    //   setState(() {
    //     _carouselHeight = math.min(
    //         value.height.toDouble(), MediaQuery.of(context).size.height * 0.6);
    //   });
    // });

    // Completer<ui.Image> completer = Completer<ui.Image>();
    // Image post_img = Image.network(
    //   widget.snap.mapIdPost['0'],
    //   fit: widget.snap.fitCover ? BoxFit.cover : BoxFit.contain,
    // );

    // post_img.image.resolve(ImageConfiguration()).addListener(
    //     ImageStreamListener((ImageInfo info, bool synchronousCall) =>
    //         completer.complete(info.image)));
    var isOurLikePresent = widget.snap.likes.contains(user?.uid ?? false);
    return Container(
      color: mobileBgColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 8,
            ).copyWith(right: 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    openUserProfile();
                  },
                  child: DefaultUserProfileView(
                    hasStory: false,
                    imagePath: widget.snap.profImage,
                    radius: 12,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            openUserProfile();
                          },
                          child: Text(
                            widget.snap.username,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await moreBtnPressed(context);
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                  postId: widget.snap.postId,
                  uid: user?.uid,
                  likes: widget.snap.likes);
              setState(() {
                _isLikeAnimating = true;
              });
            },
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CarouselSlider.builder(
                      itemCount: widget.snap.mapIdPost.length,
                      itemBuilder: ((context, index, realIndex) {
                        return getFutureBuilder(_map[index.toString()]!.future);
                      }),
                      options: CarouselOptions(
                          onPageChanged: (index, reason) {
                            setState(() {
                              _activePageIdx = index;
                            });
                          },
                          viewportFraction: 1.0,
                          enlargeCenterPage: false,
                          enableInfiniteScroll: false,
                          height: _carouselHeight),
                    ),
                    AnimatedOpacity(
                      opacity: _isLikeAnimating ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: LikeAnimation(
                        onEnd: () {
                          setState(() {
                            _isLikeAnimating = false;
                          });
                        },
                        duration: const Duration(
                          milliseconds: 400,
                        ),
                        isAnimating: _isLikeAnimating,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    )
                  ],
                ),
                widget.snap.mapIdPost.length > 1
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AnimatedSmoothIndicator(
                          activeIndex: _activePageIdx,
                          count: widget.snap.mapIdPost.length,
                          effect: ScrollingDotsEffect(
                              spacing: 5.0,
                              maxVisibleDots: 5,
                              activeDotColor: blueColor,
                              dotColor: secondaryColor.shade700,
                              dotHeight: 5.0,
                              dotWidth: 5.0,
                              activeDotScale: 1.3),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),

          //Like Comment Section
          Row(
            children: [
              LikeAnimation(
                duration: const Duration(milliseconds: 200),
                isSmallLike: true,
                isAnimating: isOurLikePresent,
                child: GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      _notLikedWidget = Icon(
                        Icons.favorite,
                        color: Colors.red,
                      );
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _notLikedWidget = Icon(
                        Icons.favorite_outline,
                        color: Colors.white,
                      );
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      _notLikedWidget = Icon(
                        Icons.favorite_outline,
                        color: Colors.white,
                      );
                    });
                  },
                  child: IconButton(
                    iconSize: 26,
                    onPressed: () async {
                      await FirestoreMethods().likePost(
                          postId: widget.snap.postId,
                          uid: user?.uid,
                          likes: widget.snap.likes);
                    },
                    icon: isOurLikePresent
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : _notLikedWidget,
                  ),
                ),
              ),
              GestureDetector(
                onTap: navigateCommentsScreen,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/svg/instagram_comment.svg',
                    color: primaryColor,
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/svg/instagram_share.svg',
                  height: 20,
                  width: 20,
                  color: primaryColor,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.bookmark_outline,
                    ),
                  ),
                ),
              )
            ],
          ),

          //desc and number of comments
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  child: Text(
                    '${widget.snap.likes.length} likes',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  // child: RichText(
                  //   text: TextSpan(
                  //     style: const TextStyle(
                  //       color: primaryColor,
                  //     ),
                  //     children: [
                  //       TextSpan(
                  //         text: widget.snap.username,
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.w700,
                  //         ),
                  //       ),

                  //       TextSpan(
                  //         text: '  ${widget.snap.caption}',
                  //         style: TextStyle(
                  //             // fontWeight: FontWeight.w700,
                  //             ),
                  //       )
                  //     ],
                  //   ),
                  // ),

                  child: ExpandableText(
                    widget.snap.caption ?? '',
                    expandText: ' more',
                    linkEllipsis: true,

                    // linkColor: secondaryColor.shade600,
                    linkStyle: TextStyle(
                      color: secondaryColor.shade600,
                    ),
                    style: TextStyle(
                      color: primaryColor,
                    ),
                    prefixStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    prefixText: widget.snap.username,
                  ),
                ),
                widget.snap.noComments < 2
                    ? const SizedBox()
                    : GestureDetector(
                        onTap: navigateCommentsScreen,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            'View all ${widget.snap.noComments} comments',
                            style: const TextStyle(
                              fontSize: 15,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    beatifiedReadableTime(
                      DateTime.parse(widget.snap.datePublished),
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: secondaryColor,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  FutureBuilder<ui.Image> getFutureBuilder(Future<ui.Image> future) {
    return FutureBuilder<ui.Image>(
      future: future,
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return RawImage(
              height: math.min(snapshot.data!.height.toDouble(),
                  MediaQuery.of(context).size.height * 0.6),
              width: double.infinity,
              image: snapshot.data!,
              fit: widget.snap.fitCover ? BoxFit.cover : BoxFit.contain);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
            child: Center(
              // child: CircularProgressIndicator(
              //   color: blueColor,
              //   strokeWidth: 2,
              // ),
              child: BaseGradientIndicator(),
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(color: Colors.grey[600]),
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            child: Center(
                child: Text(
              'Something went wrong',
            )),
          );
        }
      }),
    );
  }

  Future<dynamic> moreBtnPressed(BuildContext context) {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        var iconSize = 20.0;
        var textStyle = TextStyle(
          fontSize: 16,
        );
        return CupertinoPopupSurface(
          child: Material(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(20.0),
                //   topRight: Radius.circular(20.0),
                // ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 38,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Divider(),
                  // Row(
                  //   children: [
                  //     IconButton(onPressed: () {}, icon: Icon(Icons.star))
                  //   ],
                  // ),
                  ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Add to favourite'),
                  ),
                  ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Add to favourite'),
                  ),
                  ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Add to favourite'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void navigateCommentsScreen() {
    Navigator.pushNamed(
      context,
      CommentsScreen.routeName,
      arguments: <String, Object?>{
        'post': widget.snap,
      },
    );
  }

  void openUserProfile() {
    Navigator.pushNamed(context, ProfileScreen.routeName,
        arguments: <String, Object?>{'uid': widget.snap.uid});
  }
}
