import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/database/cookieDatabaseProvider.dart';
import 'package:dcomic/database/historyDatabaseProvider.dart';
import 'package:dcomic/model/comicCategoryModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/utils/soup.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';

class MangabzSourceModel extends BaseSourceModel {
  MangabzSourceOptions _options = MangabzSourceOptions.fromMap({});
  MangabzUserConfig _userConfig = MangabzUserConfig();

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
    } else if (comicId != null && comicId.contains('bz')) {
      return await getMangabzComic(comicId);
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
      throw ComicIdNotBoundError(comicId);
    } else if (title == null) {
      throw IDInvalidError();
    } else {
      throw ComicLoadingError();
    }
  }

  Future<MangabzComicDetail> getMangabzComic(String comicId) async {
    try {
      var response =
          await UniversalRequestModel.mangabzRequestHandler.getComic(comicId);
      if ((response.statusCode == 200||response.statusCode == 304) || response.statusCode == 304) {
        var soup = BeautifulSoup(
            ChineseHelper.convertToSimplifiedChinese(response.data.toString()));
        var title =
            soup.find(id: '.detail-info-title').text.replaceAll(' ', '');
        var authors = soup
            .find(id: '.detail-info-tip')
            .children
            .first
            .children
            .map<CategoryModel>((e) =>
                CategoryModel(title: e.text, categoryId: null, model: this))
            .toList();
        var cover = soup.find(id: '.detail-info-cover').attributes['src'];
        var description = soup.find(id: '.detail-info-content').text;
        var status =
            soup.find(id: '.detail-info-tip').children[1].children.first.text;
        var updateTime = RegExp('[0-9]{4}-[0-9]{2}-[0-9]{2}')
            .stringMatch(soup.find(id: '.detail-list-form-title').text);
        if (updateTime != null) {
          updateTime = ToolMethods.formatTimestamp(
              ToolMethods.formatTimeStringForMangabz(updateTime) ~/ 1000);
        }
        var tags = soup
            .find(id: '.detail-info-tip')
            .children[2]
            .children
            .map<CategoryModel>((e) =>
                CategoryModel(title: e.text, categoryId: null, model: this))
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
        var history = (await HistoryDatabaseProvider(this.type.name)
            .getReadHistory(comicId));
        var lastChapterId = history == null ? null : history['last_chapter_id'];
        var userId = RegExp('var MANGABZ_USERID=".+?"')
            .stringMatch(response.data)
            .replaceAll('var MANGABZ_USERID="', '')
            .replaceAll('"', '');
        return MangabzComicDetail(
            title,
            authors,
            cover,
            description,
            comicId,
            status,
            updateTime,
            tags,
            <Map<String, dynamic>>[
              {'data': chapters, 'title': 'Mangabz连载'}
            ],
            _options,
            type,
            lastChapterId,
            this,
            userId);
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
    MangabzComicDetail detail = await get(comicId: comicId, title: title);
    return await detail.getChapter(title: chapterTitle, chapterId: chapterId);
  }

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    return ChangeNotifierProvider(
      create: (_) => MangabzOptionProvider(_options),
      builder: (context, child) {
        return ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              title: Text('当前Ping(点击测试)'),
              subtitle: Text(
                  '${Provider.of<MangabzOptionProvider>(context).ping} ms'),
              onTap: () async {
                Provider.of<MangabzOptionProvider>(context, listen: false)
                        .ping =
                    await UniversalRequestModel.mangabzRequestHandler.ping();
              },
            ),
            ListTile(
              title: Text('漫画加载模式'),
              subtitle: Text(
                  '${MangabzSourceOptions.modes[Provider.of<MangabzOptionProvider>(context).mode]}'),
              onTap: () {
                Provider.of<MangabzOptionProvider>(context, listen: false)
                    .mode++;
              },
            ),
            ListTile(
              title: Text('js脚本执行网址'),
              enabled: Provider.of<MangabzOptionProvider>(context).mode != 1,
              subtitle:
                  Text('${Provider.of<MangabzOptionProvider>(context).url}'),
              onTap: () async {
                TextEditingController controller = TextEditingController();
                controller.text =
                    Provider.of<MangabzOptionProvider>(context, listen: false)
                        .url;
                var data = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'js脚本执行网址',
                              helperText: '由于使用到了js脚本为了脚本执行速度，所以请选择一个执行网址'),
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
                  Provider.of<MangabzOptionProvider>(context, listen: false)
                      .url = controller.text;
                }
              },
            )
          ],
        );
      },
    );
  }

  @override
  // TODO: implement options
  SourceOptions get options => _options;

  @override
  Future<List<SearchResult>> search(String keyword, {int page: 0}) async {
    // TODO: implement search
    try {
      var response = await UniversalRequestModel.mangabzRequestHandler
          .search(keyword, page: page);
      if ((response.statusCode == 200||response.statusCode == 304)) {
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
                  .replaceAll('/', ''),
              ChineseHelper.convertToSimplifiedChinese(item
                  .getElementsByClassName('chapter')
                  .first
                  .children[1]
                  .text)));
        }
        return data;
      }
    } catch (e) {
      throw ComicSearchError(e);
    }
    return [];
  }

  @override
  // TODO: implement type
  SourceDetail get type => SourceDetail(
      name: 'mangabz',
      title: 'Mangabz',
      description: 'Mangabz的漫画源，嘿呀，你妈的好难实现的，为了这个功能我已经快燃尽自己了',
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
    if (page > 0) {
      return [];
    }
    if (_userConfig.status == UserStatus.login) {
      try {
        var response =
            await UniversalRequestModel.mangabzRequestHandler.getSubscribe();
        if ((response.statusCode == 200||response.statusCode == 304)) {
          var soup = BeautifulSoup(
              ChineseHelper.convertToSimplifiedChinese(response.data));
          var children = soup.find(id: '.shelf-manga-list').children;
          var data = await HistoryDatabaseProvider(type.name).getAllUnread();
          var unreadList = <String, int>{};
          for (var item in data.first) {
            unreadList[item['comicId']] = item['timestamp'];
          }
          return children.map<FavoriteComic>((e) {
            String cover = e
                .children.first.children.first.children.first.attributes['src'];
            String title = e.children[1].children.first.innerHtml;
            String latestChapter = e.children[3].children.first.innerHtml;
            String comicId = e.children.first.children.first.attributes['href'];
            comicId = comicId.substring(1, comicId.length - 1);
            String updateTime =
                e.children.first.children.first.children[1].innerHtml;
            bool update = unreadList[comicId] == null ||
                unreadList[comicId] <
                    ToolMethods.formatTimeStringForMangabz(updateTime);
            return FavoriteComic(cover, title, latestChapter, comicId, this,
                update, PageType.url);
          }).toList();
        }
      } catch (e) {
        logger.e(
            'class: ${this.runtimeType}, action: loadingFavoriteError, exception: $e');
        throw e;
      }
    } else {
      throw LoginRequiredError();
    }
    return [];
  }

  @override
  // TODO: implement homePageHandler
  BaseHomePageHandler get homePageHandler => throw UnimplementedError();
}

