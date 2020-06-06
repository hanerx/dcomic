import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterdmzj/component/drawer.dart';
import 'package:flutterdmzj/view/category_page.dart';
import 'package:flutterdmzj/view/download_page.dart';
import 'package:flutterdmzj/view/history_page.dart';
import 'package:flutterdmzj/view/home_page.dart';
import 'package:flutterdmzj/view/login_page.dart';
import 'package:flutterdmzj/view/ranking_page.dart';
import 'package:flutterdmzj/view/search_page.dart';
import 'package:flutterdmzj/view/setting_page.dart';

void main() async {
  runApp(MainFrame());
}

class MainFrame extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    // TODO: implement build
    return new MaterialApp(
        routes: {
          "history": (BuildContext context) => new HistoryPage(),
          "download": (BuildContext context) => new DownloadPage(),
          "settings": (BuildContext context) => new SettingPage(),
          "login": (BuildContext context) => new LoginPage()
        },
        color: Colors.grey[400],
        showSemanticsDebugger: false,
        showPerformanceOverlay: false,
        home: DefaultTabController(
          length: 3,
          child: new Scaffold(
              appBar: new AppBar(
                title: Text('DMZJ'),
                actions: <Widget>[SearchButton()],
                bottom: TabBar(
                  tabs: <Widget>[
                    new Tab(
                      text: '首页',
                    ),
                    new Tab(
                      text: '分类',
                    ),
                    new Tab(
                      text: '排行',
                    )
                  ],
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  new HomePage(),
                  CategoryPage(),
                  RankingPage()
                ],
              ),
              drawer: CustomDrawer()),
        ));
  }
}

class SearchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
      child: Icon(
        Icons.search,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SearchPage();
        }));
      },
    );
  }
}
