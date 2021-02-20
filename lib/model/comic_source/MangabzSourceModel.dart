import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutterdmzj/database/sourceDatabaseProvider.dart';
import 'package:flutterdmzj/http/UniversalRequestModel.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';
import 'package:flutterdmzj/utils/soup.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:lpinyin/lpinyin.dart';

class MangabzSourceModel extends BaseSourceModel {
  MangabzSourceOptions _options = MangabzSourceOptions.fromMap({});

  MangabzSourceModel() {
    init();
  }

  Future<void> init() async {
    var map = await SourceDatabaseProvider.getSourceOptions(type.name);
    _options = MangabzSourceOptions.fromMap(map);
  }

  @override
  Future<ComicDetail> get({String comicId, String title}) async {
    // TODO: implement get
    if (comicId == null && title == null) {
      throw IDInvalidError();
    } else if (comicId != null &&
        await SourceDatabaseProvider.getBoundComic(type.name, comicId) !=
            null) {
      var map = await SourceDatabaseProvider.getBoundComic(type.name, comicId);
      return await getMangabzComic(map['bound_id']);
    } else if (title != null) {
      var list = await search(title);
      for (var item in list) {
        if (item.title == title) {
          if (comicId != null) {
            SourceDatabaseProvider.boundComic(type.name, comicId, item.comicId);
          }
          return await getMangabzComic(item.comicId);
        }
      }
      throw ComicIdNotBoundError();
    } else if (title == null) {
      throw IDInvalidError();
    } else {
      throw ComicLoadingError();
    }
  }

  Future<MangabzComicDetail> getMangabzComic(String comicId) async {
    try {
      var response =
          await UniversalRequestModel().mangabzRequestHandler.getComic(comicId);
      if (response.statusCode == 200) {
        var soup = BeautifulSoup(
            ChineseHelper.convertToSimplifiedChinese(response.data.toString()));
        var title =
            soup.find(id: '.detail-info-title').text.replaceAll(' ', '');
        var authors = soup
            .find(id: '.detail-info-tip')
            .children
            .first
            .children
            .map((e) => {'tag_name': e.text, 'tag_id': null})
            .toList();
        var cover = soup.find(id: '.detail-info-cover').attributes['src'];
        var description = soup.find(id: '.detail-info-content').text;
        var status =
            soup.find(id: '.detail-info-tip').children[1].children.first.text;
        var updateTime = RegExp('[0-9]{4}-[0-9]{2}-[0-9]{2}')
            .stringMatch(soup.find(id: '.detail-list-form-title').text);
        var tags = soup
            .find(id: '.detail-info-tip')
            .children[2]
            .children
            .map((e) => {'tag_name': e.text, 'tag_id': null})
            .toList();
        var chapters = soup
            .find(id: '.detail-list-form-con')
            .children
            .map<Map>((e) => {
                  'chapter_id': e.attributes['href'].replaceAll('/', ''),
                  'chapter_title': e.text.replaceAll(' ', ''),
                  'updatetime': 0
                })
            .toList();
        return MangabzComicDetail(title, authors, cover, description, comicId,
            status, updateTime, tags, <Map<String, dynamic>>[
          {'data': chapters, 'title': 'Mangabz连载'}
        ]);
      }
    } catch (e) {
      throw ComicLoadingError();
    }
    return null;
  }

  @override
  Future<Comic> getChapter(
      {String comicId,
      String title,
      String chapterId,
      String chapterTitle}) async {
    // TODO: implement getChapter
    MangabzComicDetail detail = await get(comicId: comicId, title: title);
    return await detail.getChapter(title: chapterTitle, chapterId: chapterId);
  }

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    return Container();
  }

  @override
  // TODO: implement options
  SourceOptions get options => _options;

  @override
  Future<List<SearchResult>> search(String keyword) async {
    // TODO: implement search
    try {
      var response =
          await UniversalRequestModel().mangabzRequestHandler.search(keyword);
      if (response.statusCode == 200) {
        var soup = BeautifulSoup(ChineseHelper.convertCharToSimplifiedChinese(
            response.data.toString()));
        var list = soup.find(id: '.mh-list');
        List<MangabzSearchResult> data = [];
        for (var item in list.children) {
          data.add(MangabzSearchResult(
              item.getElementsByTagName('img').first.attributes['src'],
              ChineseHelper.convertToSimplifiedChinese(item
                  .getElementsByClassName('title')
                  .first
                  .children
                  .first
                  .text),
              item
                  .getElementsByClassName('title')
                  .first
                  .children
                  .first
                  .attributes['href']
                  .replaceAll('/', '')));
        }
        return data;
      }
    } catch (e) {
      throw ComicSearchError();
    }
    return [];
  }

  @override
  // TODO: implement type
  SourceDetail get type => SourceDetail('mangabz', 'Mangabz',
      'Mangabz的漫画源，嘿呀，你妈的好难实现的，为了这个功能我已经快燃尽自己了', true, false, false);
}

class MangabzSourceOptions extends SourceOptions {
  bool _active = false;

  MangabzSourceOptions.fromMap(Map map) {
    _active = map['active'] == '1';
  }

  @override
  bool get active => _active;

  set active(bool value) {
    _active = value;
    SourceDatabaseProvider.insertSourceOption(
        'mangabz', 'active', value ? '1' : '0');
    notifyListeners();
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {'active': active};
  }
}

class MangabzComicDetail extends ComicDetail {
  final String _title;
  final List _authors;
  final String _cover;
  final String _description;
  final String _comicId;
  final String _status;
  final String _updateTime;
  final List _tags;
  final List _chapters;

  MangabzComicDetail(
      this._title,
      this._authors,
      this._cover,
      this._description,
      this._comicId,
      this._status,
      this._updateTime,
      this._tags,
      this._chapters);

