import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/component/comic/BaseListTile.dart';
import 'package:dcomic/utils/ProxyCacheManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SubjectListTile extends StatelessWidget {
  final String cover;
  final VoidCallback onPressed;
  final Map<String, String> headers;
  final String title;
  final String recommendBrief;
  final String recommendReason;

  const SubjectListTile(
      {Key key,
      this.cover,
      this.onPressed,
      this.headers,
      this.title,
      this.recommendBrief,
      this.recommendReason})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BaseListTile(
      onPressed: onPressed,
      leading: CachedNetworkImage(
        imageUrl: cover,
        httpHeaders: headers,
        progressIndicatorBuilder: (context, url, downloadProgress) => Container(
          child: Center(
            child: CircularProgressIndicator(value: downloadProgress.progress),
          ),
        ),
        errorWidget: (context, url, error) => CachedNetworkImage(
          imageUrl: cover,
          httpHeaders: headers,
          cacheManager: BadCertificateCacheManager(),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Container(
            child: Center(
              child:
                  CircularProgressIndicator(value: downloadProgress.progress),
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
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
              Icons.tag,
              color: Colors.grey,
              size: 23,
            )),
            TextSpan(
              text: " ",
            ),
            TextSpan(
                text: recommendBrief,
                style: TextStyle(color: Colors.grey, fontSize: 16))
          ]),
        ),
        SizedBox(
          height: 12,
        ),
        Text.rich(
          TextSpan(children: [
            WidgetSpan(
                child: Icon(
              Icons.message,
              color: Colors.grey,
              size: 23,
            )),
            TextSpan(
              text: " ",
            ),
            TextSpan(
                text: recommendReason,
                style: TextStyle(color: Colors.grey, fontSize: 16))
          ]),
        ),
      ],
    );
  }
}
