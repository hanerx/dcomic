import 'package:dcomic/component/comic/SearchListTile.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/view/novel_pages/novel_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';

class NovelSearchTab extends StatefulWidget {
  final String keyword;
  final Key key;

  NovelSearchTab({this.key, @required this.keyword});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelSearchTab();
  }
}

class _NovelSearchTab extends State<NovelSearchTab> {
  List list = <Widget>[];
  ScrollController _scrollController = ScrollController();
  int page = 0;

  bool refreshState = false;

  _NovelSearchTab();

  search() async {
    if (widget.keyword != null && widget.keyword != '') {
      var response = await UniversalRequestModel.dmzjRequestHandler.search(widget.keyword, page, type: 1);
      if (response.statusCode == 200 && mounted) {
        setState(() {
          if (response.data.length == 0) {
            refreshState = true;
            return;
          }
          for (var item in response.data) {
            list.add(SearchListTile(
              cover: item['cover'],
              title: item['title'],
              tag: item['types'],
              authors: item['authors'],
              latest: item['last_name'],
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NovelDetailPage(
                          id: item['id'],
                        ),
                    settings: RouteSettings(name: 'novel_detail_page')));
              },
            ));
            // list.add(SearchListTile(item['cover'], item['title'], item['types'],
            //     item['last_name'], item['id'].toString(), item['authors'],
            //     novel: 1));
          }
          refreshState = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return EasyRefresh(
      firstRefresh: true,
      firstRefreshWidget: LoadingCube(),
      onRefresh: () async {
        setState(() {
          refreshState = true;
          page = 0;
          list.clear();
        });
        await search();
      },
      onLoad: () async {
        setState(() {
          refreshState = true;
          page++;
        });
        await search();
      },
      emptyWidget: list.length == 0 ? EmptyView() : null,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: list.length,
        itemBuilder: (context, index) {
          return list[index];
        },
      ),
    );
  }
}
