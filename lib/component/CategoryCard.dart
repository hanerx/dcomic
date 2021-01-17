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
    return FlatButton(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Card(
        elevation: 0,
          child: new Container(
        child: Wrap(
          children: <Widget>[
           ClipRRect(
             child:  AspectRatio(
               child: CachedNetworkImage(
                 imageUrl: '$cover',
                 httpHeaders: {'referer': 'http://images.dmzj.com'},
                 progressIndicatorBuilder: (context, url, downloadProgress) =>
                     Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                 errorWidget: (context, url, error) => Icon(Icons.error),
               ),
               aspectRatio: 1,
             ),
             borderRadius: BorderRadius.circular(5),
           ),
            Row(
              children: [Expanded(
                child: Text(
                  '$title',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              )],
            )
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
    );
  }
}
