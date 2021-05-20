import 'dart:io';

import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/mag_model/baseMangaModel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';

class MangaComicDetailModel extends BaseModel {
  final EditMode mode;
  final MangaObject mangaObject;
  final String outputPath;

  String _cover;
  String rawPath;
  List<TagObject> _tags = [];
  List<TagObject> _authors = [];
  List<GroupObject> _data = [];
  TextEditingController comicIdController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController coverController = TextEditingController();

  String error;

  MangaComicDetailModel(this.mode, this.mangaObject, this.outputPath);

  List<TagObject> get tags => _tags;

  List<TagObject> get authors => _authors;

  List<GroupObject> get data => _data;

  String get cover => rawPath;

  bool get hasCover => _cover != null;

  Future<void> init()async{
    if(mode==EditMode.edit){
      _tags=mangaObject.tags;
      _authors=mangaObject.authors;
      _data=mangaObject.data.map<GroupObject>((e) => GroupObject(title: e.title,groupId: e.name,chapters: e.chapters.map<Chapter>((c) => Chapter(chapterId: c.name,timestamp: c.timestamp,title: c.title,data: c.pages)).toList())).toList();
      _cover=mangaObject.rawCover;
      coverController.text=_cover;
      comicIdController.text=mangaObject.name;
      titleController.text=mangaObject.title;
      descriptionController.text=mangaObject.description;
      statusController.text=mangaObject.status;
      notifyListeners();
    }
  }

  Future<void> uploadCover() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);
    try {
      var directory = Directory('$outputPath/temp/data/');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      var filename =
          '${DateTime.now().millisecondsSinceEpoch ~/ 100}${result.files.single.name}';
      await File(result.files.single.path).copy('$outputPath/temp/data/$filename');
      _cover='./data/$filename';
      rawPath='$outputPath/temp/data/$filename';
      coverController.text=_cover;
      notifyListeners();
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'uploadCoverFailed');
    }
  }

  void addGroup(group) {
    _data.add(group);
    notifyListeners();
  }

  void deleteGroup(index) {
    if (index >= 0 && index < _data.length) {
      _data.removeAt(index);
      notifyListeners();
    }
  }

  void updateGroup(index, group) {
    if (index >= 0 && index < _data.length) {
      _data[index] = group;
      notifyListeners();
    }
  }

  void reOrderGroup(oldIndex, newIndex) {
    var tmp = _data[oldIndex];
    _data[oldIndex] = _data[newIndex];
    _data[newIndex] = tmp;
    notifyListeners();
  }

  void deleteTag(TagObject tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  void deleteAuthor(TagObject tag) {
    _authors.remove(tag);
    notifyListeners();
  }

  void addTag(TagObject tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void addAuthor(TagObject tag) {
    _authors.add(tag);
    notifyListeners();
  }

  Future<bool> updateComic() async {
    try {
      await BaseMangaModel().encodeFromObject(toMap(), outputPath);
      return true;
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'updateComicFailed');
    }
    return false;
  }

  MangaObject toMap() {
    return MangaObject(
        comicIdController.text,
        titleController.text,
        descriptionController.text,
        authors,
        tags,
        _data.map<VolumeObject>((e) => e.toMap()).toList(),
        _cover,
        PageType.local,
        statusController.text,
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        outputPath);
  }
}

class GroupObject {
  String title;
  String groupId;
  List<Chapter> chapters;
  bool delete = false;

  GroupObject({this.title, this.groupId, this.chapters});

  VolumeObject toMap() {
    return VolumeObject(
        groupId, title, chapters.map<ChapterObject>((e) => e.toMap()).toList());
  }
}

class Chapter {
  String chapterId;
  int timestamp;
  String title;
  List<String> data;
  bool delete = false;

  Chapter({this.chapterId, this.timestamp, this.title, this.data});

  ChapterObject toMap() {
    return ChapterObject(chapterId, timestamp, 0, title, data, null, {}, null);
  }
}

enum EditMode { create, edit }