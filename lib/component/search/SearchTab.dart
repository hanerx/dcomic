import 'package:dcomic/component/comic/SearchListTile.dart';
import 'package:dcomic/model/comicSearchModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/view/comic_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

import '../EmptyView.dart';
import '../LoadingCube.dart';

class SearchTab extends StatefulWidget {
  final String keyword;
  final Key key;
  final BaseSourceModel model;

  SearchTab({this.key, @required this.keyword, this.model});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchTab();
  }
}

class _SearchTab extends State<SearchTab> {
  List list = <Widget>[];
  int page = 0;
  bool refreshState = false;

  _SearchTab();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ComicSearchModel(widget.model, widget.keyword),
      builder: (context, child) => EasyRefresh(
        scrollController: ScrollController(),
        firstRefreshWidget: LoadingCube(),
        firstRefresh: true,
        onRefresh: () async {
          await Provider.of<ComicSearchModel>(context, listen: false).refresh();
        },
        onLoad: () async {
          await Provider.of<ComicSearchModel>(context, listen: false).next();
        },
        emptyWidget: Provider.of<ComicSearchModel>(context).length == 0
            ? EmptyView()
            : null,
        child: ListView.builder(
          itemCount: Provider.of<ComicSearchModel>(context).length,
          itemBuilder: (context, index) {
            var comic = Provider.of<ComicSearchModel>(context, listen: false)
                .list[index];
            return SearchListTile(
              cover: comic.cover,
              title: comic.title,
              authors: comic.author,
              tag: comic.tag,
              latest: comic.latestChapter,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ComicDetailPage(
                          id: comic.comicId,
                          title: comic.title,
                          model: widget.model,
                        ),
                    settings: RouteSettings(name: 'comic_detail_page')));
              },
            );
          },
        ),
      ),
    );
  }
}
