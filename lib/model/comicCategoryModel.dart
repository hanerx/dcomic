import 'dart:convert';

import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:dcomic/component/CategoryCard.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:flutter/services.dart';

class ComicCategoryModel extends BaseModel {
  final int type;
  List category = [];
  bool _local = false;

  ComicCategoryModel(this.type);

  Future<void> init() async {
    if (type == 0 && _local) {
      List data =
          jsonDecode(await rootBundle.loadString("assets/json/category.json"));
      category = data
          .map<Map>((e) =>
              {'title': e['title'], 'cover': e['cover'], 'tag_id': e['tag_id']})
          .toList();
      notifyListeners();
    } else {
      try {
        var response = await UniversalRequestModel.dmzjRequestHandler.getCategory(type);
        if (response.statusCode == 200) {
          category = response.data;
          notifyListeners();
        }
      } catch (e,s) {
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: 'CategoryLoadingFailed: $type');
        logger
            .e('class: ComicCategoryModel, action: initFailed, exception: $e');
      }
    }
  }

  List<Widget> buildCategoryWidget(context) {
    return category
        .map<Widget>((e) => CategoryCard(
              e['cover'],
              e['title'],
              e['tag_id'],
              type: type,
            ))
        .toList();
  }

  bool get empty => category.length == 0;

  bool get local => _local;

  set local(bool value) {
    _local = value;
    notifyListeners();
  }
}
