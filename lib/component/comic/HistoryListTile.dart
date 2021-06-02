import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/component/comic/BaseListTile.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/utils/ProxyCacheManager.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HistoryListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String chapterName;
  final int date;
  final String provider;
  final VoidCallback onPressed;

  const HistoryListTile({
    Key key,
    this.cover,
    this.title,
    this.chapterName,
    this.date,
    this.onPressed,
    this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseListTile(
      onPressed: onPressed,
      leading: CachedNetworkImage(
        imageUrl: '$cover',
        fit: BoxFit.cover,
        httpHeaders: {'referer': 'http://images.dmzj.com'},
        progressIndicatorBuilder: (context, url, downloadProgress) =>Container(
          child: Center(
            child: CircularProgressIndicator(
                value: downloadProgress.progress),
          ),
        ),
        errorWidget: (context, url, error) => CachedNetworkImage(
          imageUrl: '$cover',
          fit: BoxFit.cover,
          cacheManager: BadCertificateCacheManager(),
          httpHeaders: {'referer': 'http://images.dmzj.com'},
          progressIndicatorBuilder: (context, url, downloadProgress) =>Container(
            child: Center(
              child: CircularProgressIndicator(
                  value: downloadProgress.progress),
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
          width: 100,
        ),
        width: 100,
      ),
      detail: <Widget>[
        Text(
          "$title",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          height: 12,
        ),
        Text.rich(
          TextSpan(children: [
            WidgetSpan(
                child: Icon(
              Icons.category,
              color: Colors.grey,
              size: 23,
            )),
            TextSpan(
              text: " ",
            ),
            TextSpan(
                text: '$chapterName',
                style: TextStyle(color: Colors.grey, fontSize: 16))
          ]),
        ),
        SizedBox(
          height: 6,
        ),
        Text.rich(
          TextSpan(children: [
            WidgetSpan(
                child: Icon(
              Icons.history,
              color: Colors.grey,
              size: 23,
            )),
            TextSpan(
              text: " ",
            ),
            TextSpan(
                text: ToolMethods.formatTimestamp(date),
                style: TextStyle(color: Colors.grey, fontSize: 16))
          ]),
        ),
        SizedBox(
          height: 6,
        ),
        Text.rich(
          TextSpan(children: [
            WidgetSpan(
                child: Icon(
              Icons.electrical_services,
              color: Colors.grey,
              size: 23,
            )),
            TextSpan(
              text: " ",
            ),
            TextSpan(
                text: '$provider',
                style: TextStyle(color: Colors.grey, fontSize: 16))
          ]),
        ),
      ],
    );
  }
}
