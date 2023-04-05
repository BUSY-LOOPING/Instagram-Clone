import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ImageFileModel {
  List<String> files;
  String folder;

  ImageFileModel({
    required this.files,
    required this.folder,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'files': files,
      'folder': folder,
    };
  }

  static ImageFileModel fromMap(Map<String, dynamic> map) {
    return ImageFileModel(
        files: List<String>.from(
          (List<String>.from(map['files'])),
        ),
        folder: map['folderName'].toString());
  }

  String toJson() => json.encode(toMap());

  static ImageFileModel fromJson(String source) =>
      ImageFileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class VideoFileModel {
  List<String> files;
  List<String> duration;
  String folder;

  VideoFileModel({
    required this.files,
    required this.folder,
    required this.duration,
  });

  static VideoFileModel fromMap(Map<String, dynamic> map) {
    var videoFileModel = VideoFileModel(
      files: List<String>.from((map['files'] as List<dynamic>)
          .map((e) => e['path'].toString())
          .toList()),
      folder: map['folderName'].toString(),
      duration: List<String>.from((map['files'] as List<dynamic>)
          .map((e) => e['duration'].toString())
          .toList()),
    );
    assert(videoFileModel.files.length == videoFileModel.duration.length);
    return videoFileModel;
  }
}
