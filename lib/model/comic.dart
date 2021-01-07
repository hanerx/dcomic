import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/component/ViewPointChip.dart';
import 'package:flutterdmzj/component/comic_viewer/ComicPage.dart';
import 'package:flutterdmzj/component/comic_viewer/VerticalPageView.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/database/downloader.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/utils/log_output.dart';
import 'package:logger/logger.dart';
import 'package:markdown_widget/markdown_helper.dart';
import 'package:markdown_widget/markdown_widget.dart';

class ComicModel extends BaseModel {
  final String comicId;
  final String chapterId;
  final List chapterList;
  final bool backupApi;

  String pageAt;
  String next;
  String previous;

  String title;

  bool refreshState = true;

  List<Widget> pages = [];
  List<Widget> viewPoints = [];

  int _index=0;

  //用户信息
  bool login = false;
  String uid = '';

  ComicModel(this.comicId, this.chapterId, this.chapterList, this.backupApi) {
    getComic(chapterId, comicId).then((value) {
      logger.i(
          "action: init, chapterId: $chapterId, comicId: $comicId, chapterList: ${this.chapterList}, previous: $previous, next: $next, left: $left, right: $right, index: ${chapterList.indexOf(chapterId)}");
    });
  }

  Future<void> getComic(String chapterId, String comicId) async {
    if (chapterId == null || pageAt == chapterId) {
      refreshState = false;
      return;
    }
    logger.i(
        "action: getComic, chapter: $chapterId comicId:$comicId refreshState:$refreshState");
    pageAt = chapterId;
    DownloadProvider downloadProvider = DownloadProvider();
    var localData = await downloadProvider.getChapter(chapterId);
    if (localData != null) {
      logger.i(
          'action: loadLocalData, chapter: $chapterId, tasks: ${localData.tasks}');
      title = localData.title;
      List<Widget> pages = [];
      List<String> paths = await localData.paths;
      logger.i('action: loadLocalPath, paths: $paths');
      for (var item in paths) {
        pages.add(ComicPage(
          url: item,
          title: localData.title,
          chapterId: localData.chapterId,
          cover: false,
          local: true,
        ));
      }
      this.pages = pages;
      if (chapterList.indexOf(chapterId) > 0) {
        previous = chapterList[chapterList.indexOf(chapterId) - 1];
      } else {
        previous = null;
      }
      if (chapterList.indexOf(chapterId) < chapterList.length - 1) {
        next = chapterList[chapterList.indexOf(chapterId) + 1];
      } else {
        next = null;
      }
      await getViewPoint(chapterId, comicId);
      setReadHistory(chapterId, comicId);
      refreshState = false;
      notifyListeners();
      return;
    }
    CustomHttp http = CustomHttp();
    try {
      var response = await http.getComic(comicId, chapterId);
      logger.i(
          "action: response, responseCode: ${response.statusCode} chapterId:$chapterId comicId:$comicId responseData:${response.data}");
      if (response.statusCode == 200) {
        title = response.data['title'];
        List<Widget> pages = [];
        for (var item in response.data['page_url']) {
          pages.add(ComicPage(
            url: item,
            title: response.data['title'],
            chapterId: response.data['chapter_id'].toString(),
            cover: false,
          ));
        }
        this.pages = pages;
        if (chapterList.indexOf(chapterId) > 0) {
          previous = chapterList[chapterList.indexOf(chapterId) - 1];
        } else {
          previous = null;
        }
        if (chapterList.indexOf(chapterId) < chapterList.length - 1) {
          next = chapterList[chapterList.indexOf(chapterId) + 1];
        } else {
          next = null;
        }
      }
    } catch (e) {
      logger
          .e("action:error, chapterId:$chapterId, comicId:$comicId, error:$e");
      if(backupApi){
        await this.getComicBackup(comicId, chapterId);
      }
    }
    await getViewPoint(chapterId, comicId);
    setReadHistory(chapterId, comicId);
    refreshState = false;
    notifyListeners();
  }

