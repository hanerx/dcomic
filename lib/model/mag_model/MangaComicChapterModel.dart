import 'dart:io';

import 'package:dcomic/model/baseModel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';

import 'MangaComicDetailModel.dart';

class MangaComicChapterModel extends BaseModel {
  Chapter chapter;
  final EditMode mode;
  final String outputPath;

  List<String> _data = [];
  List<String> rawPath = [];
  TextEditingController chapterIdController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  MangaComicChapterModel(this.chapter, this.mode, this.outputPath);

  Future<void> init() async {
    if (mode == EditMode.edit) {
      chapterIdController.text = chapter.chapterId;
      titleController.text = chapter.title;
      _data = chapter.data;
      notifyListeners();
    }
  }

  void reOrderGroup(int oldIndex, int newIndex) {
    var tmp = _data[oldIndex];
    _data[oldIndex] = _data[newIndex];
    _data[newIndex] = tmp;
    tmp=rawPath[oldIndex];
    rawPath[oldIndex]=rawPath[newIndex];
    rawPath[newIndex]=rawPath[oldIndex];
    notifyListeners();
  }

  Chapter delete() {
    chapter.delete = true;
    return chapter;
  }

  Chapter getChapter() {
    if (chapter == null) {
      chapter = Chapter();
    }
    chapter.chapterId = chapterIdController.text;
    chapter.title = titleController.text;
    chapter.timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    chapter.data = _data;
    return chapter;
  }

  Future<void> addPage() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);
    try {
      var directory = Directory('$outputPath/temp/data/');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      var filename =
          '${DateTime.now().millisecondsSinceEpoch ~/ 100}${result.files.single.name}';
      await File(result.files.single.path).copy('$outputPath/temp/data/$filename');
      _data.add('./data/$filename');
      rawPath.add('$outputPath/temp/data/$filename');
      notifyListeners();
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'uploadCoverFailed');
    }
  }

  void deletePage(index) {
    if (index >= 0 && index < _data.length) {
      _data.removeAt(index);
      rawPath.removeAt(index);
      notifyListeners();
    }
  }

  List<String> get data => _data;
}
