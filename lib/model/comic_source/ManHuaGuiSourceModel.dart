import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/utils/soup.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:provider/provider.dart';

class ManHuaGuiSourceModel extends BaseSourceModel {
  ManHuaGuiSourceOptions _options = ManHuaGuiSourceOptions.fromMap({});

  ManHuaGuiSourceModel() {
    init();
  }

  Future<void> init() async {
    var map = await SourceDatabaseProvider.getSourceOptions(type.name);
    _options = ManHuaGuiSourceOptions.fromMap(map);
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
      return await getManHuaGuiComic(map['bound_id']);
    } else if (title != null) {
      var list = await search(title);
      for (var item in list) {
        if (item.title == title) {
          if (comicId != null) {
            SourceDatabaseProvider.boundComic(type.name, comicId, item.comicId);
          }
          return await getManHuaGuiComic(item.comicId);
        }
      }
      throw ComicIdNotBoundError(comicId);
    } else if (title == null) {
      throw IDInvalidError();
    } else {
      throw ComicLoadingError(exception: Exception('未知的判断问题'));
    }
  }

  Future<ComicDetail> getManHuaGuiComic(String comicId) async {
    try {
      if (_options.enableProxy) {
        UniversalRequestModel.manHuaGuiRequestHandler.setProxy(_options.proxy, _options.port);
      }
      var response = await UniversalRequestModel.manHuaGuiRequestHandler.getComic(comicId);
      if (response.statusCode == 200) {
        var soup = BeautifulSoup(response.data);
        var contList = soup.find(id: '.cont-list');
        List authors = contList.children[3].children[1].children
            .map<Map<String, dynamic>>(
                (e) => {'tag_name': e.text, 'tag_id': null})
            .toList();
        List tags = contList.children[4].children[1].children
            .map<Map<String, dynamic>>(
                (e) => {'tag_name': e.text, 'tag_id': null})
            .toList();
        String description = soup.find(id: '#bookIntro').children.first.text;
        String title = soup.find(id: '.main-bar').children.first.text;
        String updateTime = contList.children[2].children[1].text;
        String status = contList.children.first.children[1].text;
        String cover = contList.children.first.children.first.attributes['src'];
        List chapters = soup
            .find(id: '#chapterList')
            .children
            .first
            .children
            .map<Map>((e) => {
                  'chapter_id': e.children.first.attributes['href']
                      .split('/')[3]
                      .replaceAll('.html', ''),
                  'chapter_title': e.children.first.children.first.text,
                  'updatetime': 0
                })
            .toList();
        return ManHuaGuiComicDetail(
            authors,
            comicId,
            cover,
            description,
            <Map<String, dynamic>>[
              {'data': chapters, 'title': '漫画柜连载'}
            ],
            status,
            tags,
            title,
            updateTime,
            _options,
            type);
      }
    } catch (e) {
      throw ComicLoadingError(exception: e);
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
    ComicDetail detail = await get(title: title, comicId: comicId);
    return detail.getChapter(chapterId: chapterId, title: chapterTitle);
  }

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    return ChangeNotifierProvider(
      create: (_) => ManHuaGuiOptionsProvider(_options),
      builder: (context, child) => ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            title: Text('当前Ping(点击测试)'),
            subtitle: Text(
                '${Provider.of<ManHuaGuiOptionsProvider>(context).ping} ms'),
            onTap: () async {

              if (Provider.of<ManHuaGuiOptionsProvider>(context, listen: false)
                  .enableProxy) {
                UniversalRequestModel.manHuaGuiRequestHandler.setProxy(
                    Provider.of<ManHuaGuiOptionsProvider>(context,
                            listen: false)
                        .proxy,
                    Provider.of<ManHuaGuiOptionsProvider>(context,
                            listen: false)
                        .port);
              }
              Provider.of<ManHuaGuiOptionsProvider>(context, listen: false)
                  .ping = await UniversalRequestModel.manHuaGuiRequestHandler.ping();
            },
          ),
          ListTile(
            title: Text('启用内置代理'),
            subtitle: Text('启用后将会根据下方代理服务器代理漫画柜流量，不开启则使用系统代理设置'),
            trailing: Switch(
              value: Provider.of<ManHuaGuiOptionsProvider>(context).enableProxy,
              onChanged: (value) {
                Provider.of<ManHuaGuiOptionsProvider>(context, listen: false)
                    .enableProxy = value;
              },
            ),
          ),
          ListTile(
            title: Text('代理服务器IP'),
            subtitle:
                Text('${Provider.of<ManHuaGuiOptionsProvider>(context).proxy}'),
            enabled: Provider.of<ManHuaGuiOptionsProvider>(context).enableProxy,
            onTap: () async {
              TextEditingController controller = TextEditingController(
                  text: Provider.of<ManHuaGuiOptionsProvider>(context,
                          listen: false)
                      .proxy);
              var data = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '代理服务器IP',
                            helperText: '代理服务器的IP地址，支持域名'),
                      ),
                      actions: [
                        FlatButton(
                          child: Text(S.of(context).Cancel),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).Confirm),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        )
                      ],
                    );
                  });
              if (data != null && data) {
                Provider.of<ManHuaGuiOptionsProvider>(context, listen: false)
                    .proxy = controller.text;
              }
            },
          ),
          ListTile(
            title: Text('代理服务器端口'),
            subtitle:
                Text('${Provider.of<ManHuaGuiOptionsProvider>(context).port}'),
            enabled: Provider.of<ManHuaGuiOptionsProvider>(context).enableProxy,
            onTap: () async {
              TextEditingController controller = TextEditingController(
                  text: Provider.of<ManHuaGuiOptionsProvider>(context,
                          listen: false)
                      .port
                      .toString());
              var data = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: TextField(
                        keyboardType: TextInputType.number,
                        controller: controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '代理服务器端口',
                            helperText: '代理服务器端口号'),
                      ),
                      actions: [
                        FlatButton(
                          child: Text(S.of(context).Cancel),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).Confirm),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        )
                      ],
                    );
                  });
              if (data != null && data) {
                Provider.of<ManHuaGuiOptionsProvider>(context, listen: false)
                    .port = int.parse(controller.text);
              }
            },
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement options
  SourceOptions get options => _options;

  @override
  Future<List<SearchResult>> search(String keyword, {int page: 0}) async {
    // TODO: implement search
    try {
      if (_options.enableProxy) {
        UniversalRequestModel.manHuaGuiRequestHandler.setProxy(_options.proxy, _options.port);
      }
      var response = await UniversalRequestModel.manHuaGuiRequestHandler.search(keyword);
      if (response.statusCode == 200) {
        var soup = BeautifulSoup(response.data);
        List<SearchResult> list = [];
        var content = soup.find(id: '#detail').children;
        for (var item in content) {
          String title = item.children[1].children[1].text;
          String author = item.children[1].children[2].children[1].text;
          String tag = item.children[1].children[3].children[1].text;
          var img = item.children[1].children[0].children.first;
          String cover = img.attributes['data-src'];
          String comicId = item.children[1].attributes['href']
              .replaceAll('/', '')
              .replaceAll('comic', '');
          list.add(ManHuaGuiSearchResult(author, comicId, cover, tag, title));
        }
        return list;
      }
    } catch (e) {
      throw ComicSearchError(e);
    }
    return [];
  }

  @override
  // TODO: implement type
  SourceDetail get type => SourceDetail('manhuagui', '漫画柜', '漫画柜漫画源，需要代理', true,
      SourceType.LocalDecoderSource, false, false);

  @override
  // TODO: implement userConfig
  UserConfig get userConfig => InactiveUserConfig(this.type);

  @override
  Future<List<FavoriteComic>> getFavoriteComics(int page) {
    // TODO: implement getFavoriteComics
    throw UnimplementedError();
  }
}

