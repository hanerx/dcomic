import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/component/ViewPointChip.dart';
import 'package:dcomic/component/comic_viewer/ComicPage.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/utils/tool_methods.dart';

class ComicModel extends BaseModel {
  final Comic comic;
  final bool enableViewpoint;

  int _index = 0;

  bool refreshState = false;

  //用户信息
  bool login = false;
  String uid = '';

  int _initialIndex = 0;

  ComicModel(this.comic, this.enableViewpoint) {
    init();
  }

  Future<void> init() async {
    try {
      await comic.init();
      await comic.addReadHistory();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'chapterLoadingFailed: $comicId, chapterId: $pageAt');
    }
    notifyListeners();
  }

  Future<void> getComic(chapterId, comicId) async {
    refreshState = true;
    notifyListeners();
    try {
      await comic.getComic(chapterId: chapterId, comicId: comicId);
      await comic.addReadHistory();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'chapterLoadingFailed: $comicId, chapterId: $pageAt');
    }
    index = 0;
    refreshState = false;
    notifyListeners();
  }

  Future<void> refreshViewPoint() async {
    if (!left && !refreshState) {
      refreshState = true;
      notifyListeners();
      await comic.getViewPoint();
      refreshState = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> nextChapter() async {
    if (!right && !refreshState) {
      refreshState = true;
      notifyListeners();
      index = 0;
      bool flag = false;
      try {
        flag = await comic.next();
        await comic.addReadHistory();
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s,
            reason: 'chapterLoadingFailed: $comicId, chapterId: $pageAt');
      }
      refreshState = false;
      notifyListeners();
      return flag;
    }
    return false;
  }

  Future<bool> previousChapter() async {
    refreshState = true;
    notifyListeners();
    bool flag = false;
    try {
      flag = await comic.previous();
      await comic.addReadHistory();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'chapterLoadingFailed: $comicId, chapterId: $pageAt');
    }
    index = 0;
    refreshState = false;
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

  Widget builder(int index, context) {
    if (comic != null && index >= 0 && index < comic.comicPages.length) {
      return ComicPage(
        url: comic.comicPages[index],
        title: comic.title,
        chapterId: comic.pageAt,
        type: comic.type,
        index: index,
        cover: false,
        headers: comic.headers,
      );
    } else if (comic.comicPages.length == index && enableViewpoint) {
      return Center(
        child: Card(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text('本章结束'),
              Divider(),
              Container(
                height: 200,
                child: Wrap(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  children: buildViewPoint(context),
                ),
              ),
              Divider(),
              TextButton.icon(
                  onPressed: () {
                    print('hit!');
                  },
                  onLongPress: () {
                    initialIndex = 0;
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: Icon(Icons.message),
                  label: Text('长按查看更多'))
            ],
          ),
        ),
      );
    }
    return null;
  }

  List<Widget> buildViewPoint(context) {
    if (comic == null) {
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

  int get length => comic == null
      ? 0
      : enableViewpoint
          ? comic.comicPages.length + 1
          : comic.comicPages.length;

  bool get left => comic == null ? true : !comic.canPrevious;

  bool get right => comic == null ? true : !comic.canNext;

  int get index => this._index;

  String get chapterId => comic == null ? '' : comic.chapterId;

  String get comicId => comic == null ? '' : comic.comicId;

  List get chapters => comic == null ? [] : comic.chapters;

  String get pageAt => comic == null ? '' : comic.pageAt;

  String get title => comic == null ? '' : comic.title;

  bool get emptyViewPoint =>
      comic == null ? true : comic.viewpoints.length == 0;

  set index(int index) {
    this._index = index;
    notifyListeners();
  }

  int get initialIndex => _initialIndex;

  set initialIndex(int index) {
    _initialIndex = index;
    notifyListeners();
  }
}
