import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterdmzj/component/drawer.dart';
import 'package:flutterdmzj/view/category_page.dart';
import 'package:flutterdmzj/view/dark_side_page.dart';
import 'package:flutterdmzj/view/download_page.dart';
import 'package:flutterdmzj/view/history_page.dart';
import 'package:flutterdmzj/view/home_page.dart';
import 'package:flutterdmzj/view/latest_update_page.dart';
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
          length: 4,
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
                    ),
                    new Tab(
                      text: '最新',
                    )
                  ],
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  new HomePage(),
                  CategoryPage(),
                  RankingPage(),
                  LatestUpdatePage(),
                ],
              ),
              drawer: CustomDrawer()),
        ));
  }
}

class SearchButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchButton();
  }
}

class _SearchButton extends State<SearchButton> {
  int _count = 0;

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
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text('小彩蛋~'),
                children: <Widget>[
                  SimpleDialogOption(
                    child: Text('我们耕耘黑暗，却守护光明'),
                    onPressed: () {
                      if (_count > 10) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return DarkSidePage();
                        }));
                      } else {
                        setState(() {
                          _count++;
                        });
                      }
                    },
                  )
                ],
              );
            });
      },
    );
  }
}
