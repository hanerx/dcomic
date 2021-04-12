import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/database/downloader.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/view/comic_viewer.dart';
import 'package:provider/provider.dart';

import 'comic_source/baseSourceModel.dart';

class DownloadChaptersModel extends BaseModel {
  final String comicId;

  List<DownloadChapter> data;
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
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () async {
            await showDialog(context: context,builder: (context){
              return AlertDialog(
                content: Text('是否删除？'),
                actions: [
                  FlatButton(
                    child: Text('取消'),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('确认'),
                    onPressed: ()async{
                      DownloadProvider downloadProvider = DownloadProvider();
                      await downloadProvider.deleteChapter(item);
                      if (data.length <= 1) {
                        await downloadProvider.deleteComic(comicId);
                      }
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
            Provider.of<DownloadChaptersModel>(context, listen: false)
                .getChapters(comicId);
          },
        ),
        onTap: () async{
          Comic comic= await Provider.of<SourceProvider>(context,listen: false).active.getChapter(chapterId: item.chapterId,comicId: item.comicId);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ComicViewPage(
              comic: comic,
            );
          }));
        },
      ));
    }
  }

  int get length => data == null ? 0 : data.length;
}
