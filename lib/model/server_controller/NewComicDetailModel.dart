import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/mag_model/baseMangaModel.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';

class NewComicDetailModel extends BaseModel {
  final EditMode mode;
  final IPFSSourceModel node;
  final String comicId;

  String _comicId;
  String _title;
  String _description;
  String _status;
  String _cover;
  List<TagObject> _tags = [];
  List<TagObject> _authors = [];
  List<GroupObject> _data = [];
  TextEditingController comicIdController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController coverController = TextEditingController();

  String error;

  NewComicDetailModel(this.mode, this.node, this.comicId);

  Future<void> init() async {
    if (mode == EditMode.edit) {
      try {
        var response = await node.handler.getComicDetail(comicId);
        if (response.statusCode == 200) {
          _title = response.data['data']['title'];
          _comicId = comicId;
          _description = response.data['data']['description'];
          _status = response.data['data']['status'];
          _cover = response.data['data']['cover'];
          _tags = response.data['data']['tags']
              .map<TagObject>((e) => TagObject(e['tag_id'], e['tag_num']))
              .toList();
          _authors = response.data['data']['authors']
              .map<TagObject>((e) => TagObject(e['tag_id'], e['tag_num']))
              .toList();
          _data = response.data['data']['data']
              .map<GroupObject>((e) => GroupObject(
                  title: e['title'],
                  groupId: e['name'],
                  chapters: e['data']
                      .map<Chapter>((c) => Chapter(
                          chapterId: c['chapter_id'],
                          title: c['title'],
                          timestamp: c['timestamp'],
                          data: c['data']
                              .map<String>((p) => p.toString())
                              .toList()))
                      .toList()))
              .toList();
          comicIdController.text = _comicId;
          titleController.text = _title;
          descriptionController.text = _description;
          statusController.text = _status;
          coverController.text = _cover;
          error = null;
          notifyListeners();
        }
      } on DioError catch (e, s) {
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: 'comicLoadingFailed');
        error = e.response.data['msg'];
      } catch (e, s) {
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: 'scomicLoadingFailed');
        error = '未知错误：$e';
      }
      notifyListeners();
    }
  }

  List<TagObject> get tags => _tags;

  List<TagObject> get authors => _authors;

  List<GroupObject> get data => _data;

  String get cover => "${node.address}/upload/ipfs/$_cover";

  bool get hasCover => _cover != null;

  Future<void> uploadCover() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);
    try {
      var response = await node.handler.uploadImage(result.files.single);
      if (response.statusCode == 200) {
        _cover = response.data['data']['cid'];
        coverController.text = _cover;
        notifyListeners();
      }
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
      if (mode == EditMode.edit) {
        var response =
            await node.handler.updateComic(comicIdController.text, toMap());
        if (response.statusCode == 200) {
          return true;
        }
      } else {
        var response =
            await node.handler.addComic(comicIdController.text, toMap());
        if (response.statusCode == 200) {
          return true;
        }
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'updateComicFailed');
    }
    return false;
  }

  Future<bool> deleteComic() async {
    try {
      if (mode == EditMode.edit) {
        var response = await node.handler.deleteComic(comicIdController.text);
        if (response.statusCode == 200) {
          return true;
        }
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'updateComicFailed');
    }
    return false;
  }

  Map toMap() {
    return {
      "comic_id": comicIdController.text,
      "title": titleController.text,
      "description": descriptionController.text,
      "status": statusController.text,
      "cover": coverController.text,
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "tags": tags.map<Map>((e) => e.toMap()).toList(),
      "authors": authors.map<Map>((e) => e.toMap()).toList(),
      "data": _data.map<Map>((e) => e.toMap(comicIdController.text)).toList()
    };
  }
}

enum EditMode { create, edit }

class GroupObject {
  String title;
  String groupId;
  List<Chapter> chapters;
  bool delete = false;

  GroupObject({this.title, this.groupId, this.chapters});

  Map toMap(String comicId) {
    return {
      "title": title,
      "name": groupId,
      "data": chapters.map<Map>((e) => e.toMap(comicId)).toList()
    };
  }
}

class Chapter {
  String chapterId;
  int timestamp;
  String title;
  List<String> data;
  bool delete = false;

  Chapter({this.chapterId, this.timestamp, this.title, this.data});

  Map toMap(String comicId) {
    return {
      "comic_id": comicId,
      "chapter_id": chapterId,
      "title": title,
      "data": data,
      "timestamp": timestamp
    };
  }
}
