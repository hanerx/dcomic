import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/sourceDatabaseProvider.dart';
import 'package:flutterdmzj/http/KuKuRequestHandler.dart';
import 'package:flutterdmzj/http/UniversalRequestModel.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';
import 'package:flutterdmzj/utils/soup.dart';
import 'package:provider/provider.dart';
import 'package:html/dom.dart' as DomElement show Element;

class KuKuSourceModel extends BaseSourceModel {
  KuKuSourceOptions _options = KuKuSourceOptions.fromMap({});

  KuKuSourceModel() {
    init();
  }

  init() async {
    var map = await SourceDatabaseProvider.getSourceOptions(type.name);
    _options = KuKuSourceOptions.fromMap(map);
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
      return await getKuKuComic(map['bound_id']);
    } else if (title != null) {
      var list = await search(title);
      for (var item in list) {
        if (item.title == title) {
          if (comicId != null) {
            SourceDatabaseProvider.boundComic(type.name, comicId, item.comicId);
          }
          return await getKuKuComic(item.comicId);
        }
      }
      throw ComicIdNotBoundError();
    } else if (title == null) {
      throw IDInvalidError();
    } else {
      throw ComicLoadingError(exception: Exception('未知的判断问题'));
    }
  }

  Future<KuKuComicDetail> getKuKuComic(String comicId) async {
    try {
      Response response;
      switch (_options.server) {
        case 1:
          response = await UniversalRequestModel()
              .kkkkRequestHandler1
              .getComic(comicId);
          break;
        case 2:
          response = await UniversalRequestModel()
              .kkkkRequestHandler2
              .getComic(comicId);
          break;
        case 3:
          response = await UniversalRequestModel()
              .kkkkRequestHandler3
              .getComic(comicId);
          break;
        default:
          response = await UniversalRequestModel()
              .kuKuRequestHandler
              .getComic(comicId);
      }
      if (response.statusCode == 200) {
        var soup = BeautifulSoup(response.data);
        DomElement.Element table;
        for (var item in soup.findAll('table')) {
          if (item.attributes['width'] == '100%' &&
              item.attributes['border'] == '0' &&
              item.attributes['cellspacing'] == '0' &&
              item.attributes['cellpadding'] == '7') {
            table = item.children.first;
            break;
          }
        }
        var title = table.children.first.children.first.text;
        var cover =
            table.children[1].children.first.children.first.attributes['src'];
        var description = table.children[2].children.first.children[1].text;
        var text = table.children[4].children.first.text;
        List authors = text
            .split('|')
            .first
            .split('：')[1]
            .split(',')
            .map<Map<String, dynamic>>((e) => {'tag_name': e, 'tag_id': null})
            .toList();
        String status = text.split('|')[1].split('：')[1];
        String updateTime = text.split('|')[2].split('：')[1];
        List chapters = soup
            .find(id: '#comiclistn')
            .children
            .map<Map<String, dynamic>>((e) => {
                  'chapter_id':
                      e.children.first.attributes['href'].split('/')[3],
                  'chapter_title': e.children.first.text.replaceAll(title, ''),
                  'updatetime': 0
                })
            .toList();
        chapters = List.generate(
            chapters.length, (index) => chapters[chapters.length - 1 - index]);
        return KuKuComicDetail(
            authors,
            comicId,
            cover,
            description,
            <Map<String, dynamic>>[
              {'title': 'KuKu连载', 'data': chapters}
            ],
            status,
            title,
            updateTime,
            options);
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
      create: (_) => KuKuOptionsProvider(_options),
      builder: (context, child) {
        return ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              title: Text('当前加载域名'),
              subtitle: Text(
                  '${KuKuSourceOptions.servers[Provider.of<KuKuOptionsProvider>(context).server]}'),
              onTap: () {
                Provider.of<KuKuOptionsProvider>(context, listen: false)
                    .server++;
              },
            ),
            ListTile(
              title: Text('当前Ping(点击测试)'),
              subtitle: Text('${Provider.of<KuKuOptionsProvider>(context).ping} ms'),
              onTap: ()async{
                int ping=-1;
                switch(Provider.of<KuKuOptionsProvider>(context,listen: false).server){
                  case 1:
                    ping=await UniversalRequestModel().kkkkRequestHandler1.ping();
                    break;
                  case 2:
                    ping=await UniversalRequestModel().kkkkRequestHandler2.ping();
                    break;
                  case 3:
                    ping=await UniversalRequestModel().kkkkRequestHandler3.ping();
                    break;
                  default:
                    ping=await UniversalRequestModel().kuKuRequestHandler.ping();
                }
                Provider.of<KuKuOptionsProvider>(context,listen: false).ping=ping;
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
  Future<List<SearchResult>> search(String keyword, {int page = 0}) async {
    // TODO: implement search
    try {
      var response =
          await UniversalRequestModel().soKuKuRequestHandler.search(keyword);
      if (response.statusCode == 200) {
        var soup = BeautifulSoup(response.data);
        List<KuKuSearchResult> data = [];
        for (var item in soup.find(id: '#comicmain').children) {
          String comicId = RegExp('[0-9]+')
              .stringMatch(item.children.first.attributes['href']);
          String cover = item.children.first.children.first.attributes['src'];
          String title = item.children[1].text
              .substring(0, item.children[1].text.length - 4);
          data.add(KuKuSearchResult(comicId, cover, title));
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
  SourceDetail get type => SourceDetail(
      'kuku', 'KuKu动漫', 'KuKu动漫源，存在四个节点，请根据延迟自行选择。由于采用多线程脚本，可能会导致你被服务器ban掉，所以请轻拿轻放。', true, SourceType.LocalDecoderSource, false);
}

class KuKuOptionsProvider extends SourceOptionsProvider {
  KuKuSourceOptions options;


  KuKuOptionsProvider(this.options) : super(options);

  int get server => options.server;

  set server(int value) {
    options.server = value;
    notifyListeners();
  }


}

class KuKuSourceOptions extends SourceOptions {
  bool _active = false;
  int _server = 0;

  static List<String> servers = [
    'https://manhua.kukudm.com/',
    'http://comic.kkkkdm.com/',
    'http://comic2.kkkkdm.com/',
    'http://comic3.kkkkdm.com/'
  ];

  KuKuSourceOptions.fromMap(Map map) {
    _active = map['active'] == '1';
    _server = map['server'] == null ? 0 : int.parse(map['server']);
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {
      'active': active,
    };
  }

  bool get active => _active;

  set active(bool value) {
    _active = value;
    SourceDatabaseProvider.insertSourceOption(
        'kuku', 'active', value ? '1' : '0');
    notifyListeners();
  }

  int get server => _server;

  set server(int value) {
    if (value >= 0 && value < servers.length) {
      _server = value;
      SourceDatabaseProvider.insertSourceOption('kuku', 'server', value);
    } else {
      _server = 0;
      SourceDatabaseProvider.insertSourceOption('kuku', 'server', 0);
    }
    notifyListeners();
  }
}

class KuKuSearchResult extends SearchResult {
  final String _comicId;
  final String _cover;
  final String _title;

  KuKuSearchResult(this._comicId, this._cover, this._title);

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

class KuKuComicDetail extends ComicDetail {
  final List _authors;
  final String _comicId;
  final String _cover;
  final String _description;
  final List _chapters;
  final String _status;
  final String _title;
  final String _updateTime;
  final KuKuSourceOptions options;

  KuKuComicDetail(
      this._authors,
      this._comicId,
      this._cover,
      this._description,
      this._chapters,
      this._status,
      this._title,
      this._updateTime,
      this.options);

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
          return KuKuComic(_comicId, chapterId, item['data'], options);
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
  Map<String, String> get headers =>
      {'referer': KuKuSourceOptions.servers[options.server]};

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
  List get tags => [];

  @override
  // TODO: implement title
  String get title => _title;

  @override
  // TODO: implement updateTime
  String get updateTime => _updateTime;
}

class KuKuComic extends Comic {
  final String _comicId;
  final String _chapterId;
  final List _chapters;
  final KuKuSourceOptions options;
  List<String> _pages = [];
  String _title;
  List<String> _chapterIdList;
  int _type = 0;

  String _previous;
  String _next;
  String _pageAt;

  KuKuComic(this._comicId, this._chapterId, this._chapters, this.options) {
    _chapterIdList = _chapters
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
      String chapterId}) async {
    // TODO: implement addReadHistory
    return;
  }

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
      KKKKRequestHandler handler = UniversalRequestModel().kuKuRequestHandler;
      switch (options.server) {
        case 1:
          handler = UniversalRequestModel().kkkkRequestHandler1;
          break;
        case 2:
          handler = UniversalRequestModel().kkkkRequestHandler2;
          break;
        case 3:
          handler = UniversalRequestModel().kkkkRequestHandler3;
          break;
      }
      var response = await handler.getChapter(comicId, chapterId, 1);
      if (response['data'].statusCode == 200) {
        Map<String, String> hosts = await handler.getImageHosts();
        int page = 2;
        int length;

        _pageAt = chapterId;
        _title = chapters[chapters.length - 1 - _chapterIdList.indexOf(_pageAt)]
            ['chapter_title'];
        var temp = RegExp('共[0-9]+页').stringMatch(response['data'].data);
        length = int.parse(temp.substring(1, temp.length - 1));
        List<String> pages = List<String>.generate(length, (index) => '');
        var image =
            RegExp('''<IMG SRC='.*?'>''').stringMatch(response['data'].data);
        image = image.substring(10, image.length - 2);
        for (var key in hosts.keys) {
          image = image
              .replaceAll('$key', hosts[key])
              .replaceAll('"', '')
              .replaceAll('+', '')
              .replaceAll(' ', '');
        }
        pages[0]=image;
        while (page <= length) {
          // var item = await handler.getChapter(comicId, chapterId, page);
          // if (item.statusCode == 200) {
          //   var image = RegExp('''<IMG SRC='.*?'>''').stringMatch(item.data);
          //   image = image.substring(10, image.length - 2);
          //   for (var key in hosts.keys) {
          //     image = image
          //         .replaceAll('$key', hosts[key])
          //         .replaceAll('"', '')
          //         .replaceAll('+', '')
          //         .replaceAll(' ', '');
          //   }
          //   pages.add(image);
          //   page++;
          // }
          handler.getChapter(comicId, chapterId, page).then((item) {
            if (item['data'].statusCode == 200) {
              var image =
                  RegExp('''<IMG SRC='.*?'>''').stringMatch(item['data'].data);
              image = image.substring(10, image.length - 2);
              for (var key in hosts.keys) {
                image = image
                    .replaceAll('$key', hosts[key])
                    .replaceAll('"', '')
                    .replaceAll('+', '')
                    .replaceAll(' ', '');
              }
              pages[item['page'] - 1] = image;
              notifyListeners();
            }
          });
          page++;
        }
        while (pages.contains('')) {
          await Future.delayed(Duration(seconds: 1));
        }
        _pages = pages;
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
  // TODO: implement headers
  Map<String, String> get headers =>
      {'referer': KuKuSourceOptions.servers[options.server]};

  @override
  Future<void> init() async {
    // TODO: implement init
    await getComic(comicId: _comicId, chapterId: _chapterId);
  }

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
  // TODO: implement pageAt
  String get pageAt => _pageAt;

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
  // TODO: implement title
  String get title => _title;

  @override
  // TODO: implement type
  int get type => _type;

  @override
  // TODO: implement viewpoints
  List get viewpoints => [];
}
