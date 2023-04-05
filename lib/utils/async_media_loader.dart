import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/utils/utils.dart';

class AsyncMediaLoader extends StatefulWidget {
  final BoxFit boxFit;
  final String? url;
  final String? localPath;
  final Widget? placeholder;
  final Widget? errorholder;

  AsyncMediaLoader({
    super.key,
    this.placeholder,
    this.errorholder,
    required this.localPath,
    required this.url,
    this.boxFit = BoxFit.cover,
  });

  @override
  State<AsyncMediaLoader> createState() => _AsyncMediaLoaderState();
}

class _AsyncMediaLoaderState extends State<AsyncMediaLoader>
    with AutomaticKeepAliveClientMixin<AsyncMediaLoader> {
  Completer<Uint8List> completer = Completer();

  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      // CachedNetworkImageProvider imageProvider =
      //     CachedNetworkImageProvider(widget.url!);

      // Image image = Image(
      //   image: imageProvider,
      //   fit: widget.boxFit,
      // );
      // image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener(
      //     (ImageInfo info, bool synchronousCall) =>
      //         completer.complete(info.image)));
    } else {
      Future<Uint8List> future = readFileByte(widget.localPath!);
      future.then((value) {
        print('length === ${value.length}');
        completer.complete(value);
      }).onError(
        (error, stackTrace) {
          print(
              '+++++++++ ERRORRR +++++++++++${error.toString()}, ${stackTrace.toString()}');
          completer.completeError(error ?? '');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return getFutureBuilder(completer.future);
  }

  FutureBuilder<Uint8List> getFutureBuilder(Future<Uint8List> future) {
    return FutureBuilder<Uint8List>(
      future: future,
      builder: ((context, snapshot) {
        // if (widget.url != null) {
        //   AsyncSnapshot<ui.Image> newSnap = snapshot as AsyncSnapshot<ui.Image>;
        if (snapshot.hasData) {
          //     return RawImage(
          //       height: newSnap.data!.height.toDouble(),
          //       width: newSnap.data!.width.toDouble(),
          //       image: newSnap.data!,
          //       fit: widget.boxFit,
          //     );
          //   } else {
          return Image.memory(
            (snapshot).data!,
            fit: widget.boxFit,
          );
          // }
        } else if (snapshot.connectionState == ConnectionState.waiting && widget.placeholder != null) {
          return widget.placeholder!;
        } else {
          return widget.errorholder ??
              Container(
                decoration: BoxDecoration(color: Colors.grey[900]),
              );
        }
      }),
    );
  }

  @override
  bool get wantKeepAlive => false;
}
