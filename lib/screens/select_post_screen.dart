// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:avatar_view/avatar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storage_path/flutter_storage_path.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram_clone/models/file_model.dart';

import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/utils/sticky_sliver_header.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:video_player/video_player.dart';

class GeneralFile {
  final String path;
  final String duration;
  bool isVideoFile = false;

  GeneralFile({
    required this.path,
    this.isVideoFile = false,
    this.duration = '0:00',
  });

  static List<GeneralFile> fromImageFileModel(ImageFileModel fileModel) {
    return fileModel.files
        .map((String path) => GeneralFile(path: path, isVideoFile: false))
        .toList();
  }

  static List<GeneralFile> fromVideoFileModel(VideoFileModel fileModel) {
    var res = <GeneralFile>[];
    for (int i = 0; i < fileModel.files.length; i++) {
      res.add(GeneralFile(
          path: fileModel.files[i],
          isVideoFile: true,
          duration: fileModel.duration[i]));
    }
    return res;
  }
}

class SelectPostScreen extends StatefulWidget {
  const SelectPostScreen({super.key});

  @override
  State<SelectPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<SelectPostScreen>
    with SingleTickerProviderStateMixin {
  int _selectedOptionToPost = 0;
  bool _selectMultiple = false,
      _selectMultipleExpanded = true,
      _fitCover = true;
  late VideoPlayerController _videoController;
  late FToast fToast;

  List<GeneralFile> files = [];
  List<int> selectedIndexLst = [];

  @override
  void initState() {
    super.initState();
    // PaintingBinding.instance.imageCache.maximumSizeBytes =
    //     1024 * 1024 * 50;
    // 50MB
    fToast = FToast();
    fToast.init(context);
    getImagesPath();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void onPostToChange(int selectedOption) {
    setState(() {
      _selectedOptionToPost = selectedOption;
    });
  }

  void selectMultipleToggle() {
    setState(() {
      if (_selectMultipleExpanded) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          setState(() {
            _selectMultipleExpanded = false;
          });
        });
      }
      _selectMultiple = !_selectMultiple;
      if (!_selectMultiple) {
        selectedIndexLst.clear();
      }
    });
  }

  Future<void> getImagesPath() async {
    try {
      var imagePath = await StoragePath.imagesPath;
      // var videoPath = await StoragePath
      //     .videoPath; //contains images, video path and folder name in json format
      List<GeneralFile> newList = [];

      if (imagePath != null) {
        var images = await jsonDecode(imagePath) as List<dynamic>;
        var fileModelLst =
            images.map((model) => ImageFileModel.fromMap(model)).toList();
        for (var element in fileModelLst) {
          newList.addAll(GeneralFile.fromImageFileModel(element));
        }
      }
      // if (videoPath != null) {
        // var videos = await jsonDecode(videoPath) as List<dynamic>;

        // // print('videos ${videos[0]}');
        // var fileModelLst =
        //     videos.map((model) => VideoFileModel.fromMap(model)).toList();
        // fileModelLst.forEach((VideoFileModel element) {
        //   newList.addAll(GeneralFile.fromVideoFileModel(element));
        // });
      // }

      setState(() {
        files = newList;
        if (files.isNotEmpty) {
          selectedIndexLst.add(0);
        }
      });
    } catch (err) {
      print(err);
    }
  }

  void fileTapped(int index) {
    setState(() {
      if (!_selectMultiple) {
        selectedIndexLst.clear();
        selectedIndexLst.add(index);
      } else {
        int idx = selectedIndexLst.indexOf(index);
        if (idx == -1) {
          selectedIndexLst.add(index);
        } else {
          selectedIndexLst.removeAt(idx);
          if (selectedIndexLst.isEmpty) {
            _selectMultiple = false;
          }
        }
      }
    });
  }

  void fileLongPress(int index) {
    setState(() {
      _selectMultiple = true;
      int idx = selectedIndexLst.indexOf(index);
      if (idx == -1) {
        selectedIndexLst.add(index);
      } else {
        selectedIndexLst.removeAt(idx);
        if (selectedIndexLst.isEmpty) {
          _selectMultiple = false;
        }
      }
    });
  }

  void toggleFitType() {
    setState(() {
      _fitCover = !_fitCover;
    });
  }

  void navigateNext() {
    if (selectedIndexLst.isEmpty) {
      showToast(fToast: fToast, toastMsg: 'Select atleast 1 media');
    } else {
      Map<String, dynamic> map = {};
      var list = <GeneralFile>[];
      for (var i in selectedIndexLst) {
        list.add(files[i]);
      }
      map['posts'] = list;
      map['postTo'] = _selectedOptionToPost;
      map['fitCover'] = _fitCover;
      Navigator.pushNamed(context, '/newPost', arguments: map);
    }
  }

  @override
  Widget build(BuildContext context) {
    var headerChild = Container(
      color: mobileBgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text(
              'Gallery',
              style: TextStyle(
                color: primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: selectMultipleToggle,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(500),
                      ),
                      color: _selectMultiple ? blueColor : Colors.grey[800],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 8),
                      child: Row(
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: Icon(
                              Icons.filter_none_rounded,
                              size: 18,
                            ),
                          ),
                          AnimatedSize(
                            curve: Curves.easeIn,
                            duration: Duration(milliseconds: 350),
                            child: SizedBox(
                              width: _selectMultipleExpanded ? 7 : 0,
                            ),
                          ),
                          AnimatedSize(
                            curve: Curves.easeIn,
                            duration: Duration(milliseconds: 350),
                            child: SizedBox(
                              width: _selectMultipleExpanded ? null : 0,
                              child: Text(
                                'SELECT MULTIPLE',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0),
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
    if (selectedIndexLst.isNotEmpty) {
      // _videoController = VideoPlayerController.file(File(
      //   files[selectedIndexLst[selectedIndexLst.length - 1]].path,
      // ));
      // _videoController.initialize().then((value) => _videoController.play());
    }
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: mobileBgColor,
              // ignore: prefer_const_literals_to_create_immutables
              actions: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    padding: const EdgeInsets.all(12.0),
                    onPressed: navigateNext,
                    icon: Icon(
                      Icons.arrow_back,
                      color: blueColor,
                      size: 30,
                    ),
                  ),
                ),
              ],
              floating: true,
              leading: IconButton(
                padding: const EdgeInsets.all(0),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close_sharp,
                  size: 30,
                ),
              ),
              title: Text(
                'New ${_selectedOptionToPost == 0 ? 'Post' : (_selectedOptionToPost == 1 ? 'Story' : 'Reel')}',
                style: TextStyle(
                  color: primaryColor,
                  // fontWeight: FontWeight.w600,
                  // fontSize: 20,
                ),
              ),
              // toolbarHeight: 60,
              pinned: true,
              stretch: true,
              expandedHeight: 450,
              snap: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned(
                      top: 60,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: selectedIndexLst.isEmpty
                          ? Container(
                              color: mobileBgColor,
                            )
                          : (files[selectedIndexLst[
                                      selectedIndexLst.length - 1]]
                                  .isVideoFile
                              ? VideoPlayer(_videoController)
                              : Image.file(
                                  File(
                                    files[selectedIndexLst[
                                            selectedIndexLst.length - 1]]
                                        .path,
                                  ),
                                  fit:
                                      _fitCover ? BoxFit.cover : BoxFit.contain,
                                )),
                    ),
                    Positioned(
                        bottom: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: toggleFitType,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Transform.rotate(
                                    angle: -math.pi / 4,
                                    child: Icon(
                                      Icons.arrow_back_ios_new,
                                      color: primaryColor,
                                      size: 13,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Transform.rotate(
                                    angle: math.pi - math.pi / 4,
                                    child: Icon(
                                      Icons.arrow_back_ios_new,
                                      color: primaryColor,
                                      size: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
                stretchModes: const [
                  StretchMode.zoomBackground,
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(),
            ),
            StickySliverHeader(child: headerChild),
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                addAutomaticKeepAlives: true,
                childCount: files.length,
                (context, index) {
                  return GestureDetector(
                    onTap: () => fileTapped(index),
                    onLongPress: () => fileLongPress(index),
                    child: GalleryGridWidget(
                      key: ValueKey(index),
                      generalFile: files[index],
                      selectMultiple: _selectMultiple,
                      currIdx: index,
                      selectedIndexLst: selectedIndexLst,
                    ),
                  );
                },
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.all(
            Radius.circular(300),
          ),
        ),
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            GestureDetector(
              onTap: () => onPostToChange(0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'POST',
                    style: TextStyle(
                      letterSpacing: 1.9,
                      color: _selectedOptionToPost == 0
                          ? primaryColor
                          : primaryColor.withOpacity(0.5),
                      fontSize: 15,
                      fontWeight: _selectedOptionToPost == 0
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onPostToChange(1),
              child: Center(
                child: Text(
                  'STORY',
                  style: TextStyle(
                    letterSpacing: 1.9,
                    color: _selectedOptionToPost == 1
                        ? primaryColor
                        : primaryColor.withOpacity(0.5),
                    fontSize: 15,
                    fontWeight: _selectedOptionToPost == 1
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onPostToChange(2),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'REEL',
                    style: TextStyle(
                      letterSpacing: 1.9,
                      color: _selectedOptionToPost == 2
                          ? primaryColor
                          : primaryColor.withOpacity(0.5),
                      fontSize: 15,
                      fontWeight: _selectedOptionToPost == 2
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildGridItem(BuildContext context, int index) {
    int selectedIndex = selectedIndexLst.indexOf(index);
    var localFile = File(
      files[index].path,
    );
    if (files[index].isVideoFile) {
      _videoController = VideoPlayerController.file(localFile);
      _videoController.initialize();
      // _videoController.setLooping(true);
      // _videoController.play();
    }
    // int selectedIndex = -1;

    return GestureDetector(
      onTap: () => fileTapped(index),
      onLongPress: () => fileLongPress(index),
      child: Container(
        color: Colors.amber,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              // child: Image.file(
              //   File(files[index].path),
              //   fit: BoxFit.cover,
              //   cacheHeight: 200,
              //   cacheWidth: 200,
              // ),

              child: !files[index].isVideoFile
                  ? Image.file(
                      localFile,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      cacheHeight: 200,
                      cacheWidth: 200,
                    )
                  : VideoPlayer(_videoController),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                height: _selectMultiple ? 28 : 0,
                width: _selectMultiple ? 28 : 0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.0),
                  color: selectedIndex == -1
                      ? primaryColor.withOpacity(0.2)
                      : blueColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    selectedIndex == -1 ? '' : '${selectedIndex + 1}',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Text(
                files[index].isVideoFile
                    ? readableTime(
                        Duration(
                          milliseconds: int.parse(files[index].duration),
                        ),
                      )
                    : '',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryGridWidget extends StatefulWidget {
  final GeneralFile generalFile;
  final bool selectMultiple;
  final int currIdx;
  final List<int> selectedIndexLst;

  const GalleryGridWidget({
    super.key,
    required this.generalFile,
    required this.selectMultiple,
    required this.currIdx,
    required this.selectedIndexLst,
  });

  @override
  State<GalleryGridWidget> createState() => _GalleryGridWidgetState();
}

class _GalleryGridWidgetState extends State<GalleryGridWidget>
    with AutomaticKeepAliveClientMixin<GalleryGridWidget> {
  late VideoPlayerController _videoController;
  int _selectedIndex = 0;
  late File _localFile;
  // final Completer<Uint8List> _completer2 = Completer();

  void searchSelectedIdx() async {
    setState(() {
      _selectedIndex = widget.selectedIndexLst.indexOf(widget.currIdx);
    });
  }

  @override
  void initState() {
    super.initState();
    _localFile = File(
      widget.generalFile.path,
    );

    if (widget.generalFile.isVideoFile) {
      _videoController = VideoPlayerController.file(_localFile);
      _videoController.initialize();
      // _videoController.setLooping(true);
    } else {
      readData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void readData() async {
    // await readFileByte(widget.generalFile.path)
    //     .then((value) => _completer2.complete(value));

    // Image postImg = Image(
    //   image: imageProvider,
    //   fit: BoxFit.cover,
    // );

    // postImg.image
    //     .resolve(
    //       ImageConfiguration(),
    //     )
    //     .addListener(
    //       ImageStreamListener(
    //         (ImageInfo info, bool synchronousCall) =>
    //             _completer.complete(info.image),
    //       ),
    //     );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // searchSelectedIdx();
    _selectedIndex = widget.selectedIndexLst.indexOf(widget.currIdx);
    var containerDim = widget.selectMultiple ? 28.0 : 0.0;
    return Container(
      color: secondaryColor.shade900,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: !widget.generalFile.isVideoFile
                ? 
                // Container()
                Image.file(
                    File(widget.generalFile.path),
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                    cacheHeight: 200,
                    cacheWidth: 200,
                  )
                // FutureBuilder<Uint8List>(
                //     future: _completer2.future,
                //     builder: ((context, snapshot) {
                //       if (snapshot.hasData) {
                //         return Image.memory(
                //           snapshot.data!,
                //           fit: BoxFit.cover,
                //         );
                //       } else {
                //         return Container(
                //           color: secondaryColor.shade900,
                //         );
                //       }
                //     }))
                : VideoPlayer(_videoController),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              height: containerDim,
              width: containerDim,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.0),
                color: _selectedIndex == -1
                    ? primaryColor.withOpacity(0.2)
                    : blueColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _selectedIndex == -1 ? '' : '${_selectedIndex + 1}',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Text(
              widget.generalFile.isVideoFile
                  ? readableTime(
                      Duration(
                        milliseconds: int.parse(widget.generalFile.duration),
                      ),
                    )
                  : '',
              style: TextStyle(
                color: primaryColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;
}
