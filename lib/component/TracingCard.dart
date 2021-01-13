import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/utils/static_language.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';

class TracingCard extends StatelessWidget{
  final String cover;
  final String title;
  final String subTitle;
  final String comicId;
  final bool isUnread;

  const TracingCard({Key key, this.cover, this.title, this.subTitle, this.comicId, this.isUnread}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
      padding: EdgeInsets.all(1),
      child: Card(
          child: Badge(
            position: BadgePosition.topEnd(top: -5, end: -5),
            showBadge: isUnread,
            animationType: BadgeAnimationType.scale,
            shape: BadgeShape.square,
            borderRadius: 3,
            child: _Card(cover, title, subTitle),
            badgeContent: Text(
              StaticLanguage.staticStrings['subscribeCard.newTip'],
              style: TextStyle(color: Colors.white),
            ),
          )),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ComicDetailPage(comicId);
        }));
      },
    );
  }

}

class _Card extends StatelessWidget {
  final String cover;
  final String title;
  final String subTitle;

  _Card(this.cover, this.title, this.subTitle);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$subTitle',
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
