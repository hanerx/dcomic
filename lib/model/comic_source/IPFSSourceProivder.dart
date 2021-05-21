import 'dart:typed_data';

import 'package:dcomic/database/historyDatabaseProvider.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/http/IPFSSourceRequestHandler.dart';
import 'package:dcomic/model/comicCategoryModel.dart';
import 'package:dcomic/model/comicRankingListModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/ipfsSettingProvider.dart';
import 'package:dcomic/model/subjectDetailModel.dart';
import 'package:dcomic/model/subjectListModel.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class IPFSSourceProvider {
  List<String> address = [];
  List<Map> nodes = [];

  List<IPFSSourceModel> getSources() {
    // TODO: implement getSources
    try {
      List<IPFSSourceModel> data = [];
      for (var e in nodes) {
        if (e['error'] != true) {
          data.add(IPFSSourceModel(e['url'], e['name'], e['title'],
              e['description'], e['version'], e['type']));
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
        var response =
            await IPFSSourceRequestHandler(item, null).getServerState();
        if ((response.statusCode == 200||response.statusCode == 304)) {
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
      var response =
          await IPFSSourceRequestHandler(address, null).getServerState();
      if ((response.statusCode == 200||response.statusCode == 304)) {
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
  final String version;
  final int mode;

  IPFSSourceRequestHandler handler;

  IPFSSourceOptions _sourceOptions = IPFSSourceOptions.fromMap(null, {});

  IPFSUserConfig _userConfig;

  IPFSSourceModel(this.address, this.name, this.title, this.description,
      this.version, this.mode) {
    init();
  }

  Future<void> init() async {
    handler = IPFSSourceRequestHandler(this.address, this.type);
    _userConfig = IPFSUserConfig(handler, this.type);
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
      if ((response.statusCode == 200||response.statusCode == 304)) {
        var data = response.data['data'];
        var history = (await HistoryDatabaseProvider(this.type.name)
            .getReadHistory(comicId));
        var lastChapterId = history == null ? null : history['last_chapter_id'];
        return IPFSComicDetail(
            model: this,
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
            handler: handler,
            hotNum: data['hot_num']);
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
  Future<List<FavoriteComic>> getFavoriteComics(int page) async {
    // TODO: implement getFavoriteComics
    if (_userConfig.status != UserStatus.login) {
      throw LoginRequiredError();
    }
    try {
      var response = await handler.getSubscribe();
      if ((response.statusCode == 200||response.statusCode == 304)) {
        var data = await HistoryDatabaseProvider(name).getAllUnread();
        var unreadList = <String, int>{};
        for (var item in data.first) {
          unreadList[item['comicId']] = item['timestamp'];
        }
        return response.data['data'].map<FavoriteComic>((e) {
          var latestChapter = '暂无数据';
          try {
            latestChapter = e['data'].first['data'].first['title'];
          } catch (e) {
            latestChapter = '解析失败';
          }
          bool update = unreadList[e['comic_id']] == null ||
              unreadList[e['comic_id']] < e['timestamp'];
          return FavoriteComic(
              address + "/upload/ipfs/" + e['cover'],
              e['title'],
              latestChapter,
              e['comic_id'],
              this,
              update,
              PageType.url);
        }).toList();
      }
    } catch (e) {
      throw e;
    }
    return [];
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
  BaseHomePageHandler get homePageHandler => IPFSHompageHandler(handler, this);

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
        if ((response.statusCode == 200||response.statusCode == 304)) {
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
      sourceType: SourceType.CloudDecoderSource,
      canSubscribe: true);

  @override
  // TODO: implement userConfig
  IPFSUserConfig get userConfig => _userConfig;
}

class IPFSHompageHandler extends BaseHomePageHandler {
  final IPFSSourceRequestHandler handler;
  final IPFSSourceModel model;

  IPFSHompageHandler(this.handler, this.model);

  @override
  Future<List<RankingComic>> getAuthorComics(String authorId,
      {int page = 0, bool popular = true}) async {
    // TODO: implement getAuthorComics
    try {
      var response = await handler.getAuthor(authorId);
      if ((response.statusCode == 200||response.statusCode == 304)) {
        return response.data['data']
            .map<RankingComic>((e) => RankingComic(
                cover: handler.baseUrl + '/upload/ipfs/' + e['cover'],
                title: e['title'],
                model: model,
                comicId: e['comic_id'],
                types: e['tags']
                    .map<String>((e) => e['title'].toString())
                    .toList()
                    .join('/'),
                timestamp: e['timestamp']))
            .toList();
      }
    } catch (e, s) {
      throw e;
    }
    return [];
  }

  @override
  Future<List<CategoryModel>> getCategory({CategoryType type}) {
    // TODO: implement getCategory
    throw UnimplementedError();
  }

  @override
  Future<List<RankingComic>> getCategoryDetail(String categoryId,
      {int page = 0, bool popular = true}) async {
    // TODO: implement getCategoryDetail
    try {
      var response = await handler.getCategoryDetail(categoryId);
      if ((response.statusCode == 200||response.statusCode == 304)) {
        return response.data['data']
            .map<RankingComic>((e) => RankingComic(
                cover: handler.baseUrl + '/upload/ipfs/' + e['cover'],
                title: e['title'],
                model: model,
                comicId: e['comic_id'],
                types: e['tags']
                    .map<String>((e) => e['title'].toString())
                    .toList()
                    .join('/'),
                authors: e['authors']
                    .map<String>((e) => e['title'].toString())
                    .toList()
                    .join('/'),
                timestamp: e['timestamp']))
            .toList();
      }
    } catch (e, s) {
      throw e;
    }
    return [];
  }

  @override
  Future<List<HomePageCardModel>> getHomePage() {
    // TODO: implement getHomePage
    throw UnimplementedError();
  }

  @override
  Future<List<RankingComic>> getLatestUpdate(int page) {
    // TODO: implement getLatestUpdate
    throw UnimplementedError();
  }

  @override
  Future<List<RankingComic>> getRankingList(int page) {
    // TODO: implement getRankingList
    throw UnimplementedError();
  }

  @override
  Future<SubjectModel> getSubject(String subjectId) {
    // TODO: implement getSubject
    throw UnimplementedError();
  }

  @override
  Future<List<SubjectItem>> getSubjectList(int page) {
    // TODO: implement getSubjectList
    throw UnimplementedError();
  }
}

class IPFSUserConfig extends UserConfig {
  final IPFSSourceRequestHandler handler;
  final SourceDetail sourceDetail;
  String _token;
  String _username;
  String _nickname;
  String _avatar = 'QmSY5BqPor7aQD8EsSJvXdixkgLoAdQHP3uq5yX28jGwsT';
  UserStatus _status = UserStatus.logout;

  IPFSUserConfig(this.handler, this.sourceDetail) {
    init();
  }

  Future<void> init() async {
    if (await SourceDatabaseProvider.getSourceOption<bool>(
        sourceDetail.name, "login",
        defaultValue: false)) {
      try {
        var response = await handler.getUserState();
        _status = UserStatus.login;
        _nickname = response.data['data']['nickname'];
        _username = response.data['data']['username'];
        _token = await SourceDatabaseProvider.getSourceOption(
            sourceDetail.name, "token");
      } catch (e) {}
    }
  }

  @override
  // TODO: implement avatar
  String get avatar => _avatar;

  @override
  Widget getLoginWidget(context) {
    // TODO: implement getLoginWidget
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return FlutterEasyLoading(
        child: Scaffold(
      appBar: AppBar(
        title: Text('登录'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text('说明'),
                      children: <Widget>[
                        SimpleDialogOption(
                          child: Text(
                              '这次程序不是第三方的了，但是内容是来自服务器提供商的，所以本程序还是不保证能正常登录（'),
                        )
                      ],
                    );
                  });
            },
          )
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    'DComic',
                    style: TextStyle(
                        fontSize: 35,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '用户名',
                      icon: Icon(Icons.account_circle),
                      helperText: '分布式服务器用户名'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '密码',
                      icon: Icon(Icons.lock),
                      helperText: '分布式服务器密码'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '*本程序为第三方登录程序，存在登录风险',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        return ElevatedButton(
                          child: Text(
                            '登录',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            EasyLoading.instance
                              ..indicatorType =
                                  EasyLoadingIndicatorType.fadingCube;
                            EasyLoading.instance
                              ..maskType = EasyLoadingMaskType.black;
                            EasyLoading.show(status: "登录中");
                            try {
                              await login(usernameController.text,
                                  passwordController.text);
                              EasyLoading.dismiss();
                              Navigator.of(context).pop();
                            } on LoginUsernameOrPasswordError catch (e) {
                              EasyLoading.dismiss();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('用户名或密码错误！'),
                              ));
                            } catch (e) {
                              EasyLoading.dismiss();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('俺也不知道的错误'),
                              ));
                            }
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    var bytes = Provider.of<IPFSSettingProvider>(context, listen: false)
        .catBytes(avatar);
    return Card(
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            leading: FutureBuilder<Uint8List>(
              future: bytes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Icon(Icons.error);
                  } else {
                    return Image.memory(snapshot.data);
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            title: Text('${sourceDetail.title}用户设置'),
            subtitle: Text('昵称：$nickname 用户ID：$userId'),
            trailing: Icon(status == UserStatus.login
                ? Icons.cloud_done
                : Icons.cloud_off),
          ),
          Divider(),
          ListTile(
            enabled: status == UserStatus.login,
            title: Text('退出登录'),
            subtitle: Text('退出登录，字面意思'),
            onTap: () async {
              await logout();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Future<bool> login(String username, String password) async {
    // TODO: implement login
    try {
      var response = await handler.login(username, password);
      if ((response.statusCode == 200||response.statusCode == 304)) {
        _token = response.data['data']['token'];
        _username = username;
        _status = UserStatus.login;
        await SourceDatabaseProvider.insertSourceOption<bool>(
            sourceDetail.name, 'login', true);
        await SourceDatabaseProvider.insertSourceOption(
            sourceDetail.name, 'token', _token);
        var userResponse = await handler.getUserState();
        if ((userResponse.statusCode == 200||userResponse.statusCode == 304)) {
          _nickname = userResponse.data['data']['nickname'];
          _avatar = userResponse.data['data']['avatar'];
        }
        return true;
      }
    } catch (e) {
      throw e;
    }
    return false;
  }

  @override
  Future<bool> logout() async {
    // TODO: implement logout
    try {
      var response = await handler.logout();
      if ((response.statusCode == 200||response.statusCode == 304)) {
        _status = UserStatus.logout;
        await SourceDatabaseProvider.insertSourceOption<bool>(
            sourceDetail.name, 'login', false);
        return true;
      }
    } on DioError catch (e) {
      if (e.response.statusCode == 401) {
        _status = UserStatus.logout;
        await SourceDatabaseProvider.insertSourceOption<bool>(
            sourceDetail.name, 'login', false);
        return true;
      }
    } catch (e) {}
    return false;
  }

  @override
  // TODO: implement nickname
  String get nickname => _nickname;

  @override
  // TODO: implement status
  UserStatus get status => _status;

  @override
  // TODO: implement userId
  String get userId => _username;
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
  final int hotNum;
  final BaseSourceModel model;

  bool _isSubscribed = false;

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
      this.handler,
      this.hotNum,
      this.model});

  @override
  bool get isSubscribed => _isSubscribed;

  set isSubscribed(bool value) {
    if (value) {
      handler.addSubscribe(comicId);
    } else {
      handler.cancelSubscribe(comicId);
    }
    _isSubscribed = value;
  }

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
              handler: handler,
              model: model,
              detail: this);
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
  Future<List<ComicComment>> getComments(int page) async {
    // TODO: implement getComments
    throw UnimplementedError();
  }

  @override
  Future<void> getIfSubscribed() async {
    // TODO: implement getIfSubscribed
    try {
      var response = await handler.getIfSubscribe(comicId);
      if ((response.statusCode == 200||response.statusCode == 304)) {
        _isSubscribed = true;
      }
    } catch (e) {}
  }

  @override
  // TODO: implement headers
  Map<String, String> get headers => null;

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
  final IPFSSourceModel model;
  final IPFSComicDetail detail;

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
      @required this.handler,
      @required this.model,
      @required this.detail}) {
    _chapterIdList = chapters
        .map<String>((value) => value['chapter_id'].toString())
        .toList();
    _chapterIdList = List.generate(_chapterIdList.length,
        (index) => _chapterIdList[_chapterIdList.length - 1 - index]);
  }

  @override
  Future<void> addReadHistory() async {
    // TODO: implement addReadHistory
    HistoryDatabaseProvider(model.name).addReadHistory(
        comicId,
        detail.title,
        detail.cover,
        title,
        pageAt,
        DateTime.now().millisecondsSinceEpoch ~/ 1000);
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
      if ((response.statusCode == 200||response.statusCode == 304)) {
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
