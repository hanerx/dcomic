import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/model/systemSettingModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:share/share.dart';

class ComicPage extends StatefulWidget {
  final String url;
  final String chapterId;
  final String title;
  final int index;
  final bool cover;
  final Map headers;
  final PageType type;

  const ComicPage(
      {Key key,
      this.url,
      this.chapterId,
      this.title,
      this.index,
      this.cover,
      this.type: PageType.url,
      this.headers})
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
    if (widget.type == PageType.local) {
      return GestureDetector(
          onLongPress: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    children: [
                      SimpleDialogOption(
                        child: Text(
                          '分享图片',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () async {
                          var state =
                              await Permission.storage.request().isGranted;
                          if (state) {
                            Navigator.of(context).pop();
                            Share.shareFiles([widget.url], text: '来自大妈之家的分享');
                            Provider.of<SystemSettingModel>(context,
                                    listen: false)
                                .analytics
                                .logShare(
                                    contentType: 'Image',
                                    itemId: widget.url,
                                    method: 'share_local_image');
                          }
                        },
                      )
                    ],
                  );
                });
          },
          child: Image.file(
            File(widget.url),
            fit: widget.cover ? BoxFit.cover : BoxFit.contain,
            errorBuilder: (context, object, stack) {
              return Icon(Icons.error);
            },
          ));
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
                        String path = Provider.of<SystemSettingModel>(context,
                                listen: false)
                            .savePath;
                        String save =
                            "$path/${DateTime.now().millisecondsSinceEpoch}${widget.url.substring(widget.url.lastIndexOf('.'))}";
                        try {
                          await Dio().download(widget.url, save,
                              options: Options(headers: widget.headers));
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
                        Directory path = await getTemporaryDirectory();
                        String save =
                            "${path.path}/${DateTime.now().millisecondsSinceEpoch}${widget.url.substring(widget.url.lastIndexOf('.'))}";
                        await Dio().download(widget.url, save,
                            options: Options(headers: widget.headers));
                        Navigator.of(context).pop();
                        Share.shareFiles([save], text: '来自大妈之家的分享');
                        Provider.of<SystemSettingModel>(context, listen: false)
                            .analytics
                            .logShare(
                                contentType: 'Image',
                                itemId: widget.url,
                                method: 'share_image');
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
        httpHeaders: widget.headers,
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
              Icon(
                Icons.error,
                color: Colors.redAccent,
              ),
              Text(
                '$error',
                style: TextStyle(color: Colors.redAccent),
              )
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
