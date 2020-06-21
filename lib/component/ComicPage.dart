import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yin_drag_sacle/core/drag_scale_widget.dart';

class ComicPage extends StatelessWidget{
  final String url;
  final String chapterId;
  final String title;


  ComicPage(this.url, this.chapterId,this.title);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DragScaleContainer(
        doubleTapStillScale: false,
        maxScale: 4,
        child: CachedNetworkImage(
      imageUrl: url,
      httpHeaders: {'referer': 'http://images.dmzj.com'},
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          Center(
              child: CircularProgressIndicator(
                  value: downloadProgress.progress)),
      errorWidget: (context, url, error) => Icon(Icons.error),
    ));
  }

}