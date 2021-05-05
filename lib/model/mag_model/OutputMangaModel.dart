import 'package:dcomic/database/localMangaDatabaseProvider.dart';
import 'package:dcomic/model/comic_source/LocalSourceModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/mag_model/baseMangaModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../baseModel.dart';

class OutputMangaModel extends BaseModel{
  List<MangaObject> _data=[];

  OutputMangaModel();

  Future<void> init()async{
    try{
      _data=await LocalMangaDatabaseProvider().getAll();
      notifyListeners();
    }catch(e,s){
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'localComicListInitFailed');
    }
  }

  List<MangaObject> get data=>_data;
}