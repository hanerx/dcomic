import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:dcomic/component/CategoryCard.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';

class ComicCategoryModel extends BaseModel {
  final int type;
  List category = [];

  ComicCategoryModel(this.type);

  Future<void> init() async {
      CustomHttp http = CustomHttp();
      try {
        var response = await http.getCategory(type);
        if (response.statusCode == 200) {
          category = response.data;
          notifyListeners();
        }
      } catch (e) {
        logger
            .e('class: ComicCategoryModel, action: initFailed, exception: $e');
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
}
