import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/database/downloader.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/comic_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

/// 漫画详情页，记录漫画订阅记录，漫画阅读记录，漫画下载记录，和提供章节的列表
/// 预计多次迭代
class ComicDetailModel extends BaseModel {
  //漫画ID
  final String comicId;
  final bool backupApi;

  //漫画加载状态
  bool error = false;
  bool loading = true;

  //基础信息
  String title = '加载中';
  String cover = 'http://manhua.dmzj.com/css/img/mh_logo_dmzj.png?t=20131122';
  List author = [];
  List types = [];
  int hotNum = 0;
  int subscribeNum = 0;
  String description = '加载中...';
  String updateDate = '';
  String status = '加载中';

  //章节信息
  List chapters = [];
  bool _reverse = false;

  //最后浏览记录
  String lastChapterId = '';
  List lastChapterList = [];

  //用户信息
  bool login = false;
  bool _sub = false;
  String uid = '';

  ComicDetailModel(this.comicId, this.backupApi) {
    print('class: ComicDetailModel, action: init, comicId: ${this.comicId}');
    this.getComic(this.comicId).then((value) {
      this.getHistory(comicId).then((value) => this
          .getIfSubscribe(comicId)
          .then((value) => this.addReadHistory(comicId)));
    });
  }

  Future<void> addReadHistory(comicId) async {
    // 添加历史记录
    DataBase dataBase = DataBase();
    bool loginState = await dataBase.getLoginState();
    if (loginState) {
      var uid = await dataBase.getUid();
      CustomHttp http = CustomHttp();
      http.addReadHistory(comicId, uid);
      http.addReadHistory0(comicId, uid);
      http.addReadHistory1(comicId);
      http.setUpRead(comicId);
      dataBase.insertUnread(comicId, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> getHistory(comicId) async {
    //获取本地最后阅读记录
    DataBase dataBase = DataBase();
    lastChapterId = await dataBase.getHistory(comicId);

    //对没有记录的本地信息提供默认值
    if (lastChapterId == '' && chapters.length > 0) {
      lastChapterList = chapters[0]['data']
          .map((value) => value['chapter_id'].toString())
          .toList();
      if (lastChapterList.length > 0) {
        lastChapterId = lastChapterList[lastChapterList.length - 1];
      }
    }

    //查找本地记录对应的板块
    chapters.forEach((element) {
      List chapterList = element['data']
          .map((value) => value['chapter_id'].toString())
          .toList();
      if (chapterList.indexOf(lastChapterId) >= 0) {
        lastChapterList = chapterList;
      }
    });

    //反向list
    lastChapterList = List.generate(lastChapterList.length,
        (index) => lastChapterList[lastChapterList.length - 1 - index]);

    print(
        'class: ComicDetailModel, action: historyLoading, comicId: $comicId, lastChapterId: $lastChapterId, lastChapterList: $lastChapterList');
    notifyListeners();
  }

  Future<void> getIfSubscribe(comicId) async {
    //获取登录状态
    DataBase dataBase = DataBase();
    login = await dataBase.getLoginState();
    //确认登录状态
    if (login) {
      //获取UID
      uid = await dataBase.getUid();
      //获取订阅信息
      CustomHttp http = CustomHttp();
      var response = await http.getIfSubscribe(comicId, uid);
      if (response.statusCode == 200 && response.data['code'] == 0) {
        _sub = true;
      }
    }
    //解锁
    loading = false;
    print(
        'class: ComicDetailModel, action: subscribeLoading, login: $login, uid: $uid, sub: $sub');
    //唤醒UI
    notifyListeners();
  }

  Future<void> getComic(comicId) async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getComicDetail(comicId);
      if (response.statusCode == 200) {
        //获取基础信息
        title = response.data['title'];
        cover = response.data['cover'];
        author = response.data['authors'];
        types = response.data['types'];
        hotNum = response.data['hot_num'];
        subscribeNum = response.data['subscribe_num'];
        description = response.data['description'];
        updateDate =
            ToolMethods.formatTimestamp(response.data['last_updatetime']);
        //状态信息需要采取特殊处理
        status = response.data['status']
            .map((value) => value['tag_name'])
            .toList()
            .join('/');
        chapters = response.data['chapters'];
        if(chapters.length==0){
          throw Exception('no chapters');
        }
        print(
            'class: ComicDetailModel, action: detailLoading, comicId: ${this.comicId}, title: ${this.title}, author: ${this.author}');
      }
    } catch (e) {
      //出现加载问题
      this.error = true;
      description = '错误代码: $e';
      title = '加载出错';
      status = '加载失败';
      print(
          'class: ComicDetailModel, action: detailLoadingFailed, comicId: ${this.comicId}, exception: $e');
      if (backupApi) {
        await getComicDetailBackup(comicId);
      }
    }
    //唤醒UI
    notifyListeners();
  }

  Future<void> getComicDetailBackup(String comicId) async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getComicDetailDark(comicId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.data)['data'];
        title = data['info']['title'];
        cover = data['info']['cover'];
        author = [
          {'tag_name': data['info']['authors'], 'tag_id': null}
        ];
        types = [
          {'tag_name': data['info']['types'], 'tag_id': null}
        ];
        description = data['info']['description'];
        updateDate = ToolMethods.formatTimestamp(
            int.parse(data['info']['last_updatetime']));
        //状态信息需要采取特殊处理
        status = data['info']['status'];
        chapters = [
          {
            'data': data['list']
                .map((e) =>
                    {'chapter_id': e['id'], 'chapter_title': e['chapter_name']})
                .toList(),
            'title': '备用API'
          }
        ];
      }
    } catch (e) {
      logger.w(
          'class: ComicDetailModel, action: detailBackupLoadingFailed, comicId: ${this.comicId}, exception: $e');
    }
  }

  Widget _buildBasicButton(context, String title, style, VoidCallback onPress,
      {double width: 120}) {
    return Container(
      width: width,
      margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
      child: OutlineButton(
        child: Text(
          '$title',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
        onPressed: onPress,
      ),
    );
  }

  Widget _buildButton(context, chapter, chapterIdList) {
    //创建章节UI
    // print(
    //     'chapter: ${chapter['chapter_id']}, lastChapterId: $lastChapterId, status: ${chapter['chapter_id'].toString() == Provider.of<ComicDetailModel>(context).lastChapterId}');
    return _buildBasicButton(
        context,
        chapter['chapter_title'],
        chapter['chapter_id'].toString() ==
                Provider.of<ComicDetailModel>(context).lastChapterId
            ? TextStyle(color: Colors.blue)
            : null, () {
      DataBase dataBase = DataBase();
      dataBase.addReadHistory(
          comicId,
          title,
          cover,
          chapter['chapter_title'],
          chapter['chapter_id'].toString(),
          DateTime.now().millisecondsSinceEpoch ~/ 1000);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ComicViewPage(
          comicId: comicId,
          chapterId: chapter['chapter_id'].toString(),
          chapterList: chapterIdList
        );
      }));
    });
  }

  Future<List<dynamic>> downloadChapter(comicId, chapterId) async {
    DownloadProvider downloadProvider = DownloadProvider();
    if (await downloadProvider.getChapter(chapterId) != null) {
      return null;
    }
    var state = await Permission.storage.request().isGranted;
    if (state) {
      CustomHttp http = CustomHttp();
      var response = await http.getComic(comicId, chapterId);
      DataBase dataBase = DataBase();
      var path = await dataBase.getDownloadPath();

      List data = <String>[];
      if (response.statusCode == 200) {
        var directory = Directory('$path/chapters/$comicId/$chapterId');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        for (var item in response.data['page_url']) {
          String taskId = await FlutterDownloader.enqueue(
            headers: {'referer': 'http://images.dmzj.com'},
            url: item,
            savedDir: '$path/chapters/$comicId/$chapterId',
            showNotification: false,
            // show download progress in status bar (for Android)
            openFileFromNotification:
                false, // click on notification to open downloaded file (for Android)
          );
          data.add(taskId);
        }
      }
      if (await downloadProvider.getComic(comicId) == null) {
        Comic comic = Comic();
        comic.title = title;
        comic.cover = cover;
        comic.comicId = comicId;
        await downloadProvider.insertComic(comic);
      }
      Chapter chapter = Chapter();
      chapter.comicId = comicId;
      chapter.tasks = data;
      chapter.chapterId = chapterId;
      chapter.title = response.data['title'];
      await downloadProvider.insertChapter(chapter);
      notifyListeners();
      return data;
    }
    return null;
  }

  Future<Widget> _buildDownloadButton(context, chapter) async {
    DownloadProvider downloadProvider = DownloadProvider();
    if (await downloadProvider.getChapter(chapter['chapter_id'].toString()) !=
        null) {
      return _buildBasicButton(context, chapter['chapter_title'], null, null,
          width: 80);
    }
    return _buildBasicButton(context, chapter['chapter_title'], null, () async {
      List list =
          await downloadChapter(comicId, chapter['chapter_id'].toString());
      logger.i(
          'action: downloadChapter, chapterId: ${chapter['chapter_id']}, tasks: $list');
    }, width: 80);
  }

  List<Widget> buildChapterWidgetList(context) {
    List<Widget> lists = [];
    for (var item in this.chapters) {
      // 生成每版的章节ID列表
      List<String> chapterIdList = item['data']
          .map<String>((value) => value['chapter_id'].toString())
          .toList();
      chapterIdList = List.generate(chapterIdList.length,
          (index) => chapterIdList[chapterIdList.length - 1 - index]);

      // 生成每版的章节列表
      List<Widget> chapterList = item['data']
          .map<Widget>((value) => _buildButton(context, value, chapterIdList))
          .toList();
      // 反向排序
      if (_reverse) {
        var tempList = List.generate(chapterList.length,
            (index) => chapterList[chapterList.length - 1 - index]);
        chapterList = tempList;
      }

      //添加每版
      lists.add(Column(
        children: <Widget>[
          Divider(),
          Text(item['title']),
          Divider(),
          Wrap(
            children: chapterList,
          )
        ],
      ));
    }
    return lists;
  }

  Future<List<Widget>> buildDownloadWidgetList(context) async {
    List<Widget> lists = [];
    for (var item in this.chapters) {
      // 生成每版的章节列表
      List<Widget> chapterList = [];
      for (var value in item['data']) {
        chapterList.add(await _buildDownloadButton(context, value));
      }
      // 反向排序
      if (_reverse) {
        var tempList = List.generate(chapterList.length,
            (index) => chapterList[chapterList.length - 1 - index]);
        chapterList = tempList;
      }

      //添加每版
      lists.add(Column(
        children: <Widget>[
          Divider(),
          Text(item['title']),
          Divider(),
          Wrap(
            children: chapterList,
          )
        ],
      ));
    }
    return lists;
  }

  set reverse(bool reverse) {
    this._reverse = reverse;
    notifyListeners();
  }

  bool get reverse => this._reverse;

  set sub(bool sub) {
    CustomHttp http = CustomHttp();
    if (sub) {
      http.addSubscribe(comicId, uid).then((response) {
        if (response.statusCode == 200 && response.data['code'] == 0) {
          this._sub = true;
          print(
              'class: ComicDetailModel, action: AddSubscribe, status: ${this._sub}');
          notifyListeners();
        }
      });
    } else {
      http.cancelSubscribe(comicId, uid).then((response) {
        if (response.statusCode == 200 && response.data['code'] == 0) {
          this._sub = false;
          print(
              'class: ComicDetailModel, action: CancelSubscribe, status: ${this._sub}');
          notifyListeners();
        }
      });
    }
  }

  bool get sub => this._sub;
}
