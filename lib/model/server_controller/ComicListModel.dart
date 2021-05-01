import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/IPFSSourceProivder.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';

class ComicListModel extends BaseModel {
  final IPFSSourceModel node;

  List<SearchResult> _data = [];

  TextEditingController controller=TextEditingController();

  ComicListModel(this.node);

  Future<void> init() async {
    try {
      _data = await node.search(controller.text);
      notifyListeners();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'comicListLoadingFailed: ${node.address}');
    }
  }

  List<SearchResult> get data => _data;
}
