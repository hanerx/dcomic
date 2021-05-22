import 'package:dcomic/database/sourceDatabaseProvider.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/protobuf/novel_chapter.pb.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  List<NovelChapterVolumeResponse> chapters = [];
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
    login = await SourceDatabaseProvider.getSourceOption<bool>('dmzj', 'login');
    //确认登录状态
    if (login) {
      //获取UID
      uid = await SourceDatabaseProvider.getSourceOption('dmzj', 'uid');
      //获取订阅信息
      var response = await UniversalRequestModel.dmzjRequestHandler
          .getIfSubscribe(novelID.toString(), uid, type: 1);
      if ((response.statusCode == 200||response.statusCode == 304) && response.data['code'] == 0) {
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
      var response = await UniversalRequestModel.dmzjv4requestHandler
          .getNovelDetail(novelID.toString());
      if (response != null) {
        title = response.name;
        cover = response.cover;
        author = response.authors;
        types = response.types.join('/');
        hotNum = response.hotHits;
        subscribeNum = response.subscribeNum;
        description = response.introduction;
        updateDate =
            ToolMethods.formatTimestamp(response.lastUpdateTime.toInt());
        status = response.status;
        logger.i(
            'class: NovelDetailModel, action: getNovel, novelID: $novelID, title: $title, cover: $cover');
        notifyListeners();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'getNovelDetailFailed: $novelID');
      error = true;
      logger.e(
          'class: NovelDetailModel, action: getNovelFailed, novelID: $novelID, exception: $e');
    }
  }

  Future<void> getChapter(novelID) async {
    try {
      var response = await UniversalRequestModel.dmzjv4requestHandler
          .getNovelChapters(novelID.toString());
      if (response != null) {
        chapters = response;
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
                title: Text('${e.volumeName}'),
              ),
          body: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: e.chapters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${e.chapters[index].chapterName}'),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return NovelViewerPage(
                        title: e.chapters[index].chapterName,
                        chapters: chapters,
                        novelID: novelID,
                        volumeID: e.volumeId,
                        chapterID: e.chapters[index].chapterId,
                      );
                    }));
                  },
                );
              }));
    }).toList();
  }

  bool get sub => this._sub;

  set sub(bool sub) {
    if (sub) {
      UniversalRequestModel.dmzjRequestHandler.addSubscribe(novelID.toString(), uid, type: 1).then((response) {
        if ((response.statusCode == 200||response.statusCode == 304) && response.data['code'] == 0) {
          this._sub = true;
          logger.i(
              'class: NovelDetailModel, action: AddSubscribe, status: ${this._sub}');
          notifyListeners();
        }
      });
    } else {
      UniversalRequestModel.dmzjRequestHandler.cancelSubscribe(novelID.toString(), uid, type: 1).then((response) {
        if ((response.statusCode == 200||response.statusCode == 304) && response.data['code'] == 0) {
          this._sub = false;
          logger.i(
              'class: NovelDetailModel, action: CancelSubscribe, status: ${this._sub}');
          notifyListeners();
        }
      });
    }
  }
}
