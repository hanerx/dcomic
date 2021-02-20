import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/model/baseModel.dart';

abstract class BaseSourceModel extends BaseModel {
  Future<List<SearchResult>> search(String keyword);

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

class SourceOptionsProvider extends BaseModel {
  final SourceOptions options;

  SourceOptionsProvider(this.options);

  bool get active => options.active;

  set active(bool value) {
    options.active = value;
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

  Map<String,String> get headers;
}

abstract class Comic extends BaseModel {
  Future<bool> next();

  Future<bool> previous();

  String get comicId;

  String get chapterId;

  String get pageAt;

  List<String> get comicPages;

  String get title;

  List get viewpoints;

  List get chapters;

  bool get canPrevious;

  bool get canNext;

  Map<String,String> get headers;

  Future<void> addReadHistory({String title, String comicId, int page,String chapterTitle,String chapterId});

  Future<void> getComic(
      {String title, String comicId, String chapterId, String chapterTitle});

  Future<void> init();

  int get type;

  Future<void> getViewPoint();
}

class SourceDetail {
  final String name;
  final String title;
  final String description;
  final bool canDisable;
  final bool cloud;
  final bool deprecated;

  SourceDetail(this.name, this.title, this.description, this.canDisable,
      this.cloud, this.deprecated);

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

abstract class SearchResult extends BaseModel{
  String get title;
  String get comicId;
  String get cover;
  String get author;
  String get tag;
}

class IDInvalidError implements Exception {}

class ComicLoadingError implements Exception {}

class ComicIdNotBoundError implements Exception {}

class ComicSearchError implements Exception {}