class MangabzUserConfig extends UserConfig {
  UserStatus _status = UserStatus.logout;
  String _nickname = '未登录';

  @override
  // TODO: implement avatar
  String get avatar => null;

  MangabzUserConfig() {
    init();
  }

  Future<void> init() async {
    _status =
        await SourceDatabaseProvider.getSourceOption<bool>('mangabz', 'login', defaultValue: false)
            ? UserStatus.login
            : UserStatus.logout;
    _nickname =
        await SourceDatabaseProvider.getSourceOption('mangabz', 'nickname');
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl:
                  'http://css.mangabz.com/v202012291638/mangabz/images/logo_mangabz.png',
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '用户名',
                    icon: Icon(Icons.account_circle),
                    helperText: '邮箱'),
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
                    helperText: 'Mangabz登录密码'),
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('用户名或密码错误！'),
                            ));
                          } catch (e) {
                            EasyLoading.dismiss();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
            title: Text('Mangabz用户设置'),
            subtitle: Text('昵称：$nickname'),
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
      await UniversalRequestModel.mangabzRequestHandler
          .login(username, password);
    } on DioError catch (e) {
      if (e.response.statusCode == 302) {
        String login = '';
        for (var item in e.response.headers['set-cookie']) {
          var key = item.substring(0, item.indexOf("="));
          var value = item.substring(item.indexOf("=") + 1);
          await CookieDatabaseProvider('mangabz').insert(key, value);
          if (key == '_Mangabz_Mangamangabz') {
            login = key + '=' + value.substring(0, value.indexOf(';'));
          }
        }
        _status = UserStatus.login;
        try {
          var response = await UniversalRequestModel.mangabzRequestHandler
              .home(headers: <String, dynamic>{
            'Cookie': login,
            'User-Agent':
                'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36'
          });
          if ((response.statusCode == 200||response.statusCode == 304)) {
            var soup = BeautifulSoup(response.data);
            _nickname = soup.find(id: '.user-form').children.first.innerHtml;
          }
        } catch (e) {
          throw e;
        }
        SourceDatabaseProvider.insertSourceOption('mangabz', 'login', '1');
        SourceDatabaseProvider.insertSourceOption(
            'mangabz', 'nickname', _nickname);
        return true;
      } else {
        throw LoginUsernameOrPasswordError();
      }
    }
    return false;
  }

  @override
  Future<bool> logout() async {
    // TODO: implement logout
    SourceDatabaseProvider.insertSourceOption('mangabz', 'login', '0');
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
  String get userId => null;
}

