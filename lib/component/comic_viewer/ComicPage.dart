import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

class ComicPage extends StatefulWidget {
  final String url;
  final String chapterId;
  final String title;
  final int index;
  final bool cover;

  const ComicPage(
      {Key key, this.url, this.chapterId, this.title, this.index, this.cover})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicPage();
  }
}

class _ComicPage extends State<ComicPage> {
  _ComicPage();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                children: [
                  SimpleDialogOption(
                    child: Text(
                      '保存图片',
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () async {
                      var state = await Permission.storage.request().isGranted;
                      if (state) {
                        var http = new CustomHttp();
                        // var response = await http.getImage(widget.url);
                        // var result = await ImageGallerySaver.saveImage(
                        //     Uint8List.fromList(response.data));
                        // print(result);
                        Directory path = await getExternalStorageDirectory();
                        String save =
                            "${path.path}/${DateTime.now().millisecondsSinceEpoch}${widget.url.substring(widget.url.lastIndexOf('.'))}";
                        await http.downloadFile(widget.url, save);
                        Navigator.of(context).pop();
                        Toast.show("已保存至:$save", context,duration: Toast.LENGTH_LONG);
                      }
                    },
                  )
                ],
              );
            });
      },
      child: CachedNetworkImage(
        fit: widget.cover ? BoxFit.cover : BoxFit.contain,
        imageUrl: widget.url,
        httpHeaders: {'referer': 'http://images.dmzj.com'},
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: Container(
          height: 500,
          child: Center(
            child: CircularProgressIndicator(value: downloadProgress.progress),
          ),
        )),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

// @override
// TODO: implement wantKeepAlive
// bool get wantKeepAlive =>true;
}
