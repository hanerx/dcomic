import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/database/historyDatabaseProvider.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lpinyin/lpinyin.dart';

class CopyMangaSourceModel extends BaseSourceModel {
  CopyMangaUserConfig _userConfig = CopyMangaUserConfig();
  CopyMangaSourceOptions _options = CopyMangaSourceOptions.fromMap({});

  CopyMangaSourceModel() {
    init();
  }

  Future<void> init() async {
    var map = await SourceDatabaseProvider.getSourceOptions(type.name);
    _options = CopyMangaSourceOptions.fromMap(map);
  }

  @override
  Future<ComicDetail> get({String comicId, String title}) async {
    // TODO: implement get
    if (comicId == null && title == null) {
      throw IDInvalidError();
    } else if (comicId != null && !RegExp('[0-9]+').hasMatch(comicId)) {
      return await getComicDetail(comicId);
    } else if (comicId != null &&
        await SourceDatabaseProvider.getBoundComic(type.name, comicId) !=
            null) {
      var map = await SourceDatabaseProvider.getBoundComic(type.name, comicId);
      return await getComicDetail(map['bound_id']);
    } else if (title != null) {
      var list = await search(title);
      for (var item in list) {
        if (item.title == title) {
          if (comicId != null) {
            SourceDatabaseProvider.boundComic(type.name, comicId, item.comicId);
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

  Future<ComicDetail> getComicDetail(String comicId) async {
    try {
      var response = await UniversalRequestModel.copyMangaRequestHandler
          .getComicDetail(comicId);
      if (response.statusCode == 200 && response.data['code'] == 200) {
        var data = response.data['results']['comic'];
        var historyChapter = await getHistoryChapter(comicId);
        Map groups = response.data['results']['groups'];
        List<Map<String, dynamic>> chapters = [];
        for (var item in groups.values) {
          var chapter = await UniversalRequestModel.copyMangaRequestHandler
              .getChapters(comicId, item['path_word'], limit: item['count']);
          if (chapter.statusCode == 200 && chapter.data['code'] == 200) {
            List chapterData = chapter.data['results']['list']
                .map<Map>((e) => {
                      'chapter_id': e['uuid'],
                      'chapter_title':
                          ChineseHelper.convertToSimplifiedChinese(e['name']),
                      'updatetime':
                          ToolMethods.formatTimeString(e['datetime_created']) ~/
                              1000
                    })
                .toList();
            chapterData = List.generate(chapterData.length,
                (index) => chapterData[chapterData.length - 1 - index]);
            chapters.add({
              'title': ChineseHelper.convertToSimplifiedChinese(item['name']),
              'data': chapterData
            });
          }
        }
        return CopyMangaComicDetail(
            data['uuid'],
            data['path_word'],
            ChineseHelper.convertToSimplifiedChinese(data['name']),
            data['cover'],
            ChineseHelper.convertToSimplifiedChinese(data['brief']),
            historyChapter,
            data['popular'],
            ChineseHelper.convertToSimplifiedChinese(data['status']['display']),
            data['theme']
                .map<Map>((e) => {
                      'tag_name':
                          ChineseHelper.convertToSimplifiedChinese(e['name']),
                      'tag_id': e['path_word']
                    })
                .toList(),
            data['author']
                .map<Map>((e) => {
                      'tag_name':
                          ChineseHelper.convertToSimplifiedChinese(e['name']),
                      'tag_id': e['path_word']
                    })
                .toList(),
            data['datetime_updated'],
            chapters,
            type);
      }
    } catch (e) {
      throw ComicLoadingError(exception: e);
    }
    throw ComicLoadingError();
  }

  Future<String> getHistoryChapter(String comicId) async {
    var history =
        (await HistoryDatabaseProvider(this.type.name).getReadHistory(comicId));
    var lastChapterId = history == null ? null : history['last_chapter_id'];
    if (_userConfig.status == UserStatus.login) {
      try {
        var cloudHistory = await UniversalRequestModel.copyMangaRequestHandler
            .getIfSubscribe(comicId);
        if (lastChapterId == null &&
            cloudHistory.statusCode == 200 &&
            cloudHistory.data['code'] == 200) {
          if (cloudHistory.data['results']['browse'] != null) {
            lastChapterId =
                cloudHistory.data['result']['browse']['chapter_uuid'];
          }
        }
      } catch (e) {}
    }
    return lastChapterId;
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
  Future<List<FavoriteComic>> getFavoriteComics(int page) async {
    // TODO: implement getFavoriteComics
    if (_userConfig.status == UserStatus.login) {
      try {
        var response = await UniversalRequestModel.copyMangaRequestHandler
            .getSubscribe(page: page);
        if (response.statusCode == 200 && response.data['code'] == 200) {
          List list = response.data['results']['list'];
          List data = list.map<Map>((e) => e['comic']).toList();
          var unread = await HistoryDatabaseProvider(type.name).getAllUnread();
          var unreadList = <String, int>{};
          for (var item in unread.first) {
            unreadList[item['comicId']] = item['timestamp'];
          }
          return data
              .map<FavoriteComic>((e) => FavoriteComic(
                  e['cover'],
                  e['name'],
                  e['last_chapter_name'],
                  e['path_word'],
                  this,
                  unreadList[e['path_word']] != null &&
                      unreadList[e['path_word']] <
                          ToolMethods.formatTimeString(e['datetime_updated'])))
              .toList();
        }
      } catch (e) {
        throw e;
      }
    }
    throw LoginRequiredError();
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
  Future<List<SearchResult>> search(String keyword, {int page = 0}) async {
    // TODO: implement search
    try {
      var response = await UniversalRequestModel.copyMangaRequestHandler
          .search(keyword, page: page);
      if (response.statusCode == 200 && response.data['code'] == 200) {
        List data = response.data['results']['list'];
        return data
            .map<CopyMangaSearchResult>((e) => CopyMangaSearchResult(
                e['author']
                    .map((e) =>
                        ChineseHelper.convertToSimplifiedChinese(e['name']))
                    .toList()
                    .join('/'),
                e['path_word'],
                e['cover'],
                ChineseHelper.convertToSimplifiedChinese(e['name'])))
            .toList();
      }
    } catch (e) {
      throw ComicSearchError(e);
    }
    return [];
  }

  @override
  // TODO: implement type
  SourceDetail get type => SourceDetail(
      name: 'copy_manga',
      title: '拷贝漫画',
      description: '拷贝漫画，万能的网友提供的网站，还蛮顶的',
      sourceType: SourceType.LocalDecoderSource,
      canSubscribe: true);

  @override
  // TODO: implement userConfig
  UserConfig get userConfig => _userConfig;
}

class CopyMangaSourceOptions extends SourceOptions {
  bool _active = false;

  CopyMangaSourceOptions.fromMap(Map map) {
    _active = map['active'] == '1';
  }

  bool get active => _active;

  set active(bool value) {
    _active = value;
    SourceDatabaseProvider.insertSourceOption<bool>(
        'copy_manga', 'active', value);
    notifyListeners();
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {};
  }
}

class CopyMangaUserConfig extends UserConfig {
  String _avatar = 'https://mirrorvip.mangafunc.fun:12001/copymanga.png';
  String _nickname = '';
  String _userId = '';
  UserStatus _status = UserStatus.logout;

  @override
  // TODO: implement avatar
  String get avatar => _avatar;

  CopyMangaUserConfig() {
    init();
  }

  Future<void> init() async {
    _status = await SourceDatabaseProvider.getSourceOption<bool>(
            'copy_manga', 'login')
        ? UserStatus.login
        : UserStatus.logout;
    if (_status == UserStatus.login) {
      try {
        var response =
            await UniversalRequestModel.copyMangaRequestHandler.getUserInfo();
        if (response.statusCode == 200 && response.data['code'] == 200) {
          var data = response.data['results'];
          _avatar = data['avatar'];
          _nickname = data['nickname'];
          _userId = data['user_id'];
        }
      } catch (e) {
        _status = UserStatus.logout;
        await SourceDatabaseProvider.insertSourceOption<bool>(
            'copy_manga', 'login', false);
      }
    }
  }

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
                              '本程序为第三方程序，登录采用调用拷贝漫画官方网页端的接口实现。本程序承诺不会将您的信息透露给任何第三方机构。由于本程序并未获得拷贝漫画官方授权，您的账号使用本程序登录可能造成不可预见的风险，您使用本程序登录即代表您了解并同意承担本程序可能带来的风险。'),
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
                    '拷贝漫画',
                    style: TextStyle(
                        fontSize: 35,
                        color: Theme.of(context).accentColor,
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
                      helperText: '拷贝漫画用户名'),
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
                      helperText: '拷贝漫画密码'),
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
    return Card(
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            leading: CachedNetworkImage(
              imageUrl: '$avatar!m_avatar',
              httpHeaders: {'referer': 'https://copymanga.com/'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => CachedNetworkImage(
                imageUrl:
                    'https://mirrorvip.mangafunc.fun:12001/copymanga.png!m_avatar',
                httpHeaders: {'referer': 'https://copymanga.com/'},
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.warning),
              ),
            ),
            title: Text('拷贝漫画用户设置'),
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
          ),
          ListTile(
            title: Text('重新获取用户状态'),
            subtitle: Text('因为这个账号是必须单点登录的，但是我们并不知道什么时候就失效了，所有点击这个重新检查是否登录'),
            onTap: () async {
              await init();
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
      var response = await UniversalRequestModel.copyMangaRequestHandler
          .login(username, password);
      if (response.statusCode == 200) {
        if (response.data['code'] == 200) {
          var data = response.data['results'];
          _status = UserStatus.login;
          _userId = data['user_id'];
          _nickname = data['nickname'];
          _avatar = 'https://mirrorvip.mangafunc.fun:12001/' + data['avatar'];
          await SourceDatabaseProvider.insertSourceOption<bool>(
              'copy_manga', 'login', true);
          await SourceDatabaseProvider.insertSourceOption(
              'copy_manga', 'token', data['token']);
          notifyListeners();
          return true;
        } else if (response.data['code'] == 210) {
          throw LoginUsernameOrPasswordError();
        }
      }
    } on LoginUsernameOrPasswordError catch (e) {
      throw e;
    } catch (e) {}
    return false;
  }

  @override
  Future<bool> logout() async {
    // TODO: implement logout
    try {
      await UniversalRequestModel.copyMangaRequestHandler.logout();
      _status = UserStatus.logout;
      await SourceDatabaseProvider.insertSourceOption<bool>(
          'copy_manga', 'login', false);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  // TODO: implement nickname
  String get nickname => _nickname;

  @override
  // TODO: implement status
  UserStatus get status => _status;

  @override
  // TODO: implement userId
  String get userId => _userId;
}

class CopyMangaSearchResult extends SearchResult {
  final String _author;
  final String _comicId;
  final String _cover;
  final String _title;

  CopyMangaSearchResult(this._author, this._comicId, this._cover, this._title);

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
  String get latestChapter => '暂无数据';

  @override
  // TODO: implement tag
  String get tag => '暂无数据';

  @override
  // TODO: implement title
  String get title => _title;
}

class CopyMangaComicDetail extends ComicDetail {
  final String uuid;
  final String _comicId;
  final String _title;
  final String _cover;
  final String _description;
  final String _historyChapter;
  final int _popular;
  final String _status;
  final List _tags;
  final List _authors;
  final String _updateTime;
  final List _chapters;
  final SourceDetail _sourceDetail;
  bool _isSubscribed = false;

  bool get isSubscribed => _isSubscribed;

  set isSubscribed(bool value) {
    _isSubscribed = value;
    UniversalRequestModel.copyMangaRequestHandler.addSubscribe(uuid, value);
    notifyListeners();
  }

  CopyMangaComicDetail(
      this.uuid,
      this._comicId,
      this._title,
      this._cover,
      this._description,
      this._historyChapter,
      this._popular,
      this._status,
      this._tags,
      this._authors,
      this._updateTime,
      this._chapters,
      this._sourceDetail);

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
          return CopyMangaComic(_comicId, chapterId, item['data'], this);
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
  Future<void> getIfSubscribed() async {
    // TODO: implement getIfSubscribed
    if (await SourceDatabaseProvider.getSourceOption<bool>(
        'copy_manga', 'login',
        defaultValue: false)) {
      try {
        var response = await UniversalRequestModel.copyMangaRequestHandler
            .getIfSubscribe(comicId);
        if (response.statusCode == 200 && response.data['code'] == 200) {
          _isSubscribed = response.data['results']['collect'] != null;
        }
      } catch (e) {
        logger.e('action: getSubscribeFailed');
      }
    }
  }

  @override
  // TODO: implement headers
  Map<String, String> get headers => {'referer': 'https://copymanga.com'};

  @override
  // TODO: implement historyChapter
  String get historyChapter => _historyChapter;

  @override
  // TODO: implement hotNum
  int get hotNum => _popular;

  @override
  String share() {
    // TODO: implement share
    return '【$title】 https://copymanga.com/h5/details/comic/$comicId';
  }

  @override
  // TODO: implement sourceDetail
  SourceDetail get sourceDetail => _sourceDetail;

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
}

class CopyMangaComic extends Comic {
  final String _comicId;
  final String _chapterId;
  final List _chapters;
  final CopyMangaComicDetail _detail;

  String _previous;
  String _next;
  String _pageAt;
  String _title;
  List<String> _pages = [];

  CopyMangaComic(this._comicId, this._chapterId, this._chapters, this._detail);

  @override
  Future<void> addReadHistory(
      {String title,
      String comicId,
      int page,
      String chapterTitle,
      String chapterId}) async {
    // TODO: implement addReadHistory
    if (comicId == null || chapterId == null) {
      throw IDInvalidError();
    }
    HistoryDatabaseProvider('dmzj').addReadHistory(
        comicId,
        _detail.title,
        _detail.cover,
        chapterTitle,
        chapterId,
        DateTime.now().millisecondsSinceEpoch ~/ 1000);
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
    try {
      var response = await UniversalRequestModel.copyMangaRequestHandler
          .getComic(comicId, chapterId);
      if (response.statusCode == 200 && response.data['code'] == 200) {
        var data = response.data['results'];
        _pageAt = chapterId;
        _title = data['chapter']['name'];
        _pages = data['chapter']['contents']
            .map<String>((e) => e['url'].toString())
            .toList();
        _previous = data['chapter']['prev'];
        _next = data['chapter']['next'];
        addReadHistory(
            chapterId: chapterId, comicId: comicId, chapterTitle: _title);
        notifyListeners();
      }
    } catch (e) {
      throw ComicLoadingError(exception: e);
    }
  }

  @override
  Future<void> getViewPoint() async {
    // TODO: implement getViewPoint
  }

  @override
  // TODO: implement headers
  Map<String, String> get headers => {'referer': 'https://copymanga.com'};

  @override
  Future<void> init() async {
    // TODO: implement init
    await getComic(comicId: comicId, chapterId: chapterId);
  }

  @override
  Future<bool> next() async {
    // TODO: implement next
    if (canNext) {
      await getComic(chapterId: _next, comicId: comicId);
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
  PageType get type => PageType.url;

  @override
  // TODO: implement viewpoints
  List get viewpoints => [];
}
