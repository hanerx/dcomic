
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/CloudHistoryTab.dart';
import 'package:flutterdmzj/component/LocalHistoryTab.dart';

class HistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HistoryPage();
  }
}

class _HistoryPage extends State<HistoryPage> {

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
            CloudHistoryTab(),
            LocalHistoryTab()
          ],
        ),
      ),
    );
  }
}