class ManHuaGuiSearchResult extends SearchResult {
  final String _author;
  final String _comicId;
  final String _cover;
  final String _tag;
  final String _title;

  ManHuaGuiSearchResult(
      this._author, this._comicId, this._cover, this._tag, this._title);

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
  // TODO: implement tag
  String get tag => _tag;

  @override
  // TODO: implement title
  String get title => _title;
}

class ManHuaGuiSourceOptions extends SourceOptions {
  bool _active = false;
  String _proxy = '';
  int _port = 0000;
  bool _enableProxy = false;

  ManHuaGuiSourceOptions.fromMap(Map map) {
    _active = map['active'] == '1';
    _proxy = map['proxy'];
    _port = map['port'] == null ? 0000 : int.parse(map['port']);
    _enableProxy = map['enable_proxy'] == '1';
  }

  @override
  bool get active => _active;

  set active(bool value) {
    _active = value;
    SourceDatabaseProvider.insertSourceOption(
        'manhuagui', 'active', value ? '1' : '0');
    notifyListeners();
  }

  bool get enableProxy => _enableProxy;

  set enableProxy(bool value) {
    _enableProxy = value;
    SourceDatabaseProvider.insertSourceOption(
        'manhuagui', 'enable_proxy', value ? '1' : '0');
    notifyListeners();
  }

  String get proxy => _proxy;

  set proxy(String value) {
    _proxy = value;
    SourceDatabaseProvider.insertSourceOption('manhuagui', 'proxy', value);
    notifyListeners();
  }

  int get port => _port;

