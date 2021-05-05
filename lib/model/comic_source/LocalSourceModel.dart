import 'dart:io';

import 'package:dcomic/database/historyDatabaseProvider.dart';
import 'package:dcomic/database/localMangaDatabaseProvider.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/model/comicCategoryModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/mag_model/baseMangaModel.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class LocalSourceModel extends BaseSourceModel {
  LocalSourceOptions _sourceOptions = LocalSourceOptions.fromMap({});

  LocalSourceModel() {
    init();
  }

  init() async {
    var map = await SourceDatabaseProvider.getSourceOptions(type.name);
    _sourceOptions = LocalSourceOptions.fromMap(map);
  }

  @override
  Future<ComicDetail> get({String comicId, String title}) async {
    // TODO: implement get
    if (comicId == null && title == null) {
      throw IDInvalidError();
    }
    if (comicId != null) {
      try {
        return await getLocalComic(comicId);
      } catch (e) {}
      if (await SourceDatabaseProvider.getBoundComic(type.name, comicId) !=
          null) {
        var map =
            await SourceDatabaseProvider.getBoundComic(type.name, comicId);
        try {
          return await getLocalComic(map['bound_id']);
        } catch (e) {
          throw ComicLoadingError(exception: e);
        }
      }
    }
    if (title != null) {
      var list = await search(title);
      for (var item in list) {
        if (item.title == title) {
          if (comicId != null) {
            SourceDatabaseProvider.boundComic(type.name, comicId, item.comicId);
          }
          return await getLocalComic(item.comicId);
        }
      }
      throw ComicIdNotBoundError(comicId);
    }
    throw IDInvalidError();
  }

  Future<ComicDetail> getLocalComic(String name) async {
    try {
      var comic = await LocalMangaDatabaseProvider().get(name);
      var history =
          (await HistoryDatabaseProvider(this.type.name).getReadHistory(name));
      var lastChapterId = history == null ? null : history['last_chapter_id'];
      return LocalComicDetail(comic, type, lastChapterId, _sourceOptions, this);
    } catch (e) {
      logger.e(
          'class: ${this.runtimeType}, action: getComicFailed, exception: $e');
      throw ComicLoadingError(exception: e);
    }
  }

  @override
  Future<Comic> getChapter(
      {String comicId,
      String title,
      String chapterId,
      String chapterTitle}) async {
    // TODO: implement getChapter
    ComicDetail detail = await get(title: title, comicId: comicId);
    return detail.getChapter(chapterId: chapterId, title: chapterTitle);
  }

  @override
  Future<List<FavoriteComic>> getFavoriteComics(int page) async {
    // TODO: implement getFavoriteComics
    List<MangaObject> comics = await LocalMangaDatabaseProvider().getAll();
    return comics
        .map<FavoriteComic>((e) => FavoriteComic(e.cover, e.title,
            e.lastChapter, e.name, this, false, e.coverPageType))
        .toList();
  }

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    return ChangeNotifierProvider(
      create: (_) => LocalOptionProvider(_sourceOptions),
      builder: (context, child) => ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            title: Text('.manga解析器版本'),
            subtitle: Text('${MangaObject.version}'),
          ),
          ListTile(
            title: Text('取消订阅时是否直接删除文件'),
            subtitle: Text('勾选后将无法重新订阅已经取消订阅的本地漫画，漫画源文件将在取消订阅时删除'),
            trailing: Switch(
              value: Provider.of<LocalOptionProvider>(context).delete,
              onChanged: (bool value) {
                Provider.of<LocalOptionProvider>(context, listen: false)
                    .delete = value;
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement options
  SourceOptions get options => _sourceOptions;

  @override
  Future<List<SearchResult>> search(String keyword, {int page = 0}) async {
    // TODO: implement search
    if (page > 0) {
      return [];
    }
    var list = await LocalMangaDatabaseProvider().search(keyword);
    return list
        .map<SearchResult>((e) => LocalSearchResult(e.authors.join('/'), e.name,
            e.cover, e.tags.join('/'), e.title, e.lastChapter))
        .toList();
  }

  @override
  // TODO: implement type
  SourceDetail get type => SourceDetail(
      name: 'local',
      title: '本地漫画',
      description: '本地漫画解析器',
      canDisable: true,
      sourceType: SourceType.LocalSource,
      deprecated: false,
      canSubscribe: true);

  @override
  // TODO: implement userConfig
  UserConfig get userConfig => InactiveUserConfig(type);

  @override
  // TODO: implement homePageHandler
  BaseHomePageHandler get homePageHandler => throw UnimplementedError();
}

class LocalSourceOptions extends SourceOptions {
  bool _active;
  bool _delete;

  LocalSourceOptions.fromMap(Map map) {
    _active = map['active'] == '1';
    _delete = map['delete'] == '1';
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {};
  }

  bool get active => _active;

  set active(bool value) {
    _active = value;
    SourceDatabaseProvider.insertSourceOption(
        'local', 'active', value ? '1' : '0');
    notifyListeners();
  }

  bool get delete => _delete;

  set delete(bool value) {
    _delete = value;
    SourceDatabaseProvider.insertSourceOption(
        'local', 'delete', value ? '1' : '0');
    notifyListeners();
  }
}

class LocalOptionProvider extends SourceOptionsProvider {
  LocalSourceOptions options;

  LocalOptionProvider(this.options) : super(options);

  bool get delete => options.delete;

  set delete(bool value) {
    options.delete = value;
    notifyListeners();
  }
}

class LocalComicDetail extends ComicDetail {
  final MangaObject _mangaObject;
  final SourceDetail _sourceDetail;
  final String _history;
  final LocalSourceOptions options;
  final LocalSourceModel model;

  bool _isSubscribed = true;

  @override
  bool get isSubscribed => _isSubscribed;

  PageType get pageType => _mangaObject.coverPageType;

  set isSubscribed(bool value) {
    if (value) {
      if (!options.delete) {
        _isSubscribed = true;
        LocalMangaDatabaseProvider().insert(_mangaObject);
      }
      notifyListeners();
    } else {
      _isSubscribed = false;
      LocalMangaDatabaseProvider().delete(_mangaObject);
      if (options.delete) {
        Directory(_mangaObject.basePath).delete(recursive: true);
      }
    }
    notifyListeners();
  }

  LocalComicDetail(this._mangaObject, this._sourceDetail, this._history,
      this.options, this.model);

  @override
  List<CategoryModel> get authors => _mangaObject.authors
      .map((e) => CategoryModel(title: e.name, categoryId: e.id, model: model))
      .toList();

  @override
  String get comicId => _mangaObject.name;

  @override
  String get cover => _mangaObject.cover;

  @override
  String get description => _mangaObject.description;

  @override
  Future<Comic> getChapter({String title, String chapterId}) async {
    for (var item in _mangaObject.data) {
      var chapter = item.indexOf(chapterId);
      if (chapter == null) {
        continue;
      }
      return LocalComic(_mangaObject, chapter, item);
    }
    throw IDInvalidError();
  }

  @override
  List<Map<String, dynamic>> getChapters() {
    // TODO: implement getChapters
    return _mangaObject.data
        .map<Map<String, dynamic>>((e) => {
              'title': e.title,
              'data': e.chapters
                  .map<Map<String, dynamic>>((e) => {
                        'chapter_id': e.name,
                        'chapter_title': e.title,
                        'updatetime': e.timestamp,
                        'order': e.order
                      })
                  .toList()
            })
        .toList();
  }

  @override
  Future<void> getIfSubscribed() async {
    // TODO: implement getIfSubscribed
  }

  @override
  // TODO: implement headers
  Map<String, String> get headers => {};

  @override
  // TODO: implement historyChapter
  String get historyChapter => _history;

  @override
  // TODO: implement hotNum
  int get hotNum => 0;

  @override
  String share() {
    // TODO: implement share
    return '【$title】';
  }

  @override
  // TODO: implement sourceDetail
  SourceDetail get sourceDetail => _sourceDetail;

  @override
  // TODO: implement status
  String get status => _mangaObject.status;

  @override
  // TODO: implement subscribeNum
  int get subscribeNum => 0;

  @override
  // TODO: implement tags
  List<CategoryModel> get tags => _mangaObject.tags
      .map((e) => CategoryModel(title: e.name, categoryId: e.id, model: model))
      .toList();

  @override
  // TODO: implement title
  String get title => _mangaObject.title;

  @override
  // TODO: implement updateTime
  String get updateTime =>
      ToolMethods.formatTimestamp(_mangaObject.lastUpdateTimeStamp);

  @override
  Future<ComicComment> getComments(int page) {
    // TODO: implement getComments
    throw UnimplementedError();
  }
}

class LocalComic extends Comic {
  final MangaObject _mangaObject;
  final ChapterObject _chapterObject;
  final VolumeObject _volumeObject;

  ChapterObject _pageAt;

  LocalComic(this._mangaObject, this._chapterObject, this._volumeObject);

  @override
  Future<void> addReadHistory(
      {String title,
      String comicId,
      int page,
      String chapterTitle,
      String chapterId}) async {
    // TODO: implement addReadHistory
    await HistoryDatabaseProvider('local').addReadHistory(
        comicId,
        _mangaObject.title,
        _mangaObject.cover,
        chapterTitle,
        pageAt,
        DateTime.now().millisecondsSinceEpoch ~/ 1000);
  }

  @override
  // TODO: implement canNext
  bool get canNext => _volumeObject.chapters.indexOf(_pageAt) > 0;

  @override
  // TODO: implement canPrevious
  bool get canPrevious =>
      _volumeObject.chapters.indexOf(_pageAt) <
      _volumeObject.chapters.length - 1;

  @override
  // TODO: implement chapterId
  String get chapterId => _chapterObject.name;

  @override
  // TODO: implement chapters
  List get chapters => _volumeObject.chapters
      .map<Map<String, dynamic>>((e) => {
            'chapter_id': e.name,
            'chapter_title': e.title,
            'updatetime': e.timestamp,
            'order': e.order
          })
      .toList();

  @override
  // TODO: implement comicId
  String get comicId => _mangaObject.name;

  @override
  // TODO: implement comicPages
  List<String> get comicPages => _pageAt.pages;

  @override
  Future<void> getComic(
      {String title,
      String comicId,
      String chapterId,
      String chapterTitle}) async {
    // TODO: implement getComic
    if (chapterId == null) {
      throw IDInvalidError();
    }
    var item = _volumeObject.indexOf(chapterId);
    if (item != null) {
      _pageAt = item;
      await addReadHistory(
          chapterId: _pageAt.name,
          comicId: _mangaObject.name,
          title: _mangaObject.title,
          chapterTitle: _pageAt.title);
      notifyListeners();
    }
    throw IDInvalidError();
  }

  @override
  Future<void> getViewPoint() async {
    // TODO: implement getViewPoint
  }

  @override
  // TODO: implement headers
  Map<String, String> get headers => {};

  @override
  Future<void> init() async {
    // TODO: implement init
    _pageAt = _chapterObject;
    notifyListeners();
  }

  @override
  Future<bool> next() async {
    // TODO: implement next
    if (canNext) {
      _pageAt =
          _volumeObject.chapters[_volumeObject.chapters.indexOf(_pageAt) - 1];
      await addReadHistory(
          chapterId: _pageAt.name,
          comicId: _mangaObject.name,
          title: _mangaObject.title,
          chapterTitle: _pageAt.title);
      return true;
    }
    return false;
  }

  @override
  // TODO: implement pageAt
  String get pageAt => _pageAt.name;

  @override
  Future<bool> previous() async {
    // TODO: implement previous
    if (canPrevious) {
      _pageAt =
          _volumeObject.chapters[_volumeObject.chapters.indexOf(_pageAt) + 1];
      await addReadHistory(
          chapterId: _pageAt.name,
          comicId: _mangaObject.name,
          title: _mangaObject.title,
          chapterTitle: _pageAt.title);
      return true;
    }
    return false;
  }

  @override
  // TODO: implement title
  String get title => _pageAt.title;

  @override
  // TODO: implement type
  PageType get type => _pageAt.type;

  @override
  // TODO: implement viewpoints
  List get viewpoints => [];
}

class LocalSearchResult extends SearchResult {
  final String author;
  final String comicId;
  final String cover;
  final String tag;
  final String title;
  final String latestChapter;

  LocalSearchResult(this.author, this.comicId, this.cover, this.tag, this.title,
      this.latestChapter);
}
