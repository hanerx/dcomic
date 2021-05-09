import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/database/cookieDatabaseProvider.dart';
import 'package:dcomic/database/historyDatabaseProvider.dart';
import 'package:dcomic/model/comicCategoryModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/utils/soup.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class ManHuaGuiSourceModel extends BaseSourceModel {
  ManHuaGuiSourceOptions _options = ManHuaGuiSourceOptions.fromMap({});
  ManHuaGuiUserConfig _userConfig;

  ManHuaGuiSourceModel() {
    init();
  }

  Future<void> init() async {
    var map = await SourceDatabaseProvider.getSourceOptions(type.name);
    _options = ManHuaGuiSourceOptions.fromMap(map);
    _userConfig = ManHuaGuiUserConfig(_options);
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
        UniversalRequestModel.manHuaGuiRequestHandler
            .setProxy(_options.proxy, _options.port);
      }
      var response =
          await UniversalRequestModel.manHuaGuiRequestHandler.getComic(comicId);
      if (response.statusCode == 200) {
        var soup = BeautifulSoup(response.data);
        var contList = soup.find(id: '.cont-list');
        List authors = contList.children[3].children[1].children
            .map<CategoryModel>((e) =>
                CategoryModel(title: e.text, model: this, categoryId: null))
            .toList();
        List tags = contList.children[4].children[1].children
            .map<CategoryModel>((e) =>
                CategoryModel(title: e.text, model: this, categoryId: null))
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
        var history = (await HistoryDatabaseProvider(this.type.name)
            .getReadHistory(comicId));
        var lastChapterId = history == null ? null : history['last_chapter_id'];
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
            type,
            lastChapterId);
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
                      .ping =
                  await UniversalRequestModel.manHuaGuiRequestHandler.ping();
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
        UniversalRequestModel.manHuaGuiRequestHandler
            .setProxy(_options.proxy, _options.port);
      }
      var response =
          await UniversalRequestModel.manHuaGuiRequestHandler.search(keyword);
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
          String latestChapter = item.children[1].children[4].children[1].text;
          list.add(ManHuaGuiSearchResult(
              author, comicId, cover, tag, title, latestChapter));
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
  SourceDetail get type => SourceDetail(
      name: 'manhuagui',
      title: '漫画柜',
      description: '漫画柜漫画源，需要代理',
      canDisable: true,
      sourceType: SourceType.LocalDecoderSource,
      deprecated: false,
      canSubscribe: true);

  @override
  // TODO: implement userConfig
  UserConfig get userConfig => _userConfig;

  @override
  Future<List<FavoriteComic>> getFavoriteComics(int page) async {
    // TODO: implement getFavoriteComics
    if (_userConfig.status != UserStatus.login) {
      throw LoginRequiredError();
    }
    if (page == 0) {
      try {
        var response =
            await UniversalRequestModel.manHuaGuiRequestHandler.getSubscribe();
        if (response.statusCode == 200) {
          var soup = BeautifulSoup(response.data);
          var list = soup.find(id: '#detail').children;
          if (list.isEmpty) {
            return [];
          }
          var data = <FavoriteComic>[];
          var historyData =
              await HistoryDatabaseProvider(type.name).getAllUnread();
          var unreadList = <String, int>{};
          for (var item in historyData.first) {
            unreadList[item['comicId']] = item['timestamp'];
          }
          for (var item in list) {
            var cover = item.children[1].children.first.children.first
                .attributes['data-src'];
            var comicId = item.children[1].attributes['href']
                .replaceAll('/comic/', '')
                .replaceAll('/', '');
            var title = item.children[1].children[1].text;
            var latestChapter = item.children[1].children[4].children[1].text
                .substring(
                    0,
                    item.children[1].children[4].children[1].text
                        .lastIndexOf(' '));
            var timestamp = item.children[1].children[4].children[1].text
                .substring(item.children[1].children[4].children[1].text
                        .lastIndexOf(' ') +
                    1);
            bool update = unreadList[comicId] == null ||
                unreadList[comicId] <
                    ToolMethods.formatTimeStringForMangabz(timestamp);
            data.add(FavoriteComic(cover, title, latestChapter, comicId, this,
                update, PageType.url));
          }
          return data;
        }
      } catch (e) {
        throw e;
      }
    }
    return [];
  }

  @override
  // TODO: implement homePageHandler
  BaseHomePageHandler get homePageHandler => throw UnimplementedError();
}

