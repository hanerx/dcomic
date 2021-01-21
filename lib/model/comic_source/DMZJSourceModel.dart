import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';

class DMZJSourceModel extends BaseSourceModel{
  @override
  Future<ComicDetail> get({String comicId, String title}) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<Comic> getChapter({String comicId, String title, String chapterId, String chapterTitle}) {
    // TODO: implement getChapter
    throw UnimplementedError();
  }

  @override
  Future<List<ComicDetail>> search(String keyword) {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  // TODO: implement type
  SourceDetail get type => SourceDetail('dmzj','默认-动漫之家','默认数据提供商，不可关闭');


}