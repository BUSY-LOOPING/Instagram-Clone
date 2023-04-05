// ignore_for_file: public_member_api_docs, sort_constructors_first

class Notification {
  String notifId;
  NotifType notifType;
  String datePublished;
  bool doWeFollow;
  String? profImage;
  String personId;
  bool personProfilePrivate;
  String personUsername;
  String? postId;
  String? reelID;
  String? extraContent;

  Notification({
    required this.notifId,
    required this.notifType,
    required this.datePublished,
    required this.doWeFollow,
    required this.profImage,
    required this.personId,
    required this.personUsername,
    this.personProfilePrivate = false,
    this.postId,
    this.reelID,
    this.extraContent,
  })  : assert(notifType == NotifType.weStartedFollowing ? doWeFollow : true),
        assert(postId == null ||
            reelID ==
                null); //1 notification cannot point to both a post and a reel; it can be only 1

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notifId': notifId,
      'notifType': notifType.index,
      'datePublished': datePublished,
      'doWeFollow': doWeFollow,
      'profImage': profImage,
      'personId': personId,
      'personUsername': personUsername,
      'personProfilePrivate': personProfilePrivate,
      'postId': postId,
      'reelID': reelID,
      'extraContent': extraContent,
    };
  }

  static Notification fromMap(Map<String, dynamic> map) {
    return Notification(
      notifId: map['notifId'] as String,
      notifType: NotifType.values[map['notifType'] as int],
      datePublished: map['datePublished'] as String,
      doWeFollow: map['doWeFollow'] as bool,
      profImage: map['profImage'] != null ? map['profImage'] as String : null,
      personId: map['personId'] as String,
      personUsername: map['personUsername'] as String,
      personProfilePrivate: map['personProfilePrivate'] != null
          ? map['personProfilePrivate'] as bool
          : false,
      postId: map['postId'] != null ? map['postId'] as String : null,
      reelID: map['reelID'] != null ? map['reelID'] as String : null,
      extraContent: map['extraContent'] != null ? map['extraContent'] as String : null,
    );
  }
}

enum NotifType {
  followReq, //when we receive someone's request
  acceptedReq, //when someone accepts our request
  startedFollowingUs, //when someone start following us
  weStartedFollowing, //when we start following someon
  likePost,
  likeReel,
  likeStory,
  commentPost,
  commentReel,
  commentLike,
}

extension NotifTypeExtension on NotifType {
  String getFormattedString(String username) {
    switch (this) {
      case NotifType.followReq:
        return '$username wants to follow you.';
      case NotifType.acceptedReq:
        return '$username accepted your request to follow.';
      case NotifType.weStartedFollowing:
        return 'You started following $username.';
      case NotifType.likePost:
        return '$username liked your post.';
      case NotifType.likeReel:
        return '$username liked your reel';
      case NotifType.commentPost:
        return '$username commented on your post';

      default:
        return '';
    }
  }
}
