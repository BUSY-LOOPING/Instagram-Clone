import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Comment {
  String commentId;
  String content;
  String username;
  String uid;
  String? profImage;
  String datePublished;
  List? likes;
  List? replies;
  
  Comment({
    required this.commentId,
    required this.content,
    required this.username,
    required this.uid,
    this.profImage,
    required this.datePublished,
    required this.likes,
    this.replies,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'commentId': commentId,
      'content': content,
      'username': username,
      'uid': uid,
      'profImage': profImage,
      'datePublished': datePublished,
      'likes': likes,
      'replies': replies,
    };
  }

  static Comment fromMap(Map<String, dynamic> map) {
    return Comment(
      commentId: map['commentId'] as String,
      content: map['content'] as String,
      username: map['username'] as String,
      uid: map['uid'] as String,
      profImage: map['profImage'] != null ? map['profImage'] as String : null,
      datePublished: map['datePublished'] as String,
      likes:map['likes'] != null ? map['likes'] as List<dynamic>  : null,
      replies: map['replies'] != null ? map['replies'] as List<dynamic> : null,
    );
  }
}
