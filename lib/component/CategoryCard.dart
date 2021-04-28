import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/view/category_detail_page.dart';
import 'package:dcomic/view/novel_pages/novel_category_detail_page.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class CategoryCard extends StatelessWidget {
  final String cover;
  final String title;
  final String tagId;
  final BaseSourceModel model;

  CategoryCard({this.cover, this.title, this.tagId, this.model});

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
              return CategoryDetailPage(
                categoryId: tagId,
                title: title,
                model: model,
              );
            },
            settings: RouteSettings(name: 'category_detail_page')));
      },
    );
  }
}