  set port(int value) {
    _port = value;
    SourceDatabaseProvider.insertSourceOption(
        'manhuagui', 'port', value.toString());
    notifyListeners();
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {
      'active': active,
      'proxy': proxy,
      'port': port,
      'enable_proxy': enableProxy
    };
  }
}

class ManHuaGuiOptionsProvider extends SourceOptionsProvider {
  ManHuaGuiSourceOptions options;

  ManHuaGuiOptionsProvider(this.options) : super(options);

  String get proxy => options.proxy;

  set proxy(String value) {
    options.proxy = value;
    notifyListeners();
  }

  int get port => options.port;

  set port(int value) {
    options.port = value;
    notifyListeners();
  }

  bool get enableProxy => options.enableProxy;

  set enableProxy(bool value) {
    options.enableProxy = value;
    notifyListeners();
  }
}

class ManHuaGuiComicDetail extends ComicDetail {
  final List _authors;
  final String _comicId;
  final String _cover;
  final String _description;
  final List _chapters;
  final String _status;
  final List _tags;
  final String _title;
  final String _updateTime;
  final ManHuaGuiSourceOptions options;
  final SourceDetail sourceDetail;

  ManHuaGuiComicDetail(
      this._authors,
      this._comicId,
      this._cover,
      this._description,
      this._chapters,
      this._status,
      this._tags,
      this._title,
      this._updateTime,
      this.options,
      this.sourceDetail);

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
    if (chapterId == null) {
      throw IDInvalidError();
    }
    for (var item in _chapters) {
      for (var chapter in item['data']) {
        if (chapter['chapter_id'].toString() == chapterId) {
          return ManHuaGuiComic(chapterId, item['data'], _comicId, options);
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
  // TODO: implement headers
  Map<String, String> get headers => {'referer': 'https://m.manhuagui.com/'};

  @override
  // TODO: implement historyChapter
  String get historyChapter => '';

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
  bool isSubscribed = false;

  @override
  Future<void> getIfSubscribed() async {
    // TODO: implement getIfSubscribed
  }

  @override
  String share() {
    // TODO: implement share
    return '【$title】https://www.manhuagui.com/comic/$comicId/';
  }
}

class ManHuaGuiComic extends Comic {
  final String _chapterId;
  final List _chapters;
  final String _comicId;
  final ManHuaGuiSourceOptions options;

  int _previous;
  int _next;
  String _pageAt;
  String _title;
  List<String> _pages = [];

  ManHuaGuiComic(this._chapterId, this._chapters, this._comicId, this.options);

  @override
  Future<void> addReadHistory(
      {String title,
      String comicId,
      int page,
      String chapterTitle,
      String chapterId}) async {
    // TODO: implement addReadHistory
    return;
  }

  @override
  // TODO: implement canNext
  bool get canNext => _next != null && _next != 0;

  @override
  // TODO: implement canPrevious
  bool get canPrevious => _previous != null && _previous != 0;

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
    if (comicId == null || chapterId == null) {
      throw IDInvalidError();
    }
    try {
      if (options.enableProxy) {
        UniversalRequestModel.manHuaGuiRequestHandler.setProxy(options.proxy, options.port);
      }
      var response =
          await UniversalRequestModel.manHuaGuiRequestHandler.getChapter(comicId, chapterId);
      if (response.statusCode == 200) {
        var soup = BeautifulSoup(response.data);
        var scripts = soup.findAll('script');
        List<String> result = await ToolMethods.evalList([
          await rootBundle.loadString('assets/js/lzString.js'),
          'SMH={};SMH.reader=function(e,t){e;t;return {preInit:function(){return JSON.stringify(e);}}}',
          scripts[3].text
        ], url: 'about:blank');
        var data = jsonDecode(jsonDecode(result.last));
        _title = data['chapterTitle'];
        _next = data['nextId'];
        _previous = data['prevId'];
        _pageAt = chapterId;
        _pages = data['images']
            .map<String>((e) => 'https://i.hamreus.com' + e)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      throw ComicLoadingError(exception: e);
    }
  }

  @override
  Future<void> getViewPoint() async {
    // TODO: implement getViewPoint
    return;
  }

  @override
  // TODO: implement headers
  Map<String, String> get headers => {'referer': 'https://m.manhuagui.com/'};

  @override
  Future<void> init() async {
    // TODO: implement init
    await getComic(chapterId: _chapterId, comicId: _comicId);
  }

  @override
  Future<bool> next() async {
    // TODO: implement next
    if (canNext) {
      await getComic(chapterId: _next.toString(), comicId: _comicId);
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
      await getComic(chapterId: _previous.toString(), comicId: _comicId);
      return true;
    }
    return false;
  }

  @override
  // TODO: implement title
  String get title => _title;

  @override
  // TODO: implement type
  PageType get type => PageType.url;

  @override
  // TODO: implement viewpoints
  List get viewpoints => [];
}
