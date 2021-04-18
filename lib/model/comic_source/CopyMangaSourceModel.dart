import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:flutter/src/widgets/framework.dart';

class CopyMangaSourceModel extends BaseSourceModel {
  @override
  Future<ComicDetail> get({String comicId, String title}) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<Comic> getChapter(
      {String comicId, String title, String chapterId, String chapterTitle}) {
    // TODO: implement getChapter
    throw UnimplementedError();
  }

  @override
  Future<List<FavoriteComic>> getFavoriteComics(int page) {
    // TODO: implement getFavoriteComics
    throw UnimplementedError();
  }

  @override
  Widget getSettingWidget(context) {
    // TODO: implement getSettingWidget
    throw UnimplementedError();
  }

  @override
  // TODO: implement options
  SourceOptions get options => throw UnimplementedError();

  @override
  Future<List<SearchResult>> search(String keyword, {int page = 0}) {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  // TODO: implement type
  SourceDetail get type => SourceDetail(
      name: 'copy_manga',
      title: '拷贝漫画',
      description: '拷贝漫画，万能的网友提供的网站，还蛮顶的',
      sourceType: SourceType.LocalDecoderSource,
      canSubscribe: true);

  @override
  // TODO: implement userConfig
  UserConfig get userConfig => throw UnimplementedError();
}
