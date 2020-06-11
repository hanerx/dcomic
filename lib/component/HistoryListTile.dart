import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';

class HistoryListTile extends StatefulWidget {
  final String cover;
  final String title;
  final String chapterName;
  final int date;
  final String comicId;

  HistoryListTile(
      this.cover, this.title, this.chapterName, this.date, this.comicId);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HistoryListTile(
        this.cover, this.title, this.chapterName, this.date, this.comicId);
  }
}

class _HistoryListTile extends State<HistoryListTile> {
  final String cover;
  final String title;
  final String chapterName;
  final int date;
  String formatDate = '';
  final String comicId;

  _HistoryListTile(
      this.cover, this.title, this.chapterName, this.date, this.comicId) {
    formatDate = ToolMethods.formatTimestamp(date);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ComicDetailPage(comicId);
        }));
      },
      child: Card(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: '$cover',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
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
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.details,
                              color: Colors.grey[500],
                            ),
                            Text(
                              '$chapterName',
                              style: TextStyle(color: Colors.grey[500]),
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
                              Icons.history,
                              color: Colors.grey[500],
                            ),
                            Text(
                              '$formatDate',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
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
