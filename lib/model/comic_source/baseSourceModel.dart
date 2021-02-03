import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/model/baseModel.dart';

abstract class BaseSourceModel extends BaseModel {
  Future<List<ComicDetail>> search(String keyword);

  Future<ComicDetail> get({String comicId, String title});

  Future<Comic> getChapter(
      {String comicId, String title, String chapterId, String chapterTitle});

  List<Widget> getSettingWidget(context);

  SourceDetail get type;

  @override
  bool operator ==(Object other) {
    if (other is BaseSourceModel) {
      return type == other.type;
    }
    return false;
  }

  @override
  int get hashCode => type.hashCode;

  SourceOptions get options;
}

abstract class SourceOptions extends BaseModel {
  Map<String, dynamic> toMap();
  bool get active;
}

abstract class ComicDetail extends BaseModel {
  Future<Comic> getChapter({String title, String chapterId});

  List<List<Map<String, dynamic>>> getChapters();

  String get title;

  String get description;

  int get subscribeNum;

  int get hotNum;

  String get comicId;

  String get cover;

  List get authors;

  List get tags;

  String get updateTime;

  String get status;
}

abstract class Comic extends BaseModel {
  Future<void> next();

  Future<void> previous();

  List<String> get comicPages;

  String get title;

  List<Map<String, dynamic>> get viewpoints;
}

class SourceDetail {
  final String name;
  final String title;
  final String description;
  final bool canDisable;

  SourceDetail(this.name, this.description, this.title, this.canDisable);

  @override
  // TODO: implement hashCode
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if (other is SourceDetail) {
      return name == other.name;
    }
    return false;
  }
}

class IDInvalidError implements Exception {}

class ComicLoadingError implements Exception {}
