// ignore_for_file: no_duplicate_case_values

import 'package:flutter/material.dart';
import 'package:instagram_clone/models/notification.dart' as model;
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/button.dart';
import 'package:instagram_clone/screens/default_user_profile.dart';
import 'package:instagram_clone/utils/color.dart';

import '../models/user.dart';
import '../utils/utils.dart';

class NotificationCard extends StatefulWidget {
  final model.Notification notification;
  final User currentUser;

  const NotificationCard(
      {super.key, required this.notification, required this.currentUser});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with AutomaticKeepAliveClientMixin<NotificationCard> {
  final _btnPadding = const EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 12,
  );
  bool _btn1Loading = false, _btn2Loading = false;

  RichText getRichText(model.Notification notification) {
    List<InlineSpan>? children;
    TextStyle boldStyle = TextStyle(
      fontWeight: FontWeight.w600,
    );

    switch (notification.notifType) {
      case model.NotifType.followReq:
        children = [
          TextSpan(text: notification.personUsername, style: boldStyle),
          TextSpan(text: ' wants to follow you. '),
          TextSpan(
            text: beatifiedMiniReadableTime(
              DateTime.parse(notification.datePublished),
            ),
            style: TextStyle(
              color: secondaryColor,
            ),
          ),
        ];
        break;
      case model.NotifType.acceptedReq:
        children = [
          TextSpan(text: notification.personUsername, style: boldStyle),
          TextSpan(text: ' accepted your request to follow. '),
          TextSpan(
            text: beatifiedMiniReadableTime(
              DateTime.parse(notification.datePublished),
            ),
            style: TextStyle(
              color: secondaryColor,
            ),
          ),
        ];
        break;
      case model.NotifType.weStartedFollowing:
        children = [
          TextSpan(text: 'You are now following '),
          TextSpan(text: notification.personUsername, style: boldStyle),
          TextSpan(text: '. '),
          TextSpan(
            text: beatifiedMiniReadableTime(
              DateTime.parse(notification.datePublished),
            ),
            style: TextStyle(
              color: secondaryColor,
            ),
          ),
        ];
        break;
      case model.NotifType.likePost:
        break;
      case model.NotifType.likeReel:
        break;
      case model.NotifType.commentPost:
        break;
      case model.NotifType.followReq:
        break;
      case model.NotifType.acceptedReq:
        break;
      case model.NotifType.startedFollowingUs:
        children = [
          TextSpan(text: notification.personUsername, style: boldStyle),
          TextSpan(text: ' started following you. '),
          TextSpan(
            text: beatifiedMiniReadableTime(
              DateTime.parse(notification.datePublished),
            ),
            style: TextStyle(
              color: secondaryColor,
            ),
          ),
        ];
        break;
      case model.NotifType.likePost:
        break;
      case model.NotifType.likeReel:
        break;
      case model.NotifType.likeStory:
        break;
      case model.NotifType.commentPost:
        break;
      case model.NotifType.commentReel:
        break;
    }
    RichText richText = RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 15.5),
        children: children,
      ),
    );
    return richText;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InkWell(
      onTap: () {},
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            DefaultUserProfileView(
              hasStory: false,
              radius: 18,
              imagePath: widget.notification.profImage,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          // vertical: 10,
                          horizontal: 12,
                        ),
                        child: getRichText(widget.notification),
                      ),
                    ),
                    widget.notification.notifType != model.NotifType.followReq
                        ? BaseButton(
                            btnLoading: _btn1Loading,
                            borderRadius: 8,
                            text: widget.notification.doWeFollow
                                ? 'Following'
                                : 'Follow',
                            onTapAction: () {
                              if (!widget.notification.doWeFollow) {
                                setState(() {
                                  _btn1Loading = true;
                                });
                                FirestoreMethods()
                                    .commitFollow(
                                  currentUserUID: widget.currentUser.uid,
                                  currentUserUsername:
                                      widget.currentUser.username,
                                  secUserUsername:
                                      widget.notification.personUsername,
                                  isPrivateProf:
                                      widget.notification.personProfilePrivate,
                                  doesSecUserFollow:
                                      widget.currentUser.followers?.contains(
                                              widget.notification.personId) ??
                                          false,
                                  secUserUID: widget.notification.personId,
                                )
                                    .then((value) {
                                  setState(() {
                                    _btn1Loading = false;
                                  });
                                });
                              }
                            },
                            btnColor: widget.notification.doWeFollow
                                ? grey1
                                : blueColor,
                            padding: _btnPadding,
                          )
                        : Row(
                            children: [
                              BaseButton(
                                btnLoading: _btn1Loading,
                                borderRadius: 8,
                                text: 'Confirm',
                                onTapAction: () {
                                  setState(() {
                                    _btn1Loading = true;
                                  });
                                  FirestoreMethods()
                                      .commitAcceptFollowReq(
                                    currentUserUID: widget.currentUser.uid,
                                    secUserUID: widget.notification.personId,
                                  )
                                      .then((value) {
                                    setState(() {
                                      _btn1Loading = false;
                                    });
                                  });
                                },
                                btnColor: blueColor,
                                padding: _btnPadding,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: BaseButton(
                                  btnLoading: _btn2Loading,
                                  borderRadius: 8,
                                  text: 'Delete',
                                  onTapAction: () {
                                    setState(() {
                                      _btn2Loading = true;
                                    });
                                    FirestoreMethods()
                                        .commitRemoveFollowReq(
                                      currentUserUID: widget.currentUser.uid,
                                      secUserUID: widget.notification.personId,
                                    )
                                        .then((value) {
                                      setState(() {
                                        _btn2Loading = false;
                                      });
                                    });
                                  },
                                  btnColor: grey1,
                                  padding: _btnPadding,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
