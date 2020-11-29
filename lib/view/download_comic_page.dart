import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/model/downloadChapters.dart';
import 'package:provider/provider.dart';

class DownloadComicPage extends StatefulWidget {
  final String comicId;
  final String title;

  const DownloadComicPage({Key key, this.comicId, this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DownloadComicPage();
  }
}

class _DownloadComicPage extends State<DownloadComicPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => DownloadChaptersModel(widget.comicId),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('下载详情-${widget.title}'),
          ),
          body: ListView.builder(
              itemCount: Provider.of<DownloadChaptersModel>(context).length,
              itemBuilder: Provider.of<DownloadChaptersModel>(context)
                  .buildChapterListTile),
        );
      },
    );
  }
}
