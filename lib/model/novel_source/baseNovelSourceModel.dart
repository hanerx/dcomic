import 'package:flutter/cupertino.dart';

import '../baseModel.dart';

abstract class BaseNovelSourceModel extends BaseModel {
  Future<List<NovelSearchResult>> search(String keyword, {int page: 0});

  Widget getSettingWidget(context);

}

abstract class NovelDetail extends BaseModel{

}

abstract class Novel extends BaseModel{

}

abstract class NovelSearchResult {
  String get title;

  String get novelId;

  String get cover;

  String get author;

  String get tag;

  String get latestChapter;

  @override
  String toString() {
    return 'SearchResult{title: $title, novelId: $novelId, cover: $cover, author: $author, tag: $tag}';
  }
}