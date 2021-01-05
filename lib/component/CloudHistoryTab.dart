import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/view/login_page.dart';

import 'HistoryListTile.dart';

class CloudHistoryTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CloudHistoryTab();
  }

}

class _CloudHistoryTab extends State<CloudHistoryTab> {
  String uid = '';
  int page = 0;
  List list = <Widget>[];
  bool login=false;

  @override
  void deactivate() {
    super.deactivate();
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        initLoginState();
      });
    }
  }

  initLoginState() async {
    DataBase dataBase = DataBase();
    var login = await dataBase.getLoginState();
    if (login) {
      uid = await dataBase.getUid();
      getHistory();
      if(mounted){
        setState(() {
          this.login=login;
          list.clear();
        });
      }
    } else {
      if(mounted){
        setState(() {
          list.add(Center(
            child: Container(
              margin: EdgeInsets.only(top: 30),
              child: Column(
                children: <Widget>[
                  Text('请先登录才能看云端记录'),
                  FlatButton(child: Text('点击登录',style: TextStyle(color: Theme.of(context).accentColor),), onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return LoginPage();
                    }));
                  },)
                ],),
            ),
          ));
        });
      }
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
    return EasyRefresh(
      scrollController: ScrollController(),
      child: ListView.builder(
          itemCount: list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return list[index];
          }),
      onRefresh: () async {
        if(login){
          setState(() {
            list.clear();
          });
          await getHistory();
        }
        return;
      },
      header: ClassicalHeader(
          refreshedText: '刷新完成',
          refreshFailedText: '刷新失败',
          refreshingText: '刷新中',
          refreshText: '下拉刷新',
          refreshReadyText: '释放刷新'),
    );
  }

}