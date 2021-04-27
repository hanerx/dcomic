import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/model/systemSettingModel.dart';
import 'package:dcomic/view/favorite/comic_favorite_page.dart';
import 'package:dcomic/view/favorite/novel_favorite_page.dart';
import 'package:dcomic/view/favorite/tracker_favorite_page.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatefulWidget {
  FavoritePage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FavoritePage();
  }
}

class _FavoritePage extends State<FavoritePage> {
  _FavoritePage();

  @override
  initState() {
    super.initState();
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
    List<Widget> tabs = Provider.of<SourceProvider>(context, listen: false)
        .favoriteSources
        .map<Widget>((e) => Tab(
              text: e.type.title,
            ))
        .toList();
    List<Widget> list = Provider.of<SourceProvider>(context, listen: false)
        .favoriteSources
        .map<Widget>((e) => ComicFavoritePage(
              model: e,
            ))
        .toList();

    if (Provider.of<SystemSettingModel>(context, listen: false).blackBox) {
      tabs.add(Tab(
        text: '黑匣子',
      ));
      list.add(TrackerFavoritePage());
    }
    // if (Provider.of<SystemSettingModel>(context, listen: false).novel) {
    //   tabs.add(Tab(
    //     text: '轻小说',
    //   ));
    //   list.add(NovelFavoritePage(
    //       uid: Provider.of<SourceProvider>(context)
    //           .activeSources
    //           .first
    //           .userConfig
    //           .userId));
    // }

    // TODO: implement build
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('我的订阅'),
          bottom: TabBar(
            isScrollable: true,
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
