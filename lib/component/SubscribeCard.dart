import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/utils/static_language.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';

class SubscribeCard extends StatefulWidget {
  final String cover;
  final String title;
  final String subTitle;
  final String comicId;
  final bool isUnread;

  SubscribeCard(
      this.cover, this.title, this.subTitle, this.comicId, this.isUnread);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SubscribeCard(
        this.cover, this.title, this.subTitle, this.comicId, this.isUnread);
  }
}

class _SubscribeCard extends State<SubscribeCard> {
  final String cover;
  final String title;
  final String subTitle;
  final String comicId;
  bool isUnread = false;

  _SubscribeCard(
      this.cover, this.title, this.subTitle, this.comicId, this.isUnread);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
      child: FlatButton(
        padding: EdgeInsets.all(0),
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
          setState(() {
            isUnread = false;
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ComicDetailPage(comicId);
          }));
        },
      ),
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
          '${StaticLanguage.staticStrings['subscribeCard.latestUpdate']}$subTitle',
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
