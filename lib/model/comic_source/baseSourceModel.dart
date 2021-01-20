import 'package:flutterdmzj/model/baseModel.dart';


abstract class BaseSourceModel extends BaseModel{
  Future<List<ComicDetail>> search(String keyword);
  Future<ComicDetail> get({String comicId,String title});
  Future<Comic> getChapter({String comicId,String title,String chapterId, String chapterTitle});
  SourceDetail get type;
}

abstract class ComicDetail extends BaseModel{
  Comic getChapter({String title,String chapterId});
  List<List<Map<String,dynamic>>> getChapters();
  String get title;
  String get description;
  int get subscribeNum;
  int get hotNum;
  String get comicId;
}

abstract class Comic extends BaseModel{
  List<String> get comicPages;
  String get title;
  List<Map<String,dynamic>> get viewpoints;
}

class SourceDetail{
  final String name;
  final String title;
  final String description;

  SourceDetail(this.name, this.description, this.title);

  @override
  // TODO: implement hashCode
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if(other is SourceDetail){
      return name==other.name;
    }
    return false;
  }
}