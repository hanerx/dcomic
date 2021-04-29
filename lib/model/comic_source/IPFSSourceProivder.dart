import 'package:dcomic/database/historyDatabaseProvider.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/http/IPFSSourceRequestHandler.dart';
import 'package:dcomic/model/comicCategoryModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class IPFSSourceProvider {
  List<String> address = [];
  List<Map> nodes = [];

  List<BaseSourceModel> getSources() {
    // TODO: implement getSources
    try {
      List<BaseSourceModel> data = [];
      for (var e in nodes) {
        if (e['error'] != true) {
          data.add(IPFSSourceModel(
              e['url'], e['name'], e['title'], e['description']));
        }
      }
      return data;
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'initIPFSSourceFailed');
    }
    return [];
  }

  Future<void> init() async {
    // TODO: implement init
    address = (await SourceDatabaseProvider.getSourceOption<List>(
        'ipfs_provider', 'address',
        defaultValue: []));
    for (var item in address) {
      try {
        var response = await IPFSSourceRequestHandler(item).getServerState();
        if (response.statusCode == 200) {
          response.data['data']['url'] = item;
          nodes.add(response.data['data']);
        }
      } catch (e, s) {
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: 'initIPFSSourceFailed: $item');
        nodes.add({
          "url": item,
          "address": item,
          "name": "error",
          "title": "配置错误",
          "description": "服务器不可访问时显示",
          "error": true
        });
      }
    }
  }

  Future<void> addSource(String address) async {
    try {
      var response = await IPFSSourceRequestHandler(address).getServerState();
      if (response.statusCode == 200) {
        nodes.add(response.data['data']);
        this.address.add(address);
        SourceDatabaseProvider.insertSourceOption<List>(
            'ipfs_provider', 'address', this.address);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'initIPFSSourceFailed: $address');
    }
  }

  Future<void> deleteSource(String address) async {
    int index = this.address.indexOf(address);
    if (index < 0) {
      return;
    }
    this.address.remove(address);
    this.nodes.removeAt(index);
    SourceDatabaseProvider.insertSourceOption<List>(
        'ipfs_provider', 'address', this.address);
  }
}

class IPFSSourceModel extends BaseSourceModel {
  final String address;
  final String name;
  final String title;
  final String description;

  IPFSSourceRequestHandler handler;

  IPFSSourceOptions _sourceOptions = IPFSSourceOptions.fromMap(null, {});

  IPFSSourceModel(this.address, this.name, this.title, this.description) {
    init();
  }

  Future<void> init() async {
    handler = IPFSSourceRequestHandler(this.address);
    var map = await SourceDatabaseProvider.getSourceOptions(type.name);
    _sourceOptions = IPFSSourceOptions.fromMap(type, map);
  }

  @override
  Future<ComicDetail> get({String comicId, String title}) async {
    // TODO: implement get
    if (comicId == null && title == null) {
      throw IDInvalidError();
    } else if (comicId != null) {
      try {
        return await getComicDetail(comicId);
      } catch (e) {}
      if (comicId != null &&
          await SourceDatabaseProvider.getBoundComic(type.name, comicId) !=
              null) {
        var map =
            await SourceDatabaseProvider.getBoundComic(type.name, comicId);
        return await getComicDetail(map['bound_id']);
      } else if (title != null) {
        var list = await search(title);
        for (var item in list) {
          if (item.title == title) {
            if (comicId != null) {
              SourceDatabaseProvider.boundComic(
                  type.name, comicId, item.comicId);
            }
            return await getComicDetail(item.comicId);
          }
        }
        throw ComicIdNotBoundError(comicId);
      } else if (title == null) {
        throw IDInvalidError();
      } else {
        throw ComicLoadingError();
      }
    }
    throw ComicLoadingError();
  }

  Future<ComicDetail> getComicDetail(String comicId) async {
    try {
      var response = await handler.getComicDetail(comicId);
      if (response.statusCode == 200) {
        var data = response.data['data'];
        var history = (await HistoryDatabaseProvider(this.type.name)
            .getReadHistory(comicId));
        var lastChapterId = history == null ? null : history['last_chapter_id'];
        return IPFSComicDetail(
            comicId: data['comic_id'],
            cover: this.address + '/upload/ipfs/' + data['cover'],
            description: data['description'],
            chapters: data['data']
                .map<Map<String, dynamic>>((e) => {
                      "title": e['title'],
                      "name": e['name'],
                      "data": e['data']
                          .map<Map>((c) => {
                                "chapter_id": c['chapter_id'],
                                "chapter_title": c['title'],
                                "updatetime": c['timestamp']
                              })
                          .toList()
                    })
                .toList(),
            tags: data['tags']
                .map<CategoryModel>((e) => CategoryModel(
                    categoryId: e['tag_id'], title: e['title'], model: this))
                .toList(),
            authors: data['authors']
                .map<CategoryModel>((e) => CategoryModel(
                    categoryId: e['tag_id'], title: e['title'], model: this))
                .toList(),
            status: data['status'],
            title: data['title'],
            updateTime: ToolMethods.formatTimestamp(data['timestamp']),
            sourceDetail: type,
            historyChapter: lastChapterId,
            handler: handler);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'getComicDetailFailed: $comicId');
      throw e;
    }
    throw ComicLoadingError(exception: '未知错误');
  }