  @override
  String toString() {
    return 'MangabzComicDetail{_title: $_title, _authors: $_authors, _cover: $_cover, _description: $_description, _comicId: $_comicId, _status: $_status, _updateTime: $_updateTime, _tags: $_tags, _chapters: $_chapters}';
  }

  @override
  // TODO: implement authors
  List get authors => _authors;

  @override
  // TODO: implement comicId
  String get comicId => _comicId;

  @override
  // TODO: implement cover
  String get cover => _cover;

  @override
  // TODO: implement description
  String get description => _description;

  @override
  Future<Comic> getChapter({String title, String chapterId}) async {
    // TODO: implement getChapter
    for (var item in _chapters) {
      for (var chapter in item['data']) {
        if (chapter['chapter_id'].toString() == chapterId) {
          return MangabzComic(_comicId, chapterId, item['data']);
        }
      }
    }
    return null;
  }

  @override
  List<Map<String, dynamic>> getChapters() {
    // TODO: implement getChapters
    return _chapters;
  }

  @override
  // TODO: implement historyChapter
  String get historyChapter => null;

  @override
  // TODO: implement hotNum
  int get hotNum => 0;

  @override
  // TODO: implement status
  String get status => _status;

  @override
  // TODO: implement subscribeNum
  int get subscribeNum => 0;

  @override
  // TODO: implement tags
  List get tags => _tags;

  @override
  // TODO: implement title
  String get title => _title;

  @override
  // TODO: implement updateTime
  String get updateTime => _updateTime;

  @override
  // TODO: implement headers
  Map<String,String> get headers => {'referer':'http://images.dmzj.com'};
}

class MangabzSearchResult extends SearchResult {
  final String _cover;
  final String _title;
  final String _comicId;

  MangabzSearchResult(this._cover, this._title, this._comicId);

  @override
  // TODO: implement author
  String get author => '';

  @override
  // TODO: implement comicId
  String get comicId => _comicId;

  @override
  // TODO: implement cover
  String get cover => _cover;

  @override
  // TODO: implement tag
  String get tag => '';

  @override
  // TODO: implement title
  String get title => _title;
}

class MangabzComic extends Comic {
  final String _comicId;
  final String _chapterId;
  final List _chapters;
  List<String> _pages = [];
  String _title;
  List<String> _chapterIdList;
  int _type = 0;
  List _viewPoints = [];

  String _previous;
  String _next;
  String _pageAt;

  MangabzComic(this._comicId, this._chapterId, this._chapters) {
    _chapterIdList = _chapters
        .map<String>((value) => value['chapter_id'].toString())
        .toList();
    _chapterIdList = List.generate(_chapterIdList.length,
        (index) => _chapterIdList[_chapterIdList.length - 1 - index]);
  }

  @override
  Future<void> addReadHistory({String title, String comicId, int page}) async {
    // TODO: implement addReadHistory
    return;
  }

  @override
  // TODO: implement canNext
  bool get canNext => _next != null && _next != '';

  @override
  // TODO: implement canPrevious
  bool get canPrevious => _previous != null && _previous != '';

  @override
  // TODO: implement chapterId
  String get chapterId => _chapterId;

  @override
  // TODO: implement chapters
  List get chapters => _chapters;

  @override
  // TODO: implement comicId
  String get comicId => _comicId;

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
    if (chapterId == null) {
      throw IDInvalidError();
    }
    try {
      var response = await UniversalRequestModel()
          .mangabzRequestHandler
          .getChapter(chapterId);
      if (response.statusCode == 200) {
        var soup = BeautifulSoup(
            ChineseHelper.convertToSimplifiedChinese(response.data.toString()));
        this._title = soup.find(id: '.top-title').text.replaceAll(' ', '');
        // _pageAt = chapterId;
        // var length = RegExp('(?<=var MANGABZ_IMAGE_COUNT=)[^;]*;')
        //     .stringMatch(response.data.toString());
        // length = length.substring(0, length.length - 1);
        // int page = 0;
        // var codes = <String>[];
        // while (page < int.parse(length)) {
        //   try {
        //     var data = await UniversalRequestModel()
        //         .mangabzRequestHandler
        //         .getChapterImage(chapterId, page);
        //     if (data.statusCode == 200) {
        //       codes.add(data.data.toString());
        //     }
        //   } catch (e) {}
        //   page++;
        // }
        // List<String> pages = [];
        // List<String> result = await ToolMethods.evalList(codes);
        // for (var item in result) {
        //   pages += jsonDecode(item).map<String>((e) => e.toString()).toList();
        // }
        // _pages = pages.toSet().toList();
        this._pages = jsonDecode(await ToolMethods.eval('newImgs',url: '${UniversalRequestModel()
            .mangabzRequestHandler.baseUrl}/$chapterId')).map<String>((e) => e.toString()).toList();
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
        notifyListeners();
      }
    } catch (e) {
      throw ComicLoadingError();
    }
  }

  @override
  Future<void> getViewPoint() async {
    // TODO: implement getViewPoint
    return;
  }

  @override
  Future<void> init() async {
    // TODO: implement init
    await getComic(chapterId: chapterId);
  }

  @override
  Future<bool> next() async {
    // TODO: implement next
    if (canNext) {
      await getComic(chapterId: _next);
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
    if (canPrevious) {
      await getComic(chapterId: _previous);
      return true;
    }
    return false;
  }

  @override
  // TODO: implement title
  String get title => _title;

  @override
  // TODO: implement type
  int get type => _type;

  @override
  // TODO: implement viewpoints
  List get viewpoints => _viewPoints;

  @override
  // TODO: implement headers
  Map<String, String> get headers => {'referer': 'http://www.mangabz.com/'};
}
