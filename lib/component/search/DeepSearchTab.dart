import 'dart:convert';

import 'package:dcomic/component/comic/SearchListTile.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/view/comic_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:provider/provider.dart';

class DeepSearchTab extends StatefulWidget {
  final Key key;
  final String keyword;

  DeepSearchTab({this.key, this.keyword});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DeepSearchTab(keyword);
  }
}

class _DeepSearchTab extends State<DeepSearchTab> {
  List list = <Widget>[];
  final String keyword;

  _DeepSearchTab(this.keyword);

  search() async {
    if (keyword != null && keyword != '') {
      try {
        var response = await UniversalRequestModel.dmzjsacgRequestHandler.deepSearch(keyword);
        if ((response.statusCode == 200||response.statusCode == 304) && mounted) {
          var jsonData = response.data.toString().substring(
              response.data.toString().indexOf('=') + 1,
              response.data.toString().length - 1);
          var data = jsonDecode(jsonData);
          setState(() {
            if (response.data.length == 0) {
              return;
            }
            for (var item in data) {
              list.add(SearchListTile(
                cover: item['cover'].replaceAll('dmzj.com','dmzj1.com'),
                title: item['comic_name'],
                tag: '暂无数据',
                authors: item['comic_author'],
                latest: item['last_update_chapter_name'],
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ComicDetailPage(
                            id: item['id'].toString(),
                            title: item['comic_name'],
                            model: Provider.of<SourceProvider>(context,
                                    listen: false)
                                .activeSources
                                .first,
                          )));
                },
              ));
            }
          });
        }
      } catch (e) {
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
      onRefresh: () async {
        await search();
      },
      firstRefreshWidget: LoadingCube(),
      firstRefresh: true,
      emptyWidget: list.length == 0 ? EmptyView() : null,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return list[index];
        },
      ),
    );
  }
}
