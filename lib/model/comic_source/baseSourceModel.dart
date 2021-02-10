import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/model/baseModel.dart';

abstract class BaseSourceModel extends BaseModel {
  Future<List<ComicDetail>> search(String keyword);

  Future<ComicDetail> get({String comicId, String title});

  Future<Comic> getChapter(
      {String comicId, String title, String chapterId, String chapterTitle});

  Widget getSettingWidget(context);

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

  @override
  String toString() {
    // TODO: implement toString
    return type.toString();
  }
}

abstract class SourceOptions extends BaseModel {
  Map<String, dynamic> toMap();

  bool get active;

  set active(bool value);
}

class SourceOptionsProvider extends BaseModel{
  final SourceOptions options;

  SourceOptionsProvider(this.options);

  bool get active=>options.active;

  set active(bool value){
    options.active=value;
    notifyListeners();
  }
}

abstract class ComicDetail extends BaseModel {
  Future<Comic> getChapter({String title, String chapterId});

  List<Map<String, dynamic>> getChapters();

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

  String get historyChapter;
}

abstract class Comic extends BaseModel {
  Future<void> next();

  Future<void> previous();

  List<String> get comicPages;

  String get title;

  List<Map<String, dynamic>> get viewpoints;

  List get chapters;

  Future<void> addReadHistory({String title,String comicId,int page});
}

class SourceDetail {
  final String name;
  final String title;
  final String description;
  final bool canDisable;
  final bool cloud;
  final bool deprecated;


  SourceDetail(this.name, this.title, this.description, this.canDisable, this.cloud, this.deprecated);

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

  @override
  String toString() {
    return '{name: $name, title: $title, description: $description, canDisable: $canDisable, cloud: $cloud}';
  }
}

class IDInvalidError implements Exception {}

class ComicLoadingError implements Exception {}
