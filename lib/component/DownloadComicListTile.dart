import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/view/download_comic_page.dart';

class DownloadComicListTile extends StatelessWidget {
  final String title;
  final String cover;
  final String comicId;

  const DownloadComicListTile({Key key, this.title, this.cover, this.comicId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: TextButton(
          style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(1, 0, 1, 0))),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return DownloadComicPage(comicId: comicId,title: title,);
            },settings: RouteSettings(name: 'download_comic_page')));
          },
          child: Card(
            child: Row(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: '$cover',
                  httpHeaders: {'referer': 'http://images.dmzj.com'},
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(child: CircularProgressIndicator(
                          value: downloadProgress.progress),),
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
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ));
  }

}