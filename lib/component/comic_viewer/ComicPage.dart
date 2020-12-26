import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import 'package:share/share.dart';

class ComicPage extends StatefulWidget {
  final String url;
  final String chapterId;
  final String title;
  final int index;
  final bool cover;
  final bool local;

  const ComicPage(
      {Key key,
      this.url,
      this.chapterId,
      this.title,
      this.index,
      this.cover,
      this.local: false})
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
    if (widget.local) {
      return Image.file(
        File(widget.url),
        fit: widget.cover ? BoxFit.cover : BoxFit.contain,
        errorBuilder: (context, object, stack) {
          return Icon(Icons.error);
        },
      );
    }
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
                        DataBase dataBase = DataBase();
                        String path = await dataBase.getDownloadPath();
                        String save =
                            "$path/${DateTime.now().millisecondsSinceEpoch}${widget.url.substring(widget.url.lastIndexOf('.'))}";
                        try {
                          await http.downloadFile(widget.url, save);
                          Navigator.of(context).pop();
                          Toast.show("已保存至:$save", context,
                              duration: Toast.LENGTH_LONG);
                        } catch (e) {
                          Navigator.of(context).pop();
                          Toast.show("保存失败，请检查网络与写入权限", context,
                              duration: Toast.LENGTH_LONG);
                        }
                      }
                    },
                  ),
                  SimpleDialogOption(
                    child: Text(
                      '分享图片',
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
                        Directory path =
                            (await getExternalCacheDirectories())[0];
                        String save =
                            "${path.path}/${DateTime.now().millisecondsSinceEpoch}${widget.url.substring(widget.url.lastIndexOf('.'))}";
                        await http.downloadFile(widget.url, save);
                        Navigator.of(context).pop();
                        Share.shareFiles([save], text: '来自大妈之家的分享');
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
        errorWidget: (context, url, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error,color: Colors.redAccent,),
              Text('$error',style: TextStyle(color: Colors.redAccent),)
            ],
          ),
        ),
      ),
    );
  }

// @override
// TODO: implement wantKeepAlive
// bool get wantKeepAlive =>true;
}
