import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/login_page.dart';

import 'comic_detail_page.dart';

class HistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HistoryPage();
  }
}

class _HistoryPage extends State<HistoryPage> {
  String uid = '';
  int page = 0;
  List list = <Widget>[];

  initLoginState() async {
    DataBase dataBase = DataBase();
    var login = await dataBase.getLoginState();
    if (login) {
      uid = await dataBase.getUid();
      getHistory();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return LoginPage();
      }));
    }
  }

  getHistory() async {
    CustomHttp http = CustomHttp();
    var response = await http.getReadHistory(uid, page);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        var data = jsonDecode(response.data);
        for (var item in data) {
          list.add(HistoryListTile(
              item['cover'],
              item['comic_name'],
              item['chapter_name'],
              item['viewing_time'],
              item['comic_id'].toString()));
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initLoginState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('历史记录'),
      ),
      body: ListView.builder(
          itemCount: list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return list[index];
          }),
    );
  }
}

class HistoryListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String chapterName;
  final int date;
  String formatDate = '';
  final String comicId;

  HistoryListTile(
      this.cover, this.title, this.chapterName, this.date, this.comicId) {
    formatDate = ToolMethods.formatTimestamp(date);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ComicDetailPage(comicId);
        }));
      },
      child: Card(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: '$cover',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
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
                        '$title',
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
                              Icons.details,
                              color: Colors.grey[500],
                            ),
                            Text(
                              '$chapterName',
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
                              '$formatDate',
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