class ManHuaGuiUserConfig extends UserConfig {
  UserStatus _status = UserStatus.logout;
  String _userId = '';

  final ManHuaGuiSourceOptions options;

  ManHuaGuiUserConfig(this.options) {
    init();
  }

  Future<void> init() async {
    if (await SourceDatabaseProvider.getSourceOption('manhuagui', 'login',
        defaultValue: false)) {
      try {
        if (options.enableProxy) {
          UniversalRequestModel.manHuaGuiRequestHandler
              .setProxy(options.proxy, options.port);
        }
        var response =
            await UniversalRequestModel.manHuaGuiRequestHandler.getLoginInfo();
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.data.toString());
          if (responseData['status'] == 1) {
            _userId = responseData['username'];
            _status = UserStatus.login;
            return true;
          }
        }
      } catch (e) {}
    }
  }

  @override
  // TODO: implement avatar
  String get avatar => '';

  @override
  Widget getLoginWidget(context) {
    // TODO: implement getLoginWidget
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return FlutterEasyLoading(
        child: Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child: CachedNetworkImage(
                  imageUrl: 'https://cf.hamreus.com/images/mhg.png',
                  httpHeaders: {'referer': 'https://www.manhuagui.com/'},
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
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
                      helperText: '昵称/手机号/邮箱'),
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
                      helperText: '漫画柜登录密码'),
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
            leading: Icon(Icons.account_circle),
            title: Text('漫画柜用户设置'),
            subtitle: Text('用户ID：$userId'),
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
      if (options.enableProxy) {
        UniversalRequestModel.manHuaGuiRequestHandler
            .setProxy(options.proxy, options.port);
      }
      var response = await UniversalRequestModel.manHuaGuiRequestHandler
          .login(username, password);
      var responseData = response.data.toString();
      var data = jsonDecode(responseData);
      if (data['status'] == 1) {
        for (var item in response.headers['set-cookie']) {
          var key = item.substring(0, item.indexOf("="));
          var value = item.substring(item.indexOf("=") + 1);
          CookieDatabaseProvider('manhuagui').insert(key, value);
        }
        try {
          var response = await UniversalRequestModel.manHuaGuiRequestHandler
              .getLoginInfo();
          if (response.statusCode == 200) {
            var responseData = jsonDecode(response.data.toString());
            if (responseData['status'] == 1) {
              _userId = responseData['username'];
              _status = UserStatus.login;
              SourceDatabaseProvider.insertSourceOption<bool>(
                  'manhuagui', 'login', true);
              return true;
            }
          }
        } catch (e) {
          throw e;
        }
      } else if (data['status'] == 0) {
        throw LoginUsernameOrPasswordError();
      }
    } catch (e) {
      logger.e('class: DMZJUserConfig, action: loginFailed, exception: $e');
      throw e;
    }
    return false;
  }

  @override
  Future<bool> logout() async {
    // TODO: implement logout
    _status = UserStatus.logout;
    SourceDatabaseProvider.insertSourceOption<bool>(
        'manhuagui', 'login', false);
    return true;
  }

  @override
  // TODO: implement nickname
  String get nickname => '';

  @override
  // TODO: implement status
  UserStatus get status => _status;

  @override
  // TODO: implement userId
  String get userId => _userId;
}

class ManHuaGuiSearchResult extends SearchResult {
  final String _author;
  final String _comicId;
  final String _cover;
  final String _tag;
  final String _title;
  final String _latestChapter;

  ManHuaGuiSearchResult(this._author, this._comicId, this._cover, this._tag,
      this._title, this._latestChapter);

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

  @override
  // TODO: implement latestChapter
  String get latestChapter => _latestChapter;
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
  final List<CategoryModel> _authors;
  final String _comicId;
  final String _cover;
  final String _description;
  final List _chapters;
  final String _status;
  final List<CategoryModel> _tags;
  final String _title;
  final String _updateTime;
  final ManHuaGuiSourceOptions options;
  final SourceDetail sourceDetail;
  final String _historyChapter;

