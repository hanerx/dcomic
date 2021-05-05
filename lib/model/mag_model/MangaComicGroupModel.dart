import 'package:dcomic/model/baseModel.dart';
import 'package:flutter/cupertino.dart';

import 'MangaComicDetailModel.dart';

class MangaComicGroupModel extends BaseModel {
  GroupObject group;
  final EditMode mode;
  final String outputPath;

  TextEditingController groupIdController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  List<Chapter> _data = [];

  MangaComicGroupModel(
    this.group,
    this.mode, this.outputPath,
  );

  Future<void> init() async {
    if (mode == EditMode.edit) {
      groupIdController.text = group.groupId;
      titleController.text = group.title;
      _data = group.chapters;
      notifyListeners();
    }
  }

  GroupObject delete() {
    group.delete = true;
    return group;
  }

  GroupObject getGroup() {
    if (group == null) {
      group = GroupObject();
    }
    group.title = titleController.text;
    group.groupId = groupIdController.text;
    group.chapters = _data;
    return group;
  }

  void reOrderGroup(oldIndex, newIndex) {
    var tmp = _data[oldIndex];
    _data[oldIndex] = _data[newIndex];
    _data[newIndex] = tmp;
    notifyListeners();
  }

  List<Chapter> get data => _data;

  void addChapter(Chapter chapter) {
    _data.add(chapter);
    notifyListeners();
  }

  void deleteChapter(int index) {
    if (index >= 0 && index < _data.length) {
      _data.removeAt(index);
      notifyListeners();
    }
  }

  void updateChapter(int index, Chapter result) {
    if (index >= 0 && index < _data.length) {
      _data[index] = result;
      notifyListeners();
    }
  }
}
