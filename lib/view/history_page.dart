import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/HistoryListTile.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/view/login_page.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('历史记录'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text:'云端记录'),
              Tab(text: '本地记录',)
            ],
          ),
        ),
        body:TabBarView(
          children: <Widget>[
            RefreshIndicator(
              child: ListView.builder(
                  itemCount: list.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return list[index];
                  }),
              onRefresh: ()async{
                setState(() {
                  list.clear();
                });
                await getHistory();
                return;
              },
            ),
            ListView(
              children: <Widget>[
                Center(child: Text('没写完~'),)
              ],
            )
          ],
        ),
      ),
    );
  }
}

