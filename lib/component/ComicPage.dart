import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yin_drag_sacle/core/drag_scale_widget.dart';

class ComicPage extends StatefulWidget {
  final String url;
  final String chapterId;
  final String title;
  final int index;
  bool cover;

  ComicPage(this.url, this.chapterId, this.title, this.cover, this.index);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicPage(this.url, this.chapterId, this.title, this.cover);
  }
}

class _ComicPage extends State<ComicPage> {
  final String url;
  final String chapterId;
  final String title;
  bool cover;

  _ComicPage(this.url, this.chapterId, this.title, this.cover);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DragScaleContainer(
        doubleTapStillScale: false,
        maxScale: 4,
        child: CachedNetworkImage(
          fit: cover ? BoxFit.cover : BoxFit.contain,
          imageUrl: url,
          httpHeaders: {'referer': 'http://images.dmzj.com'},
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
              child:
                  CircularProgressIndicator(value: downloadProgress.progress)),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ));
  }
}
