import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/view/comic_detail_page.dart';
import 'package:dcomic/view/subject_detail_page.dart';

class CustomCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final int type;
  final String id;

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
              return ComicDetailPage(id:id,title: title,);
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
          elevation: 0,
          child: new Container(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: '$imageUrl',
                    httpHeaders: {'referer': 'http://images.dmzj.com'},
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$title',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
                Text(
                  '${author != null ? author : ''}',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )),
    ));
  }
}