  Map comments = {};

  bool _isSubscribed = false;

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
      this.sourceDetail,
      this._historyChapter);

  @override
  // TODO: implement authors
  List<CategoryModel> get authors => _authors;

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
          return ManHuaGuiComic(
              chapterId, item['data'], _comicId, options, this);
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
  String get historyChapter => _historyChapter;

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
  List<CategoryModel> get tags => _tags;

  @override
  // TODO: implement title
  String get title => _title;

  @override
  // TODO: implement updateTime
  String get updateTime => _updateTime;

  @override
  bool get isSubscribed => _isSubscribed;

  set isSubscribed(bool value) {
    if (value) {
      UniversalRequestModel.manHuaGuiRequestHandler.addSubscribe(comicId);
    } else {
      UniversalRequestModel.manHuaGuiRequestHandler.cancelSubscribe(comicId);
    }
    _isSubscribed = value;
  }

  @override
  Future<void> getIfSubscribed() async {
    // TODO: implement getIfSubscribed
    try {
      var response = await UniversalRequestModel.manHuaGuiRequestHandler
          .getIfSubscribe(comicId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.data);
        if (data['status'] == 1) {
          _isSubscribed = true;
        }
      }
    } catch (e, s) {}
  }

  @override
  String share() {
    // TODO: implement share
    return '【$title】https://www.manhuagui.com/comic/$comicId/';
  }

  @override
  Future<List<ComicComment>> getComments(int page) async {
    // TODO: implement getComments
    try {
      var response = await UniversalRequestModel.manHuaGuiRequestHandler
          .getComicComments(comicId, page);
      if (response.statusCode == 200 || response.statusCode == 304) {
        response.data = jsonDecode(response.data);
        var idList = response.data['commentIds'];
        comments.addAll(response.data['comments']);
        var data = <ComicComment>[];
        for (String item in idList) {
          var commentList = item.split(',');
          var firstComment = comments[commentList.first];
          data.add(ComicComment(
              avatar: firstComment['avatar'],
              nickname: firstComment['user_name'] == ""
                  ? "匿名"
                  : firstComment['user_name'],
              content: firstComment['content'],
              timestamp: ToolMethods.formatTimeString(firstComment['add_time']),
              like: int.parse(firstComment['support_count'].toString()),
              upload_image: null,
              reply: commentList.sublist(1).map<Map>((e) {
                if (comments[e] == null) {
                  return {
                    'avatar': 'https://avatar.dmzj.com/default.png',
                    'nickname': '异次元',
                    'content': '被异次元吞噬的评论'
                  };
                }
                return {
                  'avatar': comments[e]['avatar'],
                  'nickname': comments[e]['user_name'] == ""
                      ? "匿名"
                      : comments[e]['user_name'],
                  'content': comments[e]['content']
                };
              }).toList()));
        }
        return data;
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'getComicCommentFailed: $comicId');
      throw e;
    }
    return [];
  }
}

class ManHuaGuiComic extends Comic {
  final String _chapterId;
  final List _chapters;
  final String _comicId;
  final ManHuaGuiSourceOptions options;
  final ComicDetail _detail;

  int _previous;
  int _next;
  String _pageAt;
  String _title;
  List<String> _pages = [];

  ManHuaGuiComic(this._chapterId, this._chapters, this._comicId, this.options,
      this._detail);

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
    HistoryDatabaseProvider('manhuagui').addReadHistory(
        comicId,
        _detail.title,
        _detail.cover,
        chapterTitle,
        pageAt,
        DateTime.now().millisecondsSinceEpoch ~/ 1000);
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
        UniversalRequestModel.manHuaGuiRequestHandler
            .setProxy(options.proxy, options.port);
      }
      var response = await UniversalRequestModel.manHuaGuiRequestHandler
          .getChapter(comicId, chapterId);
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
        addReadHistory(
            comicId: comicId,
            page: 0,
            chapterTitle: _title,
            chapterId: chapterId);
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
