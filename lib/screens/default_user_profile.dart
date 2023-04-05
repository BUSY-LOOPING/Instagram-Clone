import 'package:avatar_view/avatar_view.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'dart:math' as math;

class DefaultUserProfileView extends StatefulWidget {
  final double radius, borderWidth;
  final String? imagePath;
  final Color? borderColor;
  final bool hasStory;
  const DefaultUserProfileView({
    super.key,
    required this.radius,
    required this.imagePath,
    this.borderColor,
    this.borderWidth = 0.0,
    this.hasStory = false,
  });

  @override
  State<DefaultUserProfileView> createState() => _DefaultUserProfileViewState();
}

class _DefaultUserProfileViewState extends State<DefaultUserProfileView> {
  late Widget placeholderWidget;

  @override
  void initState() {
    super.initState();
    placeholderWidget = Container(
      alignment: Alignment.center,
      color: Colors.grey,
      child: Icon(
        Icons.person,
        size: widget.radius + 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kGradientBoxDecoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [
            insta_light_yellow,
            insta_orange,
            insta_pink,
            insta_purple,
            insta_blue
          ],
        ),
        border: Border.all(
          color: Colors.red,
        ),
        shape: BoxShape.circle
        // borderRadius: BorderRadius.circular(32),
        );

    // final kInnerDecoration = BoxDecoration(
    //   color: Colors.black,
    //   shape: BoxShape.circle,
    //   border: Border.all(color: Colors.black, width: 2),
    //   // borderRadius: BorderRadius.circular(32),
    // );

    return CircularStepProgressIndicator(
      roundedCap: ((p0, p1) {
        return true;
      }),
      width: widget.radius + 32,
      height: widget.radius + 32,
      startingAngle: 0,
      padding: 0,
      arcSize: widget.hasStory ? -math.pi * 2 : 0,
      circularDirection: CircularDirection.clockwise,
      stepSize: 2.5,
      selectedColor: insta_light_yellow,
      gradientColor: LinearGradient(
        colors: [
          insta_light_yellow,
          insta_orange,
          insta_pink,
          insta_purple,
          insta_blue
        ],
        begin: Alignment.bottomLeft
      ),
      totalSteps: 12,
      child: Center(
        child: SizedBox(
          width: widget.radius + 23,
          height: widget.radius + 23,
          child: AvatarView(
            borderColor: widget.borderColor,
            borderWidth: widget.borderWidth,
            // radius: widget.radius,
            isOnlyText: false,
            imagePath: widget.imagePath ?? 'http',
            backgroundColor: Colors.grey,
            placeHolder: placeholderWidget,
            errorWidget: placeholderWidget,
          ),
        ),
      ),
    );

    // return Container(
    //   decoration: kGradientBoxDecoration,
    //   child: Container(
    //     color: Colors.transparent,
    //     padding: const EdgeInsets.all(2.0),
    //     child: AvatarView(
    //       borderColor: widget.borderColor,
    //       borderWidth: widget.borderWidth,
    //       radius: widget.radius,
    //       isOnlyText: false,
    //       imagePath: widget.imagePath ?? 'http',
    //       backgroundColor: Colors.grey,
    //       placeHolder: placeholderWidget,
    //       errorWidget: placeholderWidget,
    //     ),
    //   ),
    // );
  }
}
