import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/generated/l10n.dart';

class SubscribeCard extends StatefulWidget {
  final String cover;
  final String title;
  final String subTitle;
  final bool isUnread;
  final VoidCallback onTap;

  const SubscribeCard({Key key, this.cover, this.title, this.subTitle, this.isUnread, this.onTap}) : super(key: key);



  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SubscribeCard();
  }
}

class _SubscribeCard extends State<SubscribeCard> {
  bool isUnread = false;

  _SubscribeCard();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isUnread=widget.isUnread;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
      padding: EdgeInsets.zero,
      child: Card(
          elevation: 0,
          child: Badge(
            position: BadgePosition.topEnd(top: -5, end: -4),
            showBadge: isUnread,
            animationType: BadgeAnimationType.scale,
            shape: BadgeShape.square,
            elevation: 0,
            borderRadius: BorderRadius.circular(5),
            child: _Card(widget.cover, widget.title, widget.subTitle),
            badgeContent: Text(
              S.of(context).TipsNew,
              style: TextStyle(color: Colors.white),
            ),
          )),
      onPressed: () {
        setState(() {
          isUnread = false;
        });
        widget.onTap();
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
    return Wrap(
      children: <Widget>[
        ClipRRect(
          child: AspectRatio(
            aspectRatio: 0.75,
            child:CachedNetworkImage(
            imageUrl: '$cover',
            httpHeaders: {'referer': 'http://images.dmzj.com'},
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),),
          borderRadius: BorderRadius.circular(5),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '$title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
        Text(
          S.of(context).SubscribeLatestUpdate(subTitle),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        )
      ],
    );
  }
}
