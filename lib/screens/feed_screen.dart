import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/post_card.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/widgets/base_gradient_indicator.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin<FeedScreen> {
  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: true);
  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;

  @override
  bool get wantKeepAlive => true; // ** and here

  void _navigateNewPost() {
    Navigator.pushNamed(context, '/selectPost');
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).getUser;
    if (user != null) {
      _stream = FirebaseFirestore.instance
          .collection('posts')
          .where(
            'uid',
            whereIn: [user.uid, ...user.following ?? []],
          )
          .orderBy('datePublished', descending: true)
          .snapshots();
    }
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBgColor,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/svg/ic_instagram_logo.svg',
            color: primaryColor,
            height: 34,
          ),
        ),
        actions: [
          IconButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,

            onPressed: _navigateNewPost,
            // icon: SvgPicture.asset(
            //   'assets/svg/add_square.svg',
            //   color: primaryColor,
            //   height: 20,
            // ),
            icon: Icon(
              Icons.add_circle_outline,
              color: primaryColor,
              size: 28,
            ),
          ),
          IconButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/svg/fb_messenger.svg',
              color: primaryColor,
              height: 28,
              width: 28,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: ((context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              controller: _scrollController,
              // key: UniqueKey(),
              // shrinkWrap: true,
              addAutomaticKeepAlives: true,
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data?.docs.length ?? 0,
              itemBuilder: ((context, index) {
                Post post = Post.fromMap(
                  snapshot.data!.docs[index].data(),
                );
                return PostCard(
                  key: ValueKey(post.postId),
                  snap: post,
                );
              }),
            );
          } else {
            return Center(child: BaseGradientIndicator());
          }
        }),
      ),
    );
  }
}
