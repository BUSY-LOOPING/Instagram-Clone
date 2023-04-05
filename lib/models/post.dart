import 'dart:core';

class Post {
  final String postId;
  String? caption;
  final String username;
  final String uid;
  final String? profImage;
  final String datePublished;
  final Map<String, dynamic> mapIdPost;
  final List likes;
  final bool fitCover;
  final int noComments;

  Post({
    required this.postId,
    required this.caption,
    required this.username,
    required this.uid,
    required this.profImage,
    required this.datePublished,
    required this.mapIdPost,
    required this.likes,
    required this.noComments,
    this.fitCover = true,
  });

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "caption": caption,
        "username": username,
        "uid": uid,
        "profImage": profImage,
        "datePublished": datePublished,
        "mapIdPost": mapIdPost,
        "likes": likes,
        "fitCover": fitCover,
        "noComments" : noComments
      };

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['postId'],
      caption: map['caption'],
      username: map['username'],
      uid: map['uid'],
      profImage: map['profImage'],
      datePublished: map['datePublished'],
      mapIdPost: map['mapIdPost'] as Map<String, dynamic>,
      likes: map['likes'],
      fitCover: map['fitCover'],
      noComments: map['noComments'] == null ? 0 : map['noComments'] as int,
    );
  }
}
