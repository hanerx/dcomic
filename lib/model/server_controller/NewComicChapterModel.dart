import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/server_controller/NewComicDetailModel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';

class NewComicChapterModel extends BaseModel {
  final IPFSSourceModel node;
  Chapter chapter;
  final EditMode mode;

  List<String> _data=[];
  TextEditingController chapterIdController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  NewComicChapterModel(this.node, this.chapter, this.mode);

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

  Future<void> addPage()async{
    var result = await FilePicker.platform.pickFiles(type: FileType.image);
    try {
      var response = await node.handler.uploadImage(result.files.single);
      if (response.statusCode == 200) {
        _data.add(response.data['data']['cid']);
        notifyListeners();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'uploadCoverFailed');
    }
  }

  void deletePage(index){
    if (index >= 0 && index < _data.length) {
      _data.removeAt(index);
      notifyListeners();
    }
  }

  List<String> get data => _data;
}
