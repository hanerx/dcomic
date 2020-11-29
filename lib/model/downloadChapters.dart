import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/downloader.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/view/comic_viewer.dart';

class DownloadChaptersModel extends BaseModel {
  final String comicId;

  List<Chapter> data;
  List<Widget> list = [];

  BuildContext context;

  DownloadChaptersModel(this.comicId) {
    getChapters(comicId);
  }

  Future<void> getChapters(comicId) async {
    DownloadProvider downloadProvider = DownloadProvider();
    data = await downloadProvider.getAllChapter(comicId);
    data.sort(
        (a, b) => int.parse(b.chapterId).compareTo(int.parse(a.chapterId)));
    await buildList();
    notifyListeners();
  }

  Widget buildChapterListTile(context, index) {
    this.context = context;
    if (index < 0 || index > list.length) {
      return null;
    }
    return list[index];
  }

  Future<void> buildList() async {
    for (var item in data) {
      list.add(ListTile(
        title: Text('${item.title}'),
        subtitle: LinearProgressIndicator(
          value: await item.progress / item.total,
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ComicViewPage(
              comicId: comicId,
              chapterId: item.chapterId,
              chapterList: data.map<String>((e) => e.chapterId).toList(),
            );
          }));
        },
      ));
    }
  }

  int get length => data == null ? 0 : data.length;
}
