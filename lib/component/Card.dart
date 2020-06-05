import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';
import 'package:flutterdmzj/view/subject_detail_page.dart';

class CustomCard extends StatelessWidget {
  String imageUrl = "";
  String title = "";
  String author = "";
  int type;
  String id;

  CustomCard(this.imageUrl, this.title, this.author, this.type, this.id);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
        child: FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: () {
        switch (type) {
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ComicDetailPage(id);
            }));
            break;
          case 5:
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SubjectDetailPage(id);
            }));
            break;
          default:
        }
      },
      child: Card(
          child: new Container(
        child: Column(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: '$imageUrl',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Text(
              '$title',
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${author != null ? author : ''}',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      )),
    ));
  }
}
