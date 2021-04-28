import 'package:dcomic/database/historyDatabaseProvider.dart';
import 'package:dcomic/model/subjectListModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/model/baseModel.dart';

import '../comicCategoryModel.dart';
import '../comicRankingListModel.dart';
import 'package:dcomic/model/subjectDetailModel.dart';

abstract class BaseSourceModel extends BaseModel {
  Future<List<SearchResult>> search(String keyword, {int page: 0});

  Future<ComicDetail> get({String comicId, String title});

  Future<Comic> getChapter(
      {String comicId, String title, String chapterId, String chapterTitle});

  Widget getSettingWidget(context);

  Future<List<FavoriteComic>> getFavoriteComics(int page);

  Future<List<HistoryComic>> getLocalHistoryComics() async {
    List item = await HistoryDatabaseProvider(type.name).getReadHistories();
    return item.first
        .map<HistoryComic>((e) => HistoryComic.fromMap(e, this, e['timestamp']))
        .toList();
  }

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

  BaseHomePageHandler get homePageHandler;
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

  Future<ComicComment> getComments(int page);

  String get title;

  String get description;

  int get subscribeNum;

  int get hotNum;

  String get comicId;

  String get cover;

  List<CategoryModel> get authors;

  List<CategoryModel> get tags;

  String get updateTime;

  String get status;

  String get historyChapter;

  Map<String, String> get headers;

  Future<void> getIfSubscribed();

  bool get isSubscribed;

  set isSubscribed(bool isSubscribed);

  Future<void> updateUnreadState() async {
    await HistoryDatabaseProvider(sourceDetail.name)
        .addUnread(comicId, DateTime.now().millisecondsSinceEpoch);
  }

  SourceDetail get sourceDetail;

  @override
  String toString() {
    return 'ComicDetail{title: $title, comicId: $comicId}';
  }

  String share();
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

  PageType get type;

  Future<void> getViewPoint();
}

enum PageType { local, url, ipfs }

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
  final bool canSubscribe;
  final bool haveHomePage;

  SourceDetail(
      {@required this.name,
      @required this.title,
      @required this.description,
      this.canDisable: true,
      @required this.sourceType,
      this.deprecated: false,
      this.canSubscribe: false,
      this.haveHomePage: false});

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

abstract class SearchResult {
  String get title;

  String get comicId;

  String get cover;

  String get author;

  String get tag;

  String get latestChapter;

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

class ComicIdNotBoundError implements Exception {
  final String comicId;

  ComicIdNotBoundError(this.comicId);

  @override
  String toString() {
    // TODO: implement toString
    return 'comicIdNotBoundError: $comicId';
  }
}

class ComicSearchError implements Exception {
  final dynamic exception;

  ComicSearchError(this.exception);
}

class LoginUsernameOrPasswordError implements Exception {}

class LoginRequiredError implements Exception {}

class FavoriteUnavailableError implements Exception {}

class InactiveUserConfig extends UserConfig {
  final SourceDetail type;
  final String message;

  InactiveUserConfig(this.type, {this.message: '该源不存在用户设置'});

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
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
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

class FavoriteComic {
  final String cover;

  final String title;

  final String latestChapter;

  final String comicId;

  final BaseSourceModel model;

  final bool update;

  FavoriteComic(this.cover, this.title, this.latestChapter, this.comicId,
      this.model, this.update);
}

class HistoryComic extends FavoriteComic {
  final int timestamp;

  HistoryComic(String cover, String title, String latestChapter, String comicId,
      BaseSourceModel model, bool update, this.timestamp)
      : super(cover, title, latestChapter, comicId, model, update);

  HistoryComic.fromMap(
      Map<String, dynamic> map, BaseSourceModel model, this.timestamp)
      : super(map['cover'], map['title'], map['last_chapter'], map['comicId'],
            model, false);
}

class ComicComment {
  final String avatar;
  final String nickname;
  final String content;
  final List reply;
  final int timestamp;
  final int like;

  ComicComment(this.avatar, this.nickname, this.content, this.reply,
      this.timestamp, this.like);
}

enum CategoryType{
  local,
  cloud
}

abstract class BaseHomePageHandler {
  Future<List<HomePageCardModel>> getHomePage();

  Future<List<CategoryModel>> getCategory({CategoryType type});

  Future<List<RankingComic>> getCategoryDetail(String categoryId,{int page:0,bool popular:true});

  Future<List<RankingComic>> getRankingList(int page);

  Future<List<RankingComic>> getLatestUpdate(int page);

  Future<List<SubjectItem>> getSubjectList(int page);

  Future<SubjectModel> getSubject(String subjectId);
}

typedef BuilderCallback =Widget Function(BuildContext);

class HomePageCardModel {
  final String title;
  final BuilderCallback action;
  final List detail;

  HomePageCardModel({@required this.title, this.action, @required this.detail});
}

typedef ContextCallback = void Function(dynamic);

class HomePageCardDetailModel {
  final String title;
  final String subtitle;
  final String cover;
  final ContextCallback onPressed;

  HomePageCardDetailModel(
      {@required this.title,
      this.subtitle,
      @required this.cover,
      @required this.onPressed});
}