class MangabzOptionProvider extends SourceOptionsProvider {
  final MangabzSourceOptions options;

  MangabzOptionProvider(this.options) : super(options);

  int get mode => options.mode;

  set mode(int mode) {
    options.mode = mode;
    notifyListeners();
  }

  String get url => options.url;

  set url(String url) {
    options.url = url;
    notifyListeners();
  }
}

class MangabzSourceOptions extends SourceOptions {
  bool _active = false;
  int _mode = 0;
  String _url;
  static List modes = ['evalJs', 'newImgs', 'PC API'];

  MangabzSourceOptions.fromMap(Map map) {
    _active = map['active'] == '1';
    _mode = int.parse(map['mode'] == null ? '0' : map['mode']);
    _url = map['url'];
  }

  @override
  bool get active => _active;

  set active(bool value) {
    _active = value;
    SourceDatabaseProvider.insertSourceOption(
        'mangabz', 'active', value ? '1' : '0');
    notifyListeners();
  }

  String get url => _url == null ? 'about:blank' : _url;

  set url(String value) {
    _url = value;
    SourceDatabaseProvider.insertSourceOption('mangabz', 'url', value);
    notifyListeners();
  }

  int get mode => _mode;

  set mode(int value) {
    if (0 <= value && value < modes.length) {
      _mode = value;
    } else {
      _mode = 0;
    }
    SourceDatabaseProvider.insertSourceOption('mangabz', 'mode', _mode);
    notifyListeners();
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {'active': active, 'url': url, 'mode': mode};
  }
}

class MangabzComicDetail extends ComicDetail {
  final String _title;
  final List<CategoryModel> _authors;
  final String _cover;
  final String _description;
  final String _comicId;
  final String _status;
  final String _updateTime;
  final List<CategoryModel> _tags;
  final List _chapters;
  final String _historyChapter;
  final MangabzSourceOptions options;
  final SourceDetail sourceDetail;
  final MangabzSourceModel model;
  final String userId;

  bool _isSubscribed = false;

  MangabzComicDetail(
      this._title,
      this._authors,
      this._cover,
      this._description,
      this._comicId,
      this._status,
      this._updateTime,
      this._tags,
      this._chapters,
      this.options,
      this.sourceDetail,
      this._historyChapter,
      this.model,
      this.userId);

