import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/database/database.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:dcomic/view/novel_pages/novel_viewer_page.dart';

class NovelDetailModel extends BaseModel {
  final int novelID;

  bool error = false;
  bool loading = true;

  String title = '加载中';
  String cover = 'http://manhua.dmzj.com/css/img/mh_logo_dmzj.png?t=20131122';
  String author = '';
  String types = '';
  int hotNum = 0;
  int subscribeNum = 0;
  String description = '加载中...';
  String updateDate = '';
  String status = '加载中';

  List chapters = [];
  List<bool> expand = [];

  //用户信息
  bool login = false;
  bool _sub = false;
  String uid = '';

  NovelDetailModel(this.novelID) {
    getNovel(novelID).then((value) {
      getChapter(novelID).then((value) => getIfSubscribe(novelID));
    });
    logger.i('class: NovelDetailModel, action: initNovel, novelID: $novelID');
  }

  Future<void> getIfSubscribe(novelID) async {
    //获取登录状态
    login=await SourceDatabaseProvider.getSourceOption<bool>('dmzj', 'login');
    //确认登录状态
    if (login) {
      //获取UID
      uid = await SourceDatabaseProvider.getSourceOption('dmzj', 'uid');
      //获取订阅信息
      CustomHttp http = CustomHttp();
      var response = await http.getIfSubscribe(novelID.toString(), uid,type: 1);
      if (response.statusCode == 200 && response.data['code'] == 0) {
        _sub = true;
      }
    }
    //解锁
    loading = false;
    logger.i(
        'class: NovelDetailModel, action: subscribeLoading, login: $login, uid: $uid, sub: $sub');
    //唤醒UI
    notifyListeners();
  }

  Future<void> getNovel(novelID) async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getNovelDetail(novelID);
      if (response.statusCode == 200) {
        title = response.data['name'];
        cover = response.data['cover'];
        author = response.data['authors'];
        types = response.data['types'][0];
        hotNum = response.data['hot_hits'];
        subscribeNum = response.data['subscribe_num'];
        description = response.data['introduction'];
        updateDate =
            ToolMethods.formatTimestamp(response.data['last_update_time']);
        status = response.data['status'];
        logger.i(
            'class: NovelDetailModel, action: getNovel, novelID: $novelID, title: $title, cover: $cover');
        notifyListeners();
      }
    } catch (e,s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'getNovelDetailFailed: $novelID');
      error = true;
      logger.e(
          'class: NovelDetailModel, action: getNovelFailed, novelID: $novelID, exception: $e');
    }
  }

  Future<void> getChapter(novelID) async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getNovelChapter(novelID);
      if (response.statusCode == 200) {
        chapters = response.data;
        expand = chapters.map<bool>((e) => false).toList();
        notifyListeners();
      }
    } catch (e) {
      logger.e(
          'class: NovelDetailModel, action: getNovelChapterFailed, novelID: $novelID, exception: $e');
    }
  }

  void setExpand(int panelIndex, bool isExpanded) {
    if (panelIndex < chapters.length) {
      expand[panelIndex] = !isExpanded;
      notifyListeners();
    }
  }

  List<ExpansionPanel> buildChapterWidget(context) {
    return chapters.map<ExpansionPanel>((e) {
      return ExpansionPanel(
          canTapOnHeader: true,
          isExpanded: expand[chapters.indexOf(e)],
          headerBuilder: (context, state) => ListTile(
                title: Text('${e['volume_name']}'),
              ),
          body: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: e['chapters'].length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${e['chapters'][index]['chapter_name']}'),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return NovelViewerPage(
                        title: e['chapters'][index]['chapter_name'],
                        chapters: chapters,
                        novelID: novelID,
                        volumeID: e['volume_id'],
                        chapterID: e['chapters'][index]['chapter_id'],
                      );
                    }));
                  },
                );
              }));
    }).toList();
  }

  bool get sub => this._sub;

  set sub(bool sub) {
    CustomHttp http = CustomHttp();
    if (sub) {
      http.addSubscribe(novelID.toString(), uid,type: 1).then((response) {
        if (response.statusCode == 200 && response.data['code'] == 0) {
          this._sub = true;
          logger.i(
              'class: NovelDetailModel, action: AddSubscribe, status: ${this._sub}');
          notifyListeners();
        }
      });
    } else {
      http.cancelSubscribe(novelID.toString(), uid,type: 1).then((response) {
        if (response.statusCode == 200 && response.data['code'] == 0) {
          this._sub = false;
          logger.i(
              'class: NovelDetailModel, action: CancelSubscribe, status: ${this._sub}');
          notifyListeners();
        }
      });
    }
  }
}
