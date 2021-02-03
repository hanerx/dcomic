import 'package:flutter/cupertino.dart';
import 'package:flutterdmzj/component/DownloadComicListTile.dart';
import 'package:flutterdmzj/database/downloader.dart';
import 'package:flutterdmzj/model/baseModel.dart';

class DownloadModel extends BaseModel {
  List<Comic> data;


  DownloadModel() {
    logger.i('action: init');
    getComic();
  }

  Future<void> getComic() async {
    DownloadProvider downloadProvider = DownloadProvider();
    data = await downloadProvider.getAllComic();
    logger.i('action: getComic, comicList: $data');
    notifyListeners();
  }

  Widget buildComicListTile(context, index) {
    if (index < 0 || index >= data.length) {
      return null;
    }
    return DownloadComicListTile(
      title: data[index].title,
      comicId: data[index].comicId,
      cover: data[index].cover,
    );
  }

  int get length => data == null ? 0 : data.length;
}
