import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/comic_viewer.dart';
import 'package:provider/provider.dart';

/// 漫画详情页，记录漫画订阅记录，漫画阅读记录，漫画下载记录，和提供章节的列表
/// 预计多次迭代
class ComicDetailModel extends ChangeNotifier {
  //漫画ID
  final String comicId;

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

  ComicDetailModel(this.comicId) {
    print('class: ComicDetailModel, action: init, comicId: ${this.comicId}');
    this.getComic(this.comicId).then((value) {
      this.getHistory(comicId).then((value) => this.getIfSubscribe(comicId));
    });
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
        print(
            'class: ComicDetailModel, action: detailLoading, comicId: ${this.comicId}, title: ${this.title}, author: ${this.author}');
      }
    } catch (e) {
      //出现加载问题
      this.error = true;
      print(
          'class: ComicDetailModel, action: detailLoadingFailed, comicId: ${this.comicId}, exception: $e');
    }
    //唤醒UI
    notifyListeners();
  }

  Widget _buildButton(context, chapter, chapterIdList) {
    //创建章节UI
    // print(
    //     'chapter: ${chapter['chapter_id']}, lastChapterId: $lastChapterId, status: ${chapter['chapter_id'].toString() == Provider.of<ComicDetailModel>(context).lastChapterId}');
    return Container(
      width: 120,
      margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
      child: OutlineButton(
        child: Text(
          chapter['chapter_title'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: chapter['chapter_id'].toString() ==
                  Provider.of<ComicDetailModel>(context).lastChapterId
              ? TextStyle(color: Colors.blue)
              : null,
        ),
        onPressed: () {
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
                chapterList: chapterIdList);
          }));
        },
      ),
    );
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
          print('class: ComicDetailModel, action: AddSubscribe, status: ${this._sub}');
          notifyListeners();
        }
      });
    } else {
      http.cancelSubscribe(comicId, uid).then((response) {
        if (response.statusCode == 200 && response.data['code'] == 0) {
          this._sub = false;
          print('class: ComicDetailModel, action: CancelSubscribe, status: ${this._sub}');
          notifyListeners();
        }
      });
    }
  }

  bool get sub => this._sub;
}