  @override
  Future<Comic> getChapter(
      {String comicId,
      String title,
      String chapterId,
      String chapterTitle}) async {
    // TODO: implement getChapter
    var comic = await get(comicId: comicId, title: title);
    return comic.getChapter(title: chapterTitle, chapterId: chapterId);
  }

  @override
  Future<List<FavoriteComic>> getFavoriteComics(int page) {
    // TODO: implement getFavoriteComics
    throw UnimplementedError();
  }

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        ListTile(
          title: Text('服务器地址'),
          subtitle: Text('$address'),
        )
      ],
    );
  }

  @override
  // TODO: implement homePageHandler
  BaseHomePageHandler get homePageHandler => throw UnimplementedError();

  @override
  // TODO: implement options
  SourceOptions get options => _sourceOptions;

  @override
  Future<List<SearchResult>> search(String keyword, {int page = 0}) async {
    // TODO: implement search
    if (page != 0) {
      return [];
    } else {
      try {
        var response = await handler.search(keyword);
        if (response.statusCode == 200) {
          List data = response.data['data'];
          return data.map<SearchResult>((e) {
            var latestChapter = '暂无数据';
            try {
              latestChapter = e['data'].first['data'].first['title'];
            } catch (e) {
              latestChapter = '解析失败';
            }
            return IPFSSearchResult(
                e['authors']
                    .map<String>((item) => item['title'].toString())
                    .toList()
                    .join('/'),
                e['comic_id'],
                latestChapter,
                e['tags']
                    .map<String>((item) => item['title'].toString())
                    .toList()
                    .join('/'),
                e['title'],
                this.address + '/upload/ipfs/' + e['cover']);
          }).toList();
        }
      } catch (e, s) {
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: 'searchFailed: $keyword');
        throw e;
      }
    }
    return [];
  }

  @override
  // TODO: implement type
  SourceDetail get type => SourceDetail(
      name: name,
      title: '分布式网络服务器：$title',
      description: description,
      sourceType: SourceType.CloudDecoderSource);

  @override
  // TODO: implement userConfig
  UserConfig get userConfig => InactiveUserConfig(type);
}

class IPFSSourceOptions extends SourceOptions {
  final SourceDetail sourceDetail;
  bool _active = false;

  @override
  bool get active => _active;

  set active(bool active) {
    _active = active;
    SourceDatabaseProvider.insertSourceOption<bool>(
        sourceDetail.name, 'active', active);
  }

  IPFSSourceOptions.fromMap(this.sourceDetail, Map map) {
    _active = map['active'] == '1';
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {};
  }
}

class IPFSComicDetail extends ComicDetail {
  final List<CategoryModel> authors;
  final String comicId;
  final String cover;
  final String description;
  final List<Map<String, dynamic>> chapters;
  final String historyChapter;
  final List<CategoryModel> tags;
  final String title;
  final String updateTime;
  final SourceDetail sourceDetail;
  final String status;
  final IPFSSourceRequestHandler handler;

  IPFSComicDetail(
      {this.authors,
      this.comicId,
      this.cover,
      this.description,
      this.chapters,
      this.historyChapter,
      this.tags,
      this.title,
      this.updateTime,
      this.sourceDetail,
      this.status,
      this.handler});

  @override
  bool get isSubscribed => false;

  set isSubscribed(bool value) {}

  @override
  Future<Comic> getChapter({String title, String chapterId}) async {
    // TODO: implement getChapter
    for (var item in chapters) {
      for (var chapter in item['data']) {
        if (chapter['chapter_id'] == chapterId) {
          return IPFSComic(
              sourceDetail: sourceDetail,
              comicId: comicId,
              chapterId: chapterId,
              chapters: item['data'],
              groupId: item['name'],
              handler: handler);
        }
      }
    }
    throw IDInvalidError();
  }

