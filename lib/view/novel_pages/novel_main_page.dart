import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/hanerx/AndroidStudioProjects/flutter_dmzj/lib/component/search/SearchButton.dart';
import 'package:flutterdmzj/view/category_page.dart';
import 'package:flutterdmzj/view/novel_pages/novel_home_page.dart';
import 'package:flutterdmzj/view/novel_pages/novel_latest_update_page.dart';
import 'package:flutterdmzj/view/novel_pages/novel_ranking_page.dart';

class NovelMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelMainPage();
  }
}

class _NovelMainPage extends State<NovelMainPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('轻小说站'),
          actions: [
            SearchButton()
          ],
          bottom: TabBar(tabs: [
            Tab(
              text: '主页',
            ),
            Tab(
              text: '分类',
            ),
            Tab(
              text: '排行',
            ),
            Tab(
              text: '最新',
            )
          ]),
        ),
        body: TabBarView(
          children: [
            NovelHomePage(),
            CategoryPage(type: 1,),
            NovelRankingPage(),
            NovelLatestUpdatePage(),
          ],
        ),
      ),
    );
  }
}
