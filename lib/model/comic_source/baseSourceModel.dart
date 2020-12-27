import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/model/comicDetail.dart';

import '../comic.dart';

abstract class BaseSourceModel extends BaseModel{
  Future<List> search(String keyword);
  Future<ComicDetailModel> get(String comicId);
  Future<ComicModel> getChapter(String comicId,String chapterId);
}