  Future<void> getComicBackup(String comicId, String chapterId) async{
    try{
      CustomHttp http=CustomHttp();
      var response=await http.getComicDetailDark(comicId);
      if(response.statusCode==200){
        var data=jsonDecode(response.data)['data'];
        var firstLetter=data['info']['first_letter'];
        for(var item in data['list']){
          if(item['id']==chapterId){
            title=item['chapter_name'];
          }
        }
        int page=0;
        List<Widget> pages=[];
        while(true){
          try{
            var item=await http.getComicPage(firstLetter, comicId, chapterId, page);
            if(item.headers.value('Content-Type')=='image/jpeg'){
              pages.add(ComicPage(
                url: 'http://imgsmall.dmzj.com/$firstLetter/$comicId/$chapterId/$page.jpg',
                title: title,
                chapterId: chapterId,
                cover: false,
              ));
              page++;
            }else{
              break;
            }
          }catch(e){
            logger.w('class ComicModel, action: getComicBackupFailed, page $page');
            break;
          }
          
        }
        this.pages=pages;
        notifyListeners();
      }
    }catch(e){
      logger.w('class: ComicModel, action: getComicBackupFailed, comicId: $comicId, chapterId: $chapterId, exception: $e');
    }

  }

  Future<void> setReadHistory(String chapterId, String comicId) async {
    DataBase dataBase = DataBase();
    await dataBase.insertHistory(comicId, chapterId);
    login = await dataBase.getLoginState();
    //确认登录状态
    if (login) {
      //获取UID
      uid = await dataBase.getUid();
      CustomHttp http=CustomHttp();
      http.addHistoryNew(int.parse(comicId), uid, int.parse(chapterId),page: index);
    }
    //解锁
    logger.i(
        'class: ComicModel, action: addReadHistory, login: $login, uid: $uid');
    //唤醒UI
    notifyListeners();
  }

  Future<void> getViewPoint(String chapterId, String comicId) async {
    CustomHttp http = CustomHttp();
    try {
      var response = await http.getViewPoint(comicId, chapterId);
      if (response.statusCode == 200) {
        print(
            "class: ComicModel, action: getViewPoint, responseCode: ${response.statusCode} chapterId:$chapterId comicId:$comicId responseData: ${response.data}");
        List<ViewPointChip> viewPoints = [];
        for (var item in response.data) {
          viewPoints.add(ViewPointChip(
            content: item['content'],
            num: item['num'],
            id: item['id'].toString(),
          ));
        }
        viewPoints.sort((a, b) => b.num.compareTo(a.num));
        this.viewPoints = viewPoints;
        print(
            "class: ComicModel, action: getViewPoint, viewpoints: $viewPoints");
      }
    } catch (e) {
      print("action:error, chapterId:$chapterId, comicId:$comicId, error:$e");
    }
  }

  Future<bool> nextChapter() async {
    if (!refreshState && !right) {
      refreshState = true;
      await getComic(next, comicId);
      print(
          "action:nextChapter, next: $next, previous: $previous, refreshState: $refreshState, pageAt: $pageAt, left: $left, right: $right, chapterList: $chapterList");
      refreshState = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> previousChapter() async {
    if (!refreshState && !left) {
      refreshState = true;
      await getComic(previous, comicId);
      refreshState = false;
      print(
          "action:previousChapter, next: $next, previous: $previous, refreshState: $refreshState, pageAt: $pageAt, left: $left, right: $right, chapterList: $chapterList");
      notifyListeners();
      return true;
    }
    return false;
  }

  Widget builder(int index) {
    if (index >= 0 && index < pages.length) {
      return pages[index];
    }
    return null;
  }

  int get length => pages.length;

  bool get left => previous == null || previous == '';

  bool get right => next == null || next == '';

  int get index => this._index;

  set index(int index) {
    this._index = index;
    notifyListeners();
  }
}
