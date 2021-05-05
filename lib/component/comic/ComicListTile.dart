import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/component/comic/BaseListTile.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/utils/tool_methods.dart';

class ComicListTile extends StatelessWidget {
  final String cover;
  final Map<String, String> headers;
  final String title;
  final String authors;
  final String tag;
  final int date;
  final VoidCallback onPressed;
  final PageType pageType;

  const ComicListTile(
      {Key key,
      this.cover,
      this.headers,
      this.title,
      this.authors,
      this.tag,
      this.date,
      this.onPressed,
      this.pageType: PageType.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseListTile(
      onPressed: onPressed,
      leading: buildImage(context),
      detail: <Widget>[
        Text(
          title,
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
              Icons.supervisor_account,
              color: Colors.grey,
              size: 23,
            )),
            TextSpan(
              text: " ",
            ),
            TextSpan(
                text: authors,
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
              Icons.category,
              color: Colors.grey,
              size: 23,
            )),
            TextSpan(
              text: " ",
            ),
            TextSpan(
                text: tag, style: TextStyle(color: Colors.grey, fontSize: 16))
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
      ],
    );
  }

  Widget buildImage(context) {
    if (pageType == PageType.local) {
      return Image.file(File(cover));
    }
    return CachedNetworkImage(
      imageUrl: cover,
      httpHeaders: headers,
      progressIndicatorBuilder: (context, url, downloadProgress) => Container(
        child: Center(
          child: CircularProgressIndicator(value: downloadProgress.progress),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
