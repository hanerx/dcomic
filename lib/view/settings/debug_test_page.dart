import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/http/UniversalRequestModel.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/comic_source/KuKuSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/ManHuaGuiSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/MangabzSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/sourceProvider.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/ranking_page.dart';
import 'package:provider/provider.dart';

import '../comic_detail_page.dart';

class DebugTestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DebugTestPage();
  }
}

class _DebugTestPage extends State<DebugTestPage> {
  String _data;
  List<ComicDetail> _subs = [];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).SettingPageDebugTestTitle),
          bottom: TabBar(isScrollable: true, tabs: [
            Tab(
              text: 'mangabz漫画爬取',
            ),
            Tab(
              text: 'kuku搜索爬取',
            ),
            Tab(
              text: 'mangabz漫画获取',
            ),
            Tab(
              text: '漫画台搜索爬取',
            ),
            Tab(
              text: '获取订阅',
            )
          ]),
        ),
        body: TabBarView(children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: () async {
                      var response = await UniversalRequestModel()
                          .mangabzRequestHandler
                          .getChapterImage('m161157', 0);
                      var data =
                          await ToolMethods.eval(response.data.toString());
                      setState(() {
                        _data =
                            '${response.data.toString()}\n${jsonDecode(data)}';
                      });
                    },
                  ),
                  Text('$_data')
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: () async {
                      print((await KuKuSourceModel().get(title: '哥布林杀手')).getChapters());
                    },
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: () async {
                      print(await MangabzSourceModel().get(title: '想要成为影之实力者'));
                    },
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: () async {
                      var comic = await (await ManHuaGuiSourceModel()
                              .get(title: 'EX-ARM'))
                          .getChapter(chapterId: '467538');
                      comic.init();
                    },
                  )
                ],
              ),
            ),
          ),
          EasyRefresh(
            onRefresh: () async {
              var response = await CustomHttp().getSubscribeWeb();
              if (response.statusCode == 200) {
                var list = jsonDecode(response.data);
                for (var item in list) {
                  var data =
                      await Provider.of<SourceProvider>(context, listen: false)
                          .active
                          .get(comicId: item['sub_id'].toString());
                  setState(() {
                    _subs.add(data);
                  });
                }
              }
            },
            child: ListView.builder(
              itemBuilder: (context, index) {
                var data = _subs[index];
                return _CustomListTile(
                    data.cover,
                    data.title,
                    data.tags.map((e) => e['tag_name']).toList().join('/'),
                    data.updateTime,
                    data.comicId,
                    data.authors.map((e) => e['tag_name']).toList().join('/'));
              },
              itemCount: _subs.length,
            ),
          )
        ]),
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String types;
  final String date;
  final String authors;
  final String comicId;

  _CustomListTile(this.cover, this.title, this.types, this.date, this.comicId,
      this.authors);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ComicDetailPage(
            id: comicId,
            title: title,
          );
        }));
      },
      child: Card(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: '$cover',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                child:
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: 100,
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.supervisor_account,
                              color: Colors.grey[500],
                            ),
                            Text(
                              authors,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.category,
                              color: Colors.grey[500],
                            ),
                            Text(
                              types,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.history,
                              color: Colors.grey[500],
                            ),
                            Text(
                              date,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    ));
  }
}
