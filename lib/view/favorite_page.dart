import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/view/favorite/comic_favorite_page.dart';
import 'package:flutterdmzj/view/favorite/novel_favorite_page.dart';
import 'package:markdown_widget/markdown_helper.dart';

class FavoritePage extends StatefulWidget {
  final String uid;

  FavoritePage(this.uid);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FavoritePage();
  }
}

class _FavoritePage extends State<FavoritePage> {
  bool novel = false;

  _FavoritePage();

  getNovel() async {
    DataBase dataBase = DataBase();
    bool state = await dataBase.getNovelState();
    setState(() {
      novel = state;
    });
  }

  @override
  initState() {
    super.initState();
    getNovel();
  }

//  @override
//  void deactivate() {
//    super.deactivate();
//    var bool = ModalRoute.of(context).isCurrent;
//    if (bool) {
//      Future.delayed(Duration(milliseconds: 200)).then((e) {
//        if (mounted) {
//          setState(() {
//            page = 0;
//            refreshState = true;
//          });
//          getSubscribe();
//        }
//      });
//    }
//  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      Tab(
        text: '漫画',
      )
    ];
    List<Widget> list = [
      ComicFavoritePage(
        uid: widget.uid,
      )
    ];
    if (novel) {
      tabs.add(Tab(
        text: '轻小说',
      ));
      list.add(NovelFavoritePage(
        uid: widget.uid,
      ));
    }
    // TODO: implement build
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('我的订阅'),
          bottom: TabBar(
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          children: list,
        ),
      ),
    );
  }
}