  @override
  String toString() {
    return 'MangabzComicDetail{_title: $_title, _authors: $_authors, _cover: $_cover, _description: $_description, _comicId: $_comicId, _status: $_status, _updateTime: $_updateTime, _tags: $_tags, _chapters: $_chapters}';
  }

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
    for (var item in _chapters) {
      for (var chapter in item['data']) {
        if (chapter['chapter_id'].toString() == chapterId) {
          return MangabzComic(_comicId, chapterId, item['data'], options, this);
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
  // TODO: implement headers
  Map<String, String> get headers => {'referer': 'http://images.dmzj.com'};

  @override
  bool get isSubscribed => _isSubscribed;

  set isSubscribed(bool value) {
    _isSubscribed = value;
    UniversalRequestModel.mangabzRequestHandler.addSubscribe(comicId, userId);
    notifyListeners();
  }

  @override
  Future<void> getIfSubscribed() async {
    // TODO: implement getIfSubscribed
    try {
      var list = await model.getFavoriteComics(0);
      for (var item in list) {
        if (item.comicId == comicId) {
          _isSubscribed = true;
          return;
        }
      }
    } on LoginRequiredError catch (e) {
      logger.e('loginRequired');
    } catch (e) {
      throw e;
    }
  }

  @override
  String share() {
    // TODO: implement share
    return '【$title】http://www.mangabz.com/$comicId/';
  }

  @override
  Future<List<ComicComment>> getComments(int page) {
    // TODO: implement getComments
    throw UnimplementedError();
  }
}

class MangabzSearchResult extends SearchResult {
  final String _cover;
  final String _title;
  final String _comicId;
  final String _latestChapter;

  MangabzSearchResult(
      this._cover, this._title, this._comicId, this._latestChapter);

  @override
  // TODO: implement author
  String get author => '暂无数据';

  @override
  // TODO: implement comicId
  String get comicId => _comicId;

  @override
  // TODO: implement cover
  String get cover => _cover;

  @override
  // TODO: implement tag
  String get tag => '暂无数据';

  @override
  // TODO: implement title
  String get title => _title;

  @override
  // TODO: implement latestChapter
  String get latestChapter => _latestChapter;
}

class MangabzComic extends Comic {
  final String _comicId;
  final String _chapterId;
  final List _chapters;
  final MangabzSourceOptions options;
  final MangabzComicDetail _detail;
  List<String> _pages = [];
  String _title;
  List<String> _chapterIdList;
  List _viewPoints = [];

  String _previous;
  String _next;
  String _pageAt;

  MangabzComic(this._comicId, this._chapterId, this._chapters, this.options,
      this._detail) {
    _chapterIdList = _chapters
        .map<String>((value) => value['chapter_id'].toString())
        .toList();
    _chapterIdList = List.generate(_chapterIdList.length,
        (index) => _chapterIdList[_chapterIdList.length - 1 - index]);
  }

  @override
  Future<void> addReadHistory() async {
    // TODO: implement addReadHistory
    HistoryDatabaseProvider('mangabz').addReadHistory(
        comicId,
        _detail.title,
        _detail.cover,
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
      var response = await UniversalRequestModel.mangabzRequestHandler
          .getChapter(chapterId);
      if ((response.statusCode == 200||response.statusCode == 304)) {
        this._title = RegExp('<p class="top-title">.*</p>?')
            .stringMatch(ChineseHelper.convertToSimplifiedChinese(
                response.data.toString()))
            .replaceAll(' ', '')
            .replaceAll("</p>", '')
            .split('?')[2];
        _pageAt = chapterId;
        switch (options.mode) {
          case 0:
            var eval =
                RegExp('eval(.*);?').stringMatch(response.data.toString());
            this._pages = jsonDecode(await ToolMethods.eval('$eval;newImgs',
                    url: '${options.url}'))
                .map<String>((e) => e.toString())
                .toList();
            break;
          case 1:
            this._pages = jsonDecode(await ToolMethods.eval('newImgs',
                    url:
                        '${UniversalRequestModel.mangabzRequestHandler.baseUrl}/$chapterId'))
                .map<String>((e) => e.toString())
                .toList();
            break;
          case 2:
            var length = RegExp('(?<=var MANGABZ_IMAGE_COUNT=)[^;]*;')
                .stringMatch(response.data.toString());
            length = length.substring(0, length.length - 1);
            int page = 0;
            var codes = <String>[];
            while (page < int.parse(length)) {
              try {
                var data = await UniversalRequestModel.mangabzRequestHandler
                    .getChapterImage(chapterId, page);
                if (data.statusCode == 200) {
                  codes.add(data.data.toString());
                }
              } catch (e) {}
              page++;
            }
            List<String> pages = [];
            List<String> result =
                await ToolMethods.evalList(codes, url: options.url);
            for (var item in result) {
              pages +=
                  jsonDecode(item).map<String>((e) => e.toString()).toList();
            }
            _pages = pages.toSet().toList();
            break;
        }
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
      throw ComicLoadingError(exception: e);
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
  PageType get type => PageType.url;

  @override
  // TODO: implement viewpoints
  List get viewpoints => _viewPoints;

  @override
  // TODO: implement headers
  Map<String, String> get headers => {'referer': 'http://www.mangabz.com/'};
}