  @override
  List<Map<String, dynamic>> getChapters() {
    // TODO: implement getChapters
    return List.generate(
        chapters.length, (index) => chapters[chapters.length - index - 1]);
  }

  @override
  Future<ComicComment> getComments(int page) async {
    // TODO: implement getComments
    throw UnimplementedError();
  }

  @override
  Future<void> getIfSubscribed() async {
    // TODO: implement getIfSubscribed
  }

  @override
  // TODO: implement headers
  Map<String, String> get headers => null;

  @override
  // TODO: implement hotNum
  int get hotNum => 0;

  @override
  String share() {
    // TODO: implement share
    return '【$title】';
  }

  @override
  // TODO: implement subscribeNum
  int get subscribeNum => 0;
}

class IPFSComic extends Comic {
  final SourceDetail sourceDetail;
  final String comicId;
  final String chapterId;
  final List chapters;
  final String groupId;
  final IPFSSourceRequestHandler handler;

  String _previous;
  String _next;
  String _pageAt;
  String _title;
  List<String> _pages = [];
  List<String> _chapterIdList;

  IPFSComic(
      {@required this.sourceDetail,
      @required this.comicId,
      @required this.chapterId,
      @required this.chapters,
      @required this.groupId,
      @required this.handler}) {
    _chapterIdList = chapters
        .map<String>((value) => value['chapter_id'].toString())
        .toList();
    _chapterIdList = List.generate(_chapterIdList.length,
        (index) => _chapterIdList[_chapterIdList.length - 1 - index]);
  }

  @override
  Future<void> addReadHistory(
      {String title,
      String comicId,
      int page,
      String chapterTitle,
      String chapterId}) {
    // TODO: implement addReadHistory
    throw UnimplementedError();
  }

  @override
  // TODO: implement canNext
  bool get canNext => _next != null && _next != '';

  @override
  // TODO: implement canPrevious
  bool get canPrevious => _previous != null && _previous != '';

  @override
  // TODO: implement comicPages
  List<String> get comicPages => _pages;

  @override
  Future<void> getComic(
      {String title,
      String comicId,
      String chapterId,
      String chapterTitle}) async {
    // TODO: implement getComic
    try {
      var response = await handler.getChapter(comicId, groupId, chapterId);
      if (response.statusCode == 200) {
        _pageAt = chapterId;
        _title = response.data['data']['title'];
        _pages = response.data['data']['data']
            .map<String>((e) => e.toString())
            .toList();
        if (_chapterIdList.indexOf(chapterId) > 0) {
          _previous = _chapterIdList[_chapterIdList.indexOf(chapterId) - 1];
        } else {
          _previous = null;
        }
        if (_chapterIdList.indexOf(chapterId) < _chapterIdList.length - 1) {
          _next = _chapterIdList[_chapterIdList.indexOf(chapterId) + 1];
        } else {
          _next = null;
        }
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'getComicFailed: $comicId, $chapterId, $groupId');
      throw e;
    }
  }

  @override
  Future<void> getViewPoint() async {
    // TODO: implement getViewPoint
  }

  @override
  // TODO: implement headers
  Map<String, String> get headers => null;

  @override
  Future<void> init() async {
    // TODO: implement init
    await getComic(comicId: comicId, chapterId: chapterId);
  }

  @override
  Future<bool> next() async {
    // TODO: implement next
    if (_next != null) {
      await getComic(comicId: comicId, chapterId: _next);
      return true;
    }
    return false;
  }

  @override
  // TODO: implement pageAt
  String get pageAt => _pageAt;

  @override
  Future<bool> previous() async {
    // TODO: implement previous
    if (_previous != null) {
      await getComic(comicId: comicId, chapterId: _previous);
      return true;
    }
    return false;
  }

  @override
  // TODO: implement title
  String get title => _title;

  @override
  // TODO: implement type
  PageType get type => PageType.ipfs;

  @override
  // TODO: implement viewpoints
  List get viewpoints => [];
}

class IPFSSearchResult extends SearchResult {
  final String _author;
  final String _comicId;
  final String _latestChapter;
  final String _tag;
  final String _title;
  final String _cover;

  IPFSSearchResult(this._author, this._comicId, this._latestChapter, this._tag,
      this._title, this._cover);

  @override
  // TODO: implement author
  String get author => _author;

  @override
  // TODO: implement comicId
  String get comicId => _comicId;

  @override
  // TODO: implement cover
  String get cover => _cover;

  @override
  // TODO: implement latestChapter
  String get latestChapter => _latestChapter;

  @override
  // TODO: implement tag
  String get tag => _tag;

  @override
  // TODO: implement title
  String get title => _title;
}
