import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:dcomic/database/cookieDatabaseProvider.dart';
import 'package:dcomic/database/database.dart';
import 'package:dcomic/database/downloader.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/utils/soup.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/systemSettingModel.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';

class DMZJSourceModel extends BaseSourceModel {
  DMZJSourceOptions _options = DMZJSourceOptions.fromMap({});
  DMZJUserConfig _userConfig = DMZJUserConfig();

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
        var chapters = response.data['chapters']
            .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
            .toList();
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
  Future<List<SearchResult>> search(String keyword, {int page: 0}) async {
    // TODO: implement search
    return [];
  }

  @override
  // TODO: implement type
  SourceDetail get type => SourceDetail('dmzj', '默认-动漫之家', '默认数据提供商，不可关闭',
      false, SourceType.LocalDecoderSource, false);

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

  @override
  // TODO: implement userConfig
  UserConfig get userConfig => _userConfig;
}

class DMZJUserConfig extends UserConfig {
  String _avatar = 'https://avatar.dmzj.com/default.png';
  String _uid = '';
  String _nickname = '';
  UserStatus _status = UserStatus.logout;

  DMZJUserConfig() {
    init();
  }

  Future<void> init() async {
    _status =
        await SourceDatabaseProvider.getSourceOption<bool>('dmzj', 'login',defaultValue: false)
            ? UserStatus.login
            : UserStatus.logout;
    if (_status == UserStatus.login) {
      _uid =
          await SourceDatabaseProvider.getSourceOption<String>('dmzj', 'uid');
      try {
        var response =
            await UniversalRequestModel().dmzjRequestHandler.getUserInfo(_uid);
        if (response.statusCode == 200) {
          _avatar = response.data['cover'];
          _nickname = response.data['nickname'];
        }
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
                              '本程序为第三方程序，登录采用调用动漫之家官方的接口实现。本程序承诺除保存登录凭证外不会收集任何数据信息，同时不会将您的信息透露给任何第三方机构。由于本程序并未获得动漫之家官方授权，您的账号使用本程序登录可能造成不可预见的风险，您使用本程序登录即代表您了解并同意承担本程序可能带来的风险。'),
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
                child: CachedNetworkImage(
                  imageUrl:
                      'https://static.dmzj.com/public/images/logo-new.png',
                  httpHeaders: {'referer': 'http://images.dmzj.com'},
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
                      helperText: '动漫之家登录密码'),
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
                        return RaisedButton(
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
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('用户名或密码错误！'),
                              ));
                            } catch (e) {
                              EasyLoading.dismiss();
                              Scaffold.of(context).showSnackBar(SnackBar(
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
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          FontAwesome5.qq,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          EasyLoading.instance
                            ..indicatorType =
                                EasyLoadingIndicatorType.fadingCube;
                          EasyLoading.instance
                            ..maskType = EasyLoadingMaskType.black;
                          EasyLoading.show(status: "登录中");
                          if (await loginForQQ(context)) {
                            EasyLoading.dismiss();
                            Navigator.of(context).pop();
                          } else {
                            EasyLoading.dismiss();
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('快捷登录失败'),
                            ));
                          }
                        },
                      ),
                    )
                  ],
                ),
              )
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
        children: [
          ListTile(
            leading: CachedNetworkImage(
              imageUrl: avatar,
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => CachedNetworkImage(
                imageUrl: 'https://avatar.dmzj.com/default.png',
                httpHeaders: {'referer': 'http://images.dmzj.com'},
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.warning),
                ),
              ),
            ),
            title: Text('DMZJ用户设置'),
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

  Future<bool> loginForQQ(context) async {
    FlutterWebviewPlugin webView = FlutterWebviewPlugin();
    bool result = false;
    var state = false;
    webView.onUrlChanged.listen((String url) {
      if (url == 'https://m.dmzj.com/') {
        webView.evalJavascript("document.cookie").then((value) async {
          if (!state) {
            try {
              state = true;
              webView.close();
              var data =
                  value.replaceAll(" ", "").replaceAll("\"", "").split(';');
              print(data);
              for (var item in data) {
                var key = item.substring(0, item.indexOf("="));
                var value = item.substring(item.indexOf("=") + 1);
                CookieDatabaseProvider('dmzj').insert(key, value);
                if (key == 'my') {
                  var decodeDetail =
                      Uri.decodeComponent(Uri.decodeComponent(value));
                  var list = decodeDetail.split("|");
                  SourceDatabaseProvider.insertSourceOption(
                      'dmzj', 'uid', list[0]);
                  SourceDatabaseProvider.insertSourceOption(
                      'dmzj', 'login', '1');
                  _uid = list[0];
                  _status = UserStatus.login;
                  try {
                    var response =
                    await UniversalRequestModel().dmzjRequestHandler.getUserInfo(_uid);
                    if (response.statusCode == 200) {
                      _avatar = response.data['cover'];
                      _nickname = response.data['nickname'];
                    }
                  } catch (e) {}
                  result = true;
                }
              }
            } catch (e) {
              print(e);
            }
          }
        });
      }
    });
    webView.onBack.listen((url) async {
      if (!await webView.canGoBack()) {
        webView.close();
      }
    });
    await webView.launch(
        'https://graph.qq.com/oauth2.0/authorize?client_id=101144087&display=pc&redirect_uri=https://i.dmzj.com/login/qq&response_type=code&state=http://m.dmzj.com/',
        userAgent:
            'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36');
    return result;
  }

  @override
  Future<bool> login(String username, String password) async {
    // TODO: implement login
    try {
      var response = await UniversalRequestModel()
          .dmzjiRequestHandler
          .login(username, password);
      var responseData = response.data.toString();
      var data = jsonDecode(responseData.substring(1, responseData.length - 1));
      if (data['code'] == 1000) {
        for (var item in response.headers['set-cookie']) {
          var key = item.substring(0, item.indexOf("="));
          var value = item.substring(item.indexOf("=") + 1);
          CookieDatabaseProvider('dmzj').insert(key, value);
          if (key == 'my') {
            var detail = value.substring(0, value.indexOf(";"));
            var decodeDetail = Uri.decodeComponent(Uri.decodeComponent(detail));
            var list = decodeDetail.split("|");
            SourceDatabaseProvider.insertSourceOption('dmzj', 'uid', list[0]);
            SourceDatabaseProvider.insertSourceOption('dmzj', 'login', '1');
            _uid = list[0];
            _status = UserStatus.login;
            try {
              var response =
              await UniversalRequestModel().dmzjRequestHandler.getUserInfo(_uid);
              if (response.statusCode == 200) {
                _avatar = response.data['cover'];
                _nickname = response.data['nickname'];
              }
            } catch (e) {}
          }
        }
        return true;
      } else if (data['code'] == 801 || data['code'] == 803) {
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
    await SourceDatabaseProvider.insertSourceOption('dmzj', 'login', '0');
    _status = UserStatus.logout;
    return true;
  }

  @override
  // TODO: implement nickname
  String get nickname => _nickname;

  @override
  // TODO: implement status
  UserStatus get status => _status;

  @override
  // TODO: implement userId
  String get userId => _uid;
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
  SourceDetail get type => SourceDetail('dmzj-web', '动漫之家网页',
      '使用大妈之家移动网页版的接口，让漫画重新可以看了', true, SourceType.LocalDecoderSource, false);

  @override
  // TODO: implement options
  SourceOptions get options => _options;

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    return super.getSettingWidget(context);
  }

  @override
  // TODO: implement userConfig
  UserConfig get userConfig => InactiveUserConfig(this.type,message: '请使用动漫之家默认用户管理，网页端与默认端同步');
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

  @override
  set backupApi(bool value) {
    // TODO: implement backupApi
    _backupApi = value;
    SourceDatabaseProvider.insertSourceOption(
        'dmzj-web', 'backup_api', value ? '1' : '0');
    notifyListeners();
  }

  @override
  set webApi(bool value) {
    // TODO: implement webApi
    _webApi = value;
    SourceDatabaseProvider.insertSourceOption(
        'dmzj-web', 'web_api', value ? '1' : '0');
    notifyListeners();
  }
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
      for (var chapter in item['data']) {
        if (chapter['chapter_id'].toString() == chapterId) {
          return DMZJComic(_comicId, chapterId, item['data'], options);
        }
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

  @override
  // TODO: implement headers
  Map<String, String> get headers => {'referer': 'http://images.dmzj.com'};
}

class DMZJComic extends Comic {
  final String _comicId;
  final String _chapterId;
  final List _chapters;
  final DMZJSourceOptions options;
  List<String> _pages = [];
  String _title;
  List<String> _chapterIdList;
  int _type = 0;
  List _viewPoints = [];

  String _previous;
  String _next;
  String _pageAt;

  DMZJComic(this._comicId, this._chapterId, this._chapters, this.options) {
    _chapterIdList = _chapters
        .map<String>((value) => value['chapter_id'].toString())
        .toList();
    _chapterIdList = List.generate(_chapterIdList.length,
        (index) => _chapterIdList[_chapterIdList.length - 1 - index]);
  }

  Future<void> getComic(
      {String title,
      String comicId,
      String chapterId,
      String chapterTitle}) async {
    _pageAt = chapterId;
    DownloadProvider downloadProvider = DownloadProvider();
    var localData = await downloadProvider.getChapter(chapterId);
    if (localData != null) {
      logger.i(
          'action: loadLocalData, chapter: $chapterId, tasks: ${localData.tasks}');
      _type = 1;
      _title = localData.title;
      List<String> paths = await localData.paths;
      logger.i('action: loadLocalPath, paths: $paths');
      _pages = paths;
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
      await getViewPoint();
      notifyListeners();
      return;
    }
    if (options.webApi) {
      await getComicWeb(comicId, chapterId);
      return;
    }
    CustomHttp http = CustomHttp();
    try {
      var response = await http.getComic(comicId, chapterId);
      if (response.statusCode == 200) {
        _pageAt = chapterId;
        _pages =
            response.data['page_url'].map<String>((e) => e.toString()).toList();
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
      if (options.backupApi) {
        await this.getComicBackup(comicId, chapterId);
      }
    }
    await getViewPoint();
    addReadHistory(
        comicId: comicId, page: 0, chapterTitle: title, chapterId: chapterId);
    notifyListeners();
  }

  Future<void> getComicWeb(String comicId, String chapterId) async {
    CustomHttp http = CustomHttp();
    try {
      var response = await http.getComicWeb(comicId, chapterId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.data);
        _title = data['chapter_name'];
        _pages = data['page_url'].map<String>((e) => e.toString()).toList();
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
    } catch (e) {
      logger
          .e("action:error, chapterId:$chapterId, comicId:$comicId, error:$e");
      if (options.backupApi) {
        await this.getComicBackup(comicId, chapterId);
      }
    }
    await getViewPoint();
    addReadHistory(
        comicId: comicId, page: 0, chapterTitle: title, chapterId: chapterId);
    notifyListeners();
  }

  Future<void> getComicBackup(String comicId, String chapterId) async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getComicDetailDark(comicId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.data)['data'];
        var firstLetter = data['info']['first_letter'];
        for (var item in data['list']) {
          if (item['id'] == chapterId) {
            _title = item['chapter_name'];
          }
        }
        int page = 0;
        List<String> pages = [];
        while (true) {
          try {
            var item =
                await http.getComicPage(firstLetter, comicId, chapterId, page);
            if (item.headers.value('Content-Type') == 'image/jpeg') {
              pages.add(
                  'http://imgsmall.dmzj.com/$firstLetter/$comicId/$chapterId/$page.jpg');
              page++;
            } else {
              break;
            }
          } catch (e) {
            logger.w(
                'class ComicModel, action: getComicBackupFailed, page $page');
            break;
          }
        }
        this._pages = pages;
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
        addReadHistory(
            comicId: comicId,
            page: 0,
            chapterTitle: title,
            chapterId: chapterId);
        notifyListeners();
      }
    } catch (e) {
      logger.w(
          'class: ComicModel, action: getComicBackupFailed, comicId: $comicId, chapterId: $chapterId, exception: $e');
    }
  }

  @override
  // TODO: implement comicPages
  List<String> get comicPages => _pages;

  @override
  // TODO: implement title
  String get title => this._title;

  String get pageAt => this._pageAt;

  String get comicId => _comicId;

  @override
  // TODO: implement viewpoints
  List get viewpoints => _viewPoints;

  @override
  Future<bool> next() async {
    // TODO: implement next
    if (_next != null) {
      await getComic(comicId: _comicId, chapterId: _next);
      return true;
    }
    return false;
  }

  @override
  Future<bool> previous() async {
    // TODO: implement previous
    if (_previous != null) {
      await getComic(comicId: _comicId, chapterId: _previous);
      return true;
    }
    return false;
  }

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
    DataBase dataBase = DataBase();
    await dataBase.insertHistory(comicId, chapterId);
    var login = await dataBase.getLoginState();
    //确认登录状态
    if (login) {
      //获取UID
      var uid = await dataBase.getUid();
      CustomHttp http = CustomHttp();
      http.addHistoryNew(int.parse(comicId), uid, int.parse(chapterId),
          page: page);
    }
    notifyListeners();
  }

  Future<void> getViewPoint() async {
    CustomHttp http = CustomHttp();
    try {
      var response = await http.getViewPoint(_comicId, _pageAt);
      if (response.statusCode == 200) {
        print(
            "class: ComicModel, action: getViewPoint, responseCode: ${response.statusCode} chapterId:$_chapterId comicId:$_comicId responseData: ${response.data}");
        response.data
            .sort((a, b) => int.parse(b['num'].toString()).compareTo(a['num']));
        this._viewPoints = response.data;
        print(
            "class: ComicModel, action: getViewPoint, viewpoints: $_viewPoints");
      }
    } catch (e) {
      print("action:error, chapterId:$_chapterId, comicId:$_comicId, error:$e");
    }
  }

  @override
  // TODO: implement chapters
  List get chapters => _chapters;

  int get type => _type;

  @override
  // TODO: implement canPrevious
  bool get canPrevious => _previous != null && _previous != '';

  @override
  // TODO: implement canNext
  bool get canNext => _next != null && _next != '';

  @override
  // TODO: implement chapterId
  String get chapterId => _chapterId;

  @override
  Future<void> init() async {
    // TODO: implement init
    await getComic(comicId: _comicId, chapterId: _chapterId);
  }

  @override
  // TODO: implement headers
  Map<String, String> get headers => {'referer': 'http://images.dmzj.com'};
}
