import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/view/category_detail_page.dart';
import 'package:flutterdmzj/view/novel_pages/novel_category_detail_page.dart';

class CategoryCard extends StatelessWidget {
  final String cover;
  final String title;
  final int tagId;
  final int type;

  CategoryCard(this.cover, this.title, this.tagId, {this.type: 0});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Card(
          child: new Container(
        child: Column(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: '$cover',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Text(
              '$title',
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )),
      onPressed: () {
        if (type == 0) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return CategoryDetailPage(tagId, title);
          }));
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return NovelCategoryDetailPage(
              categoryId: tagId,
              title: title,
            );
          }));
        }
      },
    ));
  }
}
