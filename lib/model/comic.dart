import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/ViewPointChip.dart';
import 'package:flutterdmzj/component/comic_viewer/ComicPage.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/database/downloader.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';

class ComicModel extends BaseModel {
  final Comic comic;

  int _index = 0;

  bool refreshState=false;

  //用户信息
  bool login = false;
  String uid = '';

  ComicModel(this.comic) {
    init();
  }

  Future<void> init()async {
    await comic.init();
    notifyListeners();
    await setReadHistory(chapterId, comicId);
  }

  Future<void> setReadHistory(String chapterId, String comicId) async {
    await comic.addReadHistory(comicId: comicId,chapterId: chapterId);
  }

  Future<void> getComic(chapterId, comicId) async {
    refreshState=true;
    notifyListeners();
    await comic.getComic(chapterId: chapterId, comicId: comicId);
    refreshState=false;
    notifyListeners();
  }

  Future<void> refreshViewPoint() async {
    if(!left&&!refreshState){
      refreshState=true;
      notifyListeners();
      await comic.getViewPoint();
      refreshState=false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> nextChapter() async {
    if(!right&&!refreshState){
      refreshState=true;
      notifyListeners();
      bool flag=await comic.next();
      index=0;
      refreshState=false;
      notifyListeners();
      return flag;
    }
    return false;
  }

  Future<bool> previousChapter() async {
    refreshState=true;
    notifyListeners();
    bool flag=await comic.previous();
    index=0;
    refreshState=false;
    notifyListeners();
    return flag;
  }

  Widget buildChapterWidget(context, index) {
    return ListTile(
      selected: comic.chapters[index]['chapter_id'].toString() == comic.pageAt,
      title: Text('${comic.chapters[index]['chapter_title']}'),
      subtitle: Text(
          '更新时间：${ToolMethods.formatTimestamp(comic.chapters[index]['updatetime'])} 章节ID：${comic.chapters[index]['chapter_id']}'),
      onTap: () async {
        await getComic(
            comic.chapters[index]['chapter_id'].toString(), comic.comicId);
        Navigator.of(context).pop();
      },
    );
  }

  Widget builder(int index) {
    if (comic != null && index >= 0 && index < comic.comicPages.length) {
      return ComicPage(
        url: comic.comicPages[index],
        title: comic.title,
        chapterId: comic.pageAt,
        local: comic.type == 1,
        index: index,
        cover: false,
        headers: comic.headers,
      );
    }
    return null;
  }

  List<Widget> buildViewPoint(context) {
    if(comic==null){
      return <Widget>[];
    }
    return comic.viewpoints
        .map<Widget>((e) => ViewPointChip(
              content: e['content'],
              num: e['num'],
              id: e['id'].toString(),
            ))
        .toList();
  }

  int get catalogueLength => comic == null ? 0 : comic.chapters.length;

  int get length => comic == null ? 0 : comic.comicPages.length;

  bool get left => comic == null ? true : !comic.canPrevious;

  bool get right => comic == null ? true : !comic.canNext;

  int get index => this._index;

  String get chapterId => comic == null ? '' : comic.chapterId;

  String get comicId => comic == null ? '' : comic.comicId;

  List get chapters => comic == null ? [] : comic.chapters;

  String get pageAt => comic == null ? '' : comic.pageAt;

  String get title=>comic==null?'':comic.title;

  bool get emptyViewPoint=>comic==null?true:comic.viewpoints.length==0;

  set index(int index) {
    this._index = index;
    notifyListeners();
  }
}
