import 'dart:convert';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/utils/soup.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutterdmzj/database/sourceDatabaseProvider.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:provider/provider.dart';

class DMZJSourceModel extends BaseSourceModel {
  DMZJSourceOptions _options = DMZJSourceOptions.fromMap({});

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
      if (response.statusCode == 200) {
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
        DataBase dataBase = DataBase();
        var lastChapterId = await dataBase.getHistory(comicId);
        return DMZJComicDetail(comicId, description, hotNum, subscribeNum,
            title, cover, author, types, chapters, status, updateDate,options,lastChapterId);
      }
    } catch (e) {
      if (_options.backupApi) {
        return this.getComicDetailBackup(comicId);
      } else {
        throw ComicLoadingError();
      }
    }
    return null;
  }

  Future<ComicDetail> getComicDetailBackup(String comicId) async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getComicDetailDark(comicId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.data)['data'];
        var title = data['info']['title'];
        var cover = data['info']['cover'];
        var author = [
          {'tag_name': data['info']['authors'], 'tag_id': null}
        ];
        var types = [
          {'tag_name': data['info']['types'], 'tag_id': null}
        ];
        var description = data['info']['description'];
        var updateDate = ToolMethods.formatTimestamp(
            int.parse(data['info']['last_updatetime']));
        //状态信息需要采取特殊处理
        var status = data['info']['status'];
        var chapters = [
          {
            'data': data['list']
                .map((e) => {
                      'chapter_id': e['id'],
                      'chapter_title': e['chapter_name'],
                      'updatetime': int.parse(e['updatetime'])
                    })
                .toList(),
            'title': '备用API'
          }
        ];
        DataBase dataBase = DataBase();
        var lastChapterId = await dataBase.getHistory(comicId);
        return DMZJComicDetail(comicId, description, 0, 0, title, cover, author,
            types, chapters, status, updateDate, options, lastChapterId);
      }
    } catch (e) {
      logger.w(
          'class: ComicDetailModel, action: detailBackupLoadingFailed, comicId: $comicId, exception: $e');
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
      SourceDetail('dmzj', '默认-动漫之家', '默认数据提供商，不可关闭', false, false);

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    return ChangeNotifierProvider(
      create: (_) => DMZJConfigProvider(_options),
      builder: (context, child) {
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: Provider.of<SystemSettingModel>(context).backupApi ? 2 : 1,
          itemBuilder: (context, index) {
            var list = [
              ListTile(
                title: Text('webApi'),
                subtitle: Text('是否开启webApi'),
                trailing: Switch(
                  value: Provider.of<DMZJConfigProvider>(context).webApi,
                  onChanged: (value) {
                    Provider.of<DMZJConfigProvider>(context, listen: false)
                        .webApi = value;
                  },
                ),
              ),
              ListTile(
                title: Text('备用API'),
                subtitle: Text('是否开启备用API'),
                trailing: Switch(
                  value: Provider.of<DMZJConfigProvider>(context).backupApi,
                  onChanged: (value) {
                    Provider.of<DMZJConfigProvider>(context, listen: false)
                        .backupApi = value;
                  },
                ),
              )
            ];
            return list[index];
          },
        );
      },
    );
  }

  @override
  // TODO: implement options
  SourceOptions get options => _options;
}

class DMZJWebSourceModel extends DMZJSourceModel {
  @override
  // TODO: implement _options
  DMZJSourceOptions get _options => _webSourceOptions;

  DMZJWebSourceOptions _webSourceOptions = DMZJWebSourceOptions.fromMap({});

  DMZJWebSourceModel() {
    init();
  }

  @override
  Future<void> init() async {
    // TODO: implement init
    var map = await SourceDatabaseProvider.getSourceOptions(type.name);
    _webSourceOptions = DMZJWebSourceOptions.fromMap(map);
  }

