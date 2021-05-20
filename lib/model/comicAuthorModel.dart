import 'package:dcomic/model/comicRankingListModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:dcomic/component/AuthorCard.dart';
import 'package:dcomic/model/baseModel.dart';

class ComicAuthorModel extends BaseModel {
  final String authorId;
  final BaseSourceModel model;

  int page = 0;

  List<RankingComic> comics = [];

  ComicAuthorModel(this.authorId, this.model);

  Future<void> init() async {
    // CustomHttp http = CustomHttp();
    // try{
    //   var response = await http.getAuthor(authorId);
    //   if (response.statusCode == 200) {
    //     comics=response.data['data'];
    //     notifyListeners();
    //   }
    // }catch(e){
    //   logger.e('class: ComicAuthorModel, action: initFailed, authorId: $authorId exception: $e');
    // }
    try {
      comics =
          await model.homePageHandler.getAuthorComics(authorId, page: page);
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'getAuthorFailed');
    }
    notifyListeners();
  }

  List<Widget> buildAuthorWidget(context) {
    return comics
        .map<Widget>((e) => AuthorCard(
              imageUrl: e.cover,
              title: e.title,
              subtitle: e.types,
              model: e.model,
              id: e.comicId,
            ))
        .toList();
  }

  bool get empty => comics.length == 0;
}
