import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterdmzj/model/novel.dart';
import 'package:provider/provider.dart';

class NovelViewerPage extends StatefulWidget {
  final String title;
  final List chapters;
  final int novelID;
  final int volumeID;
  final int chapterID;

  const NovelViewerPage(
      {Key key,
      this.title,
      this.chapters,
      this.novelID,
      this.volumeID,
      this.chapterID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelViewerPage();
  }
}

class _NovelViewerPage extends State<NovelViewerPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => NovelModel(widget.title, widget.chapters, widget.novelID,
          widget.volumeID, widget.chapterID),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${Provider.of<NovelModel>(context).title}'),
          ),
          endDrawer: Drawer(
            child: Scaffold(
              appBar: AppBar(title: Text('目录'),),
              body: SingleChildScrollView(
                child: ExpansionPanelList(
                  expansionCallback:
                  Provider.of<NovelModel>(context).setExpand,
                  children: Provider.of<NovelModel>(context).buildChapterWidget(context),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: HtmlWidget(Provider.of<NovelModel>(context).data),
          ),
        );
      },
    );
  }
}