  @override
  Future<ComicDetail> get({String comicId, String title}) async {
    // TODO: implement get
    if (comicId == null) {
      throw IDInvalidError();
    }
    CustomHttp http = CustomHttp();
    try {
      var response = await http.getComicDetailWeb(comicId);
      if (response.statusCode == 200) {
        var jsonString =
            RegExp('initIntroData(.*);').stringMatch(response.data);
        var data = jsonDecode(jsonString.substring(
            'initIntroData('.length, jsonString.length - 2));
        BeautifulSoup doc = BeautifulSoup(response.data);
        var title = doc.find(id: '#comicName').text;
        var cover = doc.find(id: '#Cover').children.first.attributes['src'];
        var txtItem = doc.findAll('.txtItme');
        txtItem.forEach((element) {
          element.children.removeAt(0);
        });
        var author = txtItem.first.children
            .map<Map<String, dynamic>>(
                (e) => {'tag_name': e.innerHtml, 'tag_id': null})
            .toList();
        var types = txtItem[1]
            .children
            .map<Map<String, dynamic>>(
                (e) => {'tag_name': e.innerHtml, 'tag_id': null})
            .toList();
        var hotNum = 0;
        var subscribeNum = 0;
        var description = doc.find(id: '.txtDesc').innerHtml;
        var updateDate = doc.find(id: '.date').innerHtml;
        //状态信息需要采取特殊处理
        var status = txtItem[2]
            .children
            .map<String>((e) => e.innerHtml)
            .toList()
            .join('/');
        List<Map<String, dynamic>> chapters = [];
        for (var item in data) {
          var chapterList = [];
          for (var chapter in item['data']) {
            chapterList.add({
              'chapter_id': chapter['id'],
              'chapter_title': chapter['chapter_name'],
              'updatetime': 0
            });
          }
          chapters.add({"data": chapterList, 'title': item['title']});
        }
        DataBase dataBase = DataBase();
        var lastChapterId = await dataBase.getHistory(comicId);
        return DMZJComicDetail(
            comicId,
            description,
            hotNum,
            subscribeNum,
            title,
            cover,
            author,
            types,
            chapters,
            status,
            updateDate,
            options,
            lastChapterId);
      }
    } catch (e) {
      if (_options.backupApi) {
        return this.getComicDetailBackup(comicId);
      } else {
        throw ComicLoadingError();
      }
    }
    return null;
  }

  @override
  // TODO: implement type
  SourceDetail get type =>
      SourceDetail('dmzj-web', '动漫之家网页', '大妈之家的网络接口', true, false);

  @override
  // TODO: implement options
  SourceOptions get options => _options;

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    return super.getSettingWidget(context);
  }
}

class DMZJConfigProvider extends SourceOptionsProvider {
  final DMZJSourceOptions options;

  DMZJConfigProvider(this.options) : super(options);

  bool get webApi => options.webApi;

  set webApi(bool value) {
    options.webApi = value;
    notifyListeners();
  }

  bool get backupApi => options.backupApi;

  set backupApi(bool value) {
    options.backupApi = value;
    notifyListeners();
  }
}

class DMZJSourceOptions extends SourceOptions {
  bool _webApi;
  bool _backupApi;
  bool _deepSearch;

  DMZJSourceOptions.fromMap(Map map) {
    _webApi = map['web_api'] == '1';
    _backupApi = map['backup_api'] == '1';
    _deepSearch = map['deep_search'] == '1';
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {
      "web_api": webApi,
      "backup_api": backupApi,
      'deep_search': _deepSearch
    };
  }

  @override
  // TODO: implement active
  bool get active => true;

  @override
  set active(bool value) {
    // TODO: implement active
    return;
  }

  bool get webApi => _webApi;

  set webApi(bool value) {
    _webApi = value;
    SourceDatabaseProvider.insertSourceOption(
        'dmzj', 'web_api', value ? '1' : '0');
    notifyListeners();
  }

  bool get backupApi => _backupApi;

  set backupApi(bool value) {
    _backupApi = value;
    SourceDatabaseProvider.insertSourceOption(
        'dmzj', 'backup_api', value ? '1' : '0');
    notifyListeners();
  }

  bool get deepSearch => _deepSearch;

  set deepSearch(bool value) {
    _deepSearch = value;
    SourceDatabaseProvider.insertSourceOption(
        'dmzj', 'deep_search', value ? '1' : '0');
    notifyListeners();
  }
}

class DMZJWebSourceOptions extends DMZJSourceOptions {
  bool _active;

  DMZJWebSourceOptions.fromMap(Map map) : super.fromMap(map) {
    _active = map['active'] == '1';
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    var map = super.toMap();
    map['active'] = active;
    return map;
  }

  @override
  set active(bool value) {
    // TODO: implement active
    _active = value;
    SourceDatabaseProvider.insertSourceOption(
        'dmzj-web', 'active', value ? '1' : '0');
    notifyListeners();
  }

  @override
  // TODO: implement active
  bool get active => _active;
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
  final String _historyChapter;

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
      this.options,
      this._historyChapter);

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
  List<Map<String, dynamic>> getChapters() {
    // TODO: implement getChapters
    return this._chapters;
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

  @override
  // TODO: implement historyChapter
  String get historyChapter => _historyChapter;
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

  @override
  Future<void> addReadHistory({String title, String comicId, int page}) {
    // TODO: implement addReadHistory
    throw UnimplementedError();
  }

  @override
  // TODO: implement chapters
  List get chapters => _chapters;
}
