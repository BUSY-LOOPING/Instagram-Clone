import 'package:flutter/material.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/screens/default_user_profile.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/utils/utils.dart';

import '../screens/profile_screen.dart';

class CommentCard extends StatefulWidget {
  final bool isHeader;
  final Comment? comment;
  final Post? post;

  const CommentCard({
    super.key,
    required this.comment,
    this.isHeader = false,
    this.post,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard>
    with AutomaticKeepAliveClientMixin<CommentCard> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String? desc =
        widget.isHeader ? widget.post?.caption : widget.comment?.content;
    if (desc != null && desc.isEmpty) {
      desc = null;
    }
    return widget.comment == null && widget.post == null
        ? Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text('Something went wrong!'),
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              border: widget.isHeader
                  ? Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 62, 62, 62),
                        width: 0.1,
                      ),
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: widget.isHeader ? 12 : 10, horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: desc != null
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ProfileScreen.routeName,
                        arguments: <String, Object?>{
                          'uid': widget.isHeader
                              ? widget.post!.uid
                              : widget.comment!.uid
                        },
                      );
                    },
                    child: DefaultUserProfileView(
                        hasStory: false,
                        radius: 14,
                        imagePath: widget.isHeader
                            ? widget.post!.profImage
                            : widget.comment!.profImage),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        // vertical: 5,
                        horizontal: 10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ProfileScreen.routeName,
                                arguments: <String, Object?>{
                                  'uid': widget.isHeader
                                      ? widget.post!.uid
                                      : widget.comment!.uid
                                },
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.isHeader
                                        ? widget.post!.username
                                        : widget.comment!.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: const SizedBox(
                                      width: 8,
                                    ),
                                  ),
                                  TextSpan(
                                    text: beatifiedMiniReadableTime(
                                        DateTime.parse(widget.isHeader
                                            ? widget.post!.datePublished
                                            : widget.comment!.datePublished)),
                                    style: TextStyle(
                                        color: secondaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12),
                                  ),
                                ],
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          desc != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5.0,
                                  ),
                                  child: Text(
                                    desc,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          widget.isHeader
                              ? const SizedBox()
                              : RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: secondaryColor.shade400,
                                    ),
                                    children: [
                                      TextSpan(text: 'Reply'),
                                      const WidgetSpan(
                                        child: SizedBox(
                                          width: 15,
                                        ),
                                      ),
                                      TextSpan(text: 'Send'),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  widget.isHeader
                      ? const SizedBox()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              color: secondaryColor,
                              size: 18,
                            ),
                            Text(
                              '${widget.comment!.likes?.length ?? 0}',
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          );
  }
}
