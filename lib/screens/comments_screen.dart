import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/default_user_profile.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/widgets/base_gradient_indicator.dart';
import 'package:provider/provider.dart';

import '../widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  static String routeName = '/comments';

  const CommentsScreen({
    super.key,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen>
    with TickerProviderStateMixin
    // , AutomaticKeepAliveClientMixin<CommentsScreen>
    {
  final TextEditingController _commentController = TextEditingController();
  bool _postEnabled = false;
  late Stream<QuerySnapshot<Map<String, dynamic>>>? _stream = Stream.empty();
  late Post _post;
  
  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _stream = FirebaseFirestore.instance
            .collection('posts')
            .doc(_post.postId)
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .snapshots();
      });
    });

    _commentController.addListener(() {
      if (_commentController.text.isEmpty && _postEnabled) {
        setState(() {
          _postEnabled = false;
        });
      } else if (_commentController.text.isNotEmpty && !_postEnabled) {
        setState(() {
          _postEnabled = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    final Map<String, Object?> map =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;
    final Post post = map['post'] as Post;
    _post = post;

    User? user = Provider.of<UserProvider>(context).getUser;
    TextStyle emojiStyle = TextStyle(
      fontSize: 20,
    );

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: mobileBgColor,
            title: const Text('Comments'),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: SvgPicture.asset(
                  'assets/svg/instagram_share.svg',
                  height: 20,
                  width: 20,
                  color: primaryColor,
                ),
              )
            ],
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _stream,
            builder: (context, snapshot) {
              print('builder called');
              int itemCount = 1;
              if (snapshot.data != null) {
                itemCount = snapshot.data!.docs.length + 1;
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                itemCount = 2;
              }
              print('itemCount $itemCount');
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: ((context, index) {
                  if (index == 0) {
                    print('here');
                    return CommentCard(
                      key: ValueKey('header'),
                      comment: null,
                      isHeader: true,
                      post: post,
                    );
                  }
                  if (index == 1 &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Align(
                      key: ValueKey('loadingIndicator'),
                      alignment: Alignment.topCenter,
                      child: BaseGradientIndicator(),
                    );
                  } else if (snapshot.hasData) {
                    return CommentCard(
                      key: ValueKey(
                          snapshot.data?.docs[index - 1].data()['commentId'] ??
                              'error'),
                      comment: snapshot.data == null || snapshot.hasError
                          ? null
                          : Comment.fromMap(
                              snapshot.data!.docs[index - 1].data(),
                            ),
                    );
                  }

                  return const SizedBox();
                }),
              );
            },
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              color: commentsBottomColor,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GestureDetector(
                          onTap: () => addEmojiToText('❤️'),
                          child: Text(
                            '❤️',
                            style: emojiStyle,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => addEmojiToText('🙌'),
                          child: Text(
                            '🙌',
                            style: emojiStyle,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => addEmojiToText('🔥'),
                          child: Text(
                            '🔥',
                            style: emojiStyle,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => addEmojiToText('👏'),
                          child: Text(
                            '👏',
                            style: emojiStyle,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => addEmojiToText('😥'),
                          child: Text(
                            '😥',
                            style: emojiStyle,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => addEmojiToText('😍'),
                          child: Text(
                            '😍',
                            style: emojiStyle,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => addEmojiToText('😮'),
                          child: Text(
                            '😮',
                            style: emojiStyle,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => addEmojiToText('😂'),
                          child: Text(
                            '😂',
                            style: emojiStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 2.0,
                      bottom: 2.0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DefaultUserProfileView(
                          radius: 14,
                          imagePath: user?.photoUrl,
                        ),
                        Expanded(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 150,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextField(
                                controller: _commentController,
                                maxLines: null,
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                  hintText:
                                      'Comment as ${user?.username ?? ''}...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_postEnabled) {
                              await commitComment(
                                  username: user!.username,
                                  uid: user.uid,
                                  postId: post.postId,
                                  profImage: user.photoUrl);
                            }
                          },
                          child: Text(
                            'Post',
                            style: TextStyle(
                              color: _postEnabled
                                  ? blueColor
                                  : blueColor.withOpacity(0.5),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> commitComment(
      {required String username,
      required String uid,
      required String postId,
      required String? profImage}) async {
    await FirestoreMethods()
        .commentPost(
            content: _commentController.text,
            username: username,
            uid: uid,
            postId: postId,
            profImage: profImage)
        .then((value) => _commentController.text = '');
  }

  addEmojiToText(String s) {
    var cursorPos = _commentController.selection.base.offset; 
    String textAfterCursor =  _commentController.text.substring(cursorPos);
    String textBeforeCursor = _commentController.text.substring(0, cursorPos);
    _commentController.text = textBeforeCursor + s + textAfterCursor;
    _commentController.selection = TextSelection.fromPosition(TextPosition(offset: textBeforeCursor.length + 2));
    // _commentController.text += s;
  }
  
  
}
