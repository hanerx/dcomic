import 'package:flutter/src/widgets/framework.dart';
import 'package:flutterdmzj/database/sourceDatabaseProvider.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';

class DMZJSourceModel extends BaseSourceModel {
  DMZJSourceOptions _options;

  DMZJSourceModel() {
    init();
  }

  Future<void> init() async {
    var map = await SourceDatabaseProvider.getSourceOptions(type.name);
    _options = DMZJSourceOptions.fromMap(map);
  }

  @override
  Future<ComicDetail> get({String comicId, String title}) async {
    // TODO: implement get
    if (comicId == null) {
      throw IDInvalidError();
    }
    CustomHttp http = CustomHttp();
    try {
      var response = await http.getComicDetail(comicId);
      if (response.data == 200) {
        var title = response.data['title'];
        var cover = response.data['cover'];
        var author = response.data['authors'];
        var types = response.data['types'];
        var hotNum = response.data['hot_num'];
        var subscribeNum = response.data['subscribe_num'];
        var description = response.data['description'];
        var updateDate =
            ToolMethods.formatTimestamp(response.data['last_updatetime']);
        //状态信息需要采取特殊处理
        var status = response.data['status']
            .map((value) => value['tag_name'])
            .toList()
            .join('/');
        var chapters = response.data['chapters'];
        return DMZJComicDetail(comicId, description, hotNum, subscribeNum,
            title, cover, author, types, chapters, status, updateDate, options);
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
    if (comicId == null || chapterId == null) {
      throw IDInvalidError();
    }
    try {
      ComicDetail comicDetail = await this.get(comicId: comicId);
      return await comicDetail.getChapter(chapterId: chapterId);
    } catch (e) {
      throw ComicLoadingError();
    }
  }

  @override
  Future<List<ComicDetail>> search(String keyword) {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  // TODO: implement type
  SourceDetail get type =>
      SourceDetail('dmzj', '默认-动漫之家', '默认数据提供商，不可关闭', false);

  @override
  List<Widget> getSettingWidget(context) {
    // TODO: implement getSettingWidget
    throw UnimplementedError();
  }

  @override
  // TODO: implement options
  SourceOptions get options => _options;
}

class DMZJSourceOptions extends SourceOptions {
  bool webApi;
  bool backupApi;
  bool deepSearch;

  DMZJSourceOptions.fromMap(Map map) {
    webApi = map['web_api'] == '1';
    backupApi = map['backup_api'] == '1';
    deepSearch = map['deep_search'] == '1';
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {
      "web_api": webApi,
      "backup_api": backupApi,
      'deep_search': deepSearch
    };
  }

  @override
  // TODO: implement active
  bool get active => true;
}

class DMZJComicDetail extends ComicDetail {
  final String _comicId;
  final String _description;
  final int _hotNum;
  final int _subscribeNum;
  final String _title;
  final String _cover;
  final List _authors;
  final List _tags;
  final List _chapters;
  final String _status;
  final String _updateTime;
  final DMZJSourceOptions options;

  DMZJComicDetail(
      this._comicId,
      this._description,
      this._hotNum,
      this._subscribeNum,
      this._title,
      this._cover,
      this._authors,
      this._tags,
      this._chapters,
      this._status,
      this._updateTime,
      this.options);

  @override
  // TODO: implement comicId
  String get comicId => _comicId;

  @override
  // TODO: implement description
  String get description => _description;

  @override
  Future<Comic> getChapter({String title, String chapterId}) async {
    // TODO: implement getChapter
    if (chapterId == null) {
      throw IDInvalidError();
    }
    for (var item in _chapters) {
      if (item['chapter_id'].toString() == chapterId) {
        return DMZJComic(_comicId, chapterId, _chapters, options);
      }
    }
    return null;
  }

  @override
  List<List<Map<String, dynamic>>> getChapters() {
    // TODO: implement getChapters
    throw UnimplementedError();
  }

  @override
  // TODO: implement hotNum
  int get hotNum => _hotNum;

  @override
  // TODO: implement subscribeNum
  int get subscribeNum => _subscribeNum;

  @override
  // TODO: implement title
  String get title => _title;

  @override
  // TODO: implement cover
  String get cover => _cover;

  @override
  // TODO: implement authors
  List get authors => _authors;

  @override
  // TODO: implement tags
  List get tags => _tags;

  @override
  // TODO: implement status
  String get status => _status;

  @override
  // TODO: implement updateTime
  String get updateTime => _updateTime;
}

class DMZJComic extends Comic {
  final String _comicId;
  final String _chapterId;
  final List _chapters;
  final DMZJSourceOptions options;
  List<String> _pages;
  String _title;
  List<String> _chapterIdList;

  String _previous;
  String _next;
  String _pageAt;

  DMZJComic(this._comicId, this._chapterId, this._chapters, this.options) {
    _chapterIdList = _chapters
        .map<String>((value) => value['chapter_id'].toString())
        .toList();
    _chapterIdList = List.generate(_chapterIdList.length,
        (index) => _chapterIdList[_chapterIdList.length - 1 - index]);
    getComic(_comicId, _chapterId);
  }

  Future<void> getComic(String comicId, String chapterId) async {
    CustomHttp http = CustomHttp();
    try {
      var response = await http.getComic(comicId, chapterId);
      if (response.statusCode == 200) {
        _pageAt = chapterId;
        _pages = response.data['page_url'];
        _title = response.data['title'];
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
      logger.e('class: DMZJComic, action: getComicFailed, exception: $e');
    }
  }

  @override
  // TODO: implement comicPages
  List<String> get comicPages => _pages;

  @override
  // TODO: implement title
  String get title => this._title;

  String get pageAt => this._pageAt;

  @override
  // TODO: implement viewpoints
  List<Map<String, dynamic>> get viewpoints => throw UnimplementedError();

  @override
  Future<void> next() async {
    // TODO: implement next
    if (_next != null) {
      await getComic(_comicId, _next);
    }
  }

  @override
  Future<void> previous() async {
    // TODO: implement previous
    if (_previous != null) {
      await getComic(_comicId, _previous);
    }
  }
}
