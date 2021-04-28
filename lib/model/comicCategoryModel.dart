import 'dart:convert';

import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:dcomic/component/CategoryCard.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:flutter/services.dart';

class ComicCategoryModel extends BaseModel {
  final BaseSourceModel model;
  List<CategoryModel> category = [];
  bool _local = false;

  ComicCategoryModel(this.model);

  Future<void> init() async {
    try {
      category = await model.homePageHandler
          .getCategory(type: _local ? CategoryType.local : CategoryType.cloud);
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'CategoryLoadingFailed');
    }
    notifyListeners();
  }

  List<Widget> buildCategoryWidget(context) {
    return category
        .map<Widget>((e) => CategoryCard(
              cover: e.cover,
              title: e.title,
              tagId: e.categoryId,
              model: e.model,
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

class CategoryModel {
  final String cover;
  final Map<String, String> headers;
  final String title;
  final String categoryId;
  final BaseSourceModel model;

  CategoryModel(
      {this.cover, this.headers, this.title, this.categoryId, this.model});
}
