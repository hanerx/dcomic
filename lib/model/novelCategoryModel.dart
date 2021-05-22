import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/view/novel_pages/novel_category_detail_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:dcomic/component/CategoryCard.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

import 'comicCategoryModel.dart';

class NovelCategoryModel extends BaseModel {
  List<CategoryModel> category = [];
  bool _local = false;

  NovelCategoryModel();

  Future<void> init() async {
    try {
      category = await getCategorys();
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'CategoryLoadingFailed');
    }
    notifyListeners();
  }

  Future<List<CategoryModel>> getCategorys() async {
    try {
      var response =
          await UniversalRequestModel.dmzjRequestHandler.getCategory(type: 1);
      if ((response.statusCode == 200 || response.statusCode == 304)) {
        return response.data
            .map<CategoryModel>((e) => CategoryModel(
                  cover: e['cover'],
                  title: e['title'],
                  categoryId: e['tag_id'].toString(),
                  headers: {'referer': 'https://m.dmzj.com'},
                ))
            .toList();
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'dmzjCategoryLoadingFailed');
      throw e;
    }
    return [];
  }

  List<Widget> buildCategoryWidget(context) {
    return category
        .map<Widget>((e) => NovelCategoryCard(
              cover: e.cover,
              title: e.title,
              tagId: e.categoryId,
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

class NovelCategoryCard extends StatelessWidget {
  final String cover;
  final String title;
  final String tagId;

  NovelCategoryCard({this.cover, this.title, this.tagId});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
      child: Card(
          elevation: 0,
          child: new Container(
            child: Wrap(
              children: <Widget>[
                ClipRRect(
                  child: AspectRatio(
                    child: CachedNetworkImage(
                      imageUrl: '$cover',
                      fit: BoxFit.cover,
                      httpHeaders: {'referer': 'http://images.dmzj.com'},
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(FontAwesome5.folder_open),
                    ),
                    aspectRatio: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$title',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return NovelCategoryDetailPage(
                categoryId: tagId,
                title: title,
              );
            },
            settings: RouteSettings(name: 'novel_category_detail_page')));
      },
    );
  }
}
