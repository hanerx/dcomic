import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';
import 'package:flutterdmzj/view/novel_pages/novel_detail_page.dart';

class SearchListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String types;
  final String last;
  final String authors;
  final String comicId;
  final int novel;

  SearchListTile(
      this.cover, this.title, this.types, this.last, this.comicId, this.authors,
      {this.novel: 0});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      onPressed: () {
        switch (novel) {
          case 0:
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ComicDetailPage(id:comicId,title: this.title,);
            }));
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return NovelDetailPage(id: int.parse(comicId));
            }));
            break;
        }
      },
      child: Card(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: '$cover',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                child:
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: 100,
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '$title',
                        style: TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.supervisor_account,
                              color: Colors.grey[500],
                            ),
                            Expanded(
                              child: Text(
                                '$authors',
                                style: TextStyle(color: Colors.grey[500]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.category,
                              color: Colors.grey[500],
                            ),
                            Expanded(
                              child: Text(
                                "$types",
                                style: TextStyle(color: Colors.grey[500]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        )),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.history,
                              color: Colors.grey[500],
                            ),
                            Expanded(
                              child: Text(
                                '$last',
                                style: TextStyle(color: Colors.grey[500]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        )),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    ));
  }
}
