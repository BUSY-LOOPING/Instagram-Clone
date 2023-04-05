import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'dart:ui' as ui;

import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/utils/color.dart';

import 'dart:math' as math;

class ThumbnailWidget extends StatefulWidget {
  final Post post;
  const ThumbnailWidget({
    super.key,
    required this.post,
  });

  @override
  State<ThumbnailWidget> createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget>
    with AutomaticKeepAliveClientMixin<ThumbnailWidget> {
  final Completer<ui.Image> _completer = Completer();

  @override
  void initState() {
    super.initState();
    CachedNetworkImageProvider cachedNetworkImageProvider =
        CachedNetworkImageProvider(widget.post.mapIdPost['0']);
    Image postImg = Image(
      image: cachedNetworkImageProvider,
      fit: widget.post.fitCover ? BoxFit.cover : BoxFit.contain,
    );

    postImg.image.resolve(ImageConfiguration()).addListener(ImageStreamListener(
        (ImageInfo info, bool synchronousCall) =>
            !_completer.isCompleted ? _completer.complete(info.image) : null));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: grey1,
      width: double.infinity,
      child: Stack(children: [
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          bottom: 0,
          child: getFutureBuilder(),
        ),
        widget.post.mapIdPost.length > 1
            ? Positioned(
                top: 4,
                right: 4,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: SvgPicture.asset(
                    'assets/svg/filter_none_rounded_filled.svg',
                    width: 15,
                    height: 15,
                    color: Colors.grey[200],
                  ),
                ),
              )
            : const SizedBox()
      ]),
    );
  }

  Widget getFutureBuilder() {
    return FutureBuilder(
        future: _completer.future,
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return RawImage(
              image: snapshot.data,
              fit: widget.post.fitCover ? BoxFit.cover : BoxFit.contain,
            );
          }
          return Container(
            color: grey1,
          );
        }));
  }

  @override
  bool get wantKeepAlive => true;
}
