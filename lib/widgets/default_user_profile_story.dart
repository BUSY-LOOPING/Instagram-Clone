import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/color.dart';

class DefaultUserBubble extends StatefulWidget {
  final double radius;
  final String? imagePath;
  final bool isStoryPresent;
  final double borderRadius;
  final Color borderColor;

  const DefaultUserBubble(
      {super.key,
      required this.radius,
      this.imagePath,
      this.isStoryPresent = false,
      this.borderRadius = 0.0,
      this.borderColor = primaryColor});

  @override
  State<DefaultUserBubble> createState() => _DefaultUserBubbleState();
}

class _DefaultUserBubbleState extends State<DefaultUserBubble> {
  @override
  Widget build(BuildContext context) {
    Widget placeholderWidget = Container(
      alignment: Alignment.center,
      color: Colors.grey,
      child: Icon(
        Icons.person,
        size: widget.radius + 2,
      ),
    );

    return Stack(
      );
  }
}
