import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/model/baseModel.dart';

abstract class BaseSourceModel extends BaseModel {
  Future<List<SearchResult>> search(String keyword, {int page: 0});

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

  UserConfig get userConfig;

  @override
  String toString() {
    // TODO: implement toString
    return type.toString();
  }
}

enum UserStatus { login, logout, inactivate }

abstract class UserConfig extends BaseModel {
  String get nickname;

  String get userId;

  String get avatar;

  Future<bool> login(String username, String password);

  Future<bool> logout();

  Widget getSettingWidget(context);

  Widget getLoginWidget(context);

  UserStatus get status;
}

abstract class SourceOptions extends BaseModel {
  Map<String, dynamic> toMap();

  bool get active;

  set active(bool value);
}

class SourceOptionsProvider extends BaseModel {
  final SourceOptions options;
  int _ping = -1;

  SourceOptionsProvider(this.options);

  bool get active => options.active;

  set active(bool value) {
    options.active = value;
    notifyListeners();
  }

  int get ping => _ping;

  set ping(int value) {
    _ping = value;
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

  Map<String, String> get headers;

  @override
  String toString() {
    return 'ComicDetail{title: $title, comicId: $comicId}';
  }
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

  Map<String, String> get headers;

  Future<void> addReadHistory(
      {String title,
      String comicId,
      int page,
      String chapterTitle,
      String chapterId});

  Future<void> getComic(
      {String title, String comicId, String chapterId, String chapterTitle});

  Future<void> init();

  int get type;

  Future<void> getViewPoint();
}

enum SourceType {
  LocalSource,
  LocalDecoderSource,
  CloudDecoderSource,
  DeprecatedSource
}

class SourceDetail {
  final String name;
  final String title;
  final String description;
  final bool canDisable;
  final SourceType sourceType;
  final bool deprecated;

  SourceDetail(this.name, this.title, this.description, this.canDisable,
      this.sourceType, this.deprecated);

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
    return '{name: $name, title: $title, description: $description, canDisable: $canDisable, sourceType:$sourceType}';
  }
}

abstract class SearchResult extends BaseModel {
  String get title;

  String get comicId;

  String get cover;

  String get author;

  String get tag;

  @override
  String toString() {
    return 'SearchResult{title: $title, comicId: $comicId, cover: $cover, author: $author, tag: $tag}';
  }
}

class IDInvalidError implements Exception {}

class ComicLoadingError implements Exception {
  dynamic exception;

  ComicLoadingError({this.exception});

  @override
  String toString() {
    // TODO: implement toString
    return 'ComicLoadingError{exception: $exception}';
  }
}

class ComicIdNotBoundError implements Exception {}

class ComicSearchError implements Exception {}

class LoginUsernameOrPasswordError implements Exception {}

class InactiveUserConfig extends UserConfig {
  final SourceDetail type;
  final String message;

  InactiveUserConfig(this.type,{this.message:'该源不存在用户设置'});
  @override
  // TODO: implement avatar
  String get avatar => '';

  @override
  Widget getLoginWidget(context) {
    // TODO: implement getLoginWidget
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: Center(
        child: Text('该源不支持登录'),
      ),
    );
  }

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    return Card(
        child:ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: Icon(Icons.cloud_off),
              title: Text('${type.title}用户设置'),
              subtitle: Text('$message'),
            )
          ],
        ),
      );
  }

  @override
  Future<bool> login(String username, String password) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<bool> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  // TODO: implement nickname
  String get nickname => '';

  @override
  // TODO: implement status
  UserStatus get status => UserStatus.inactivate;

  @override
  // TODO: implement userId
  String get userId => '';
}

abstract class FavoriteComic {
  String get cover;

  String get title;

  String get latestChapter;

  String get comicId;

  BaseSourceModel get model;

  bool get update;
}
