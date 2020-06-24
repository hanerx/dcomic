import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterdmzj/component/Drawer.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/utils/static_language.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
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
import 'package:markdown_widget/markdown_widget.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'http/http.dart';

void main() async {
  runApp(MainFrame());
}

class MainFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    debugPaintSizeEnabled = true;
    debugPaintSizeEnabled = false;
    // TODO: implement build
    return new MaterialApp(
        darkTheme: ThemeData(
          brightness: Brightness.dark,
            platform: TargetPlatform.iOS,
          floatingActionButtonTheme:FloatingActionButtonThemeData(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.black
          )
        ),
        routes: {
          "history": (BuildContext context) => new HistoryPage(),
          "settings": (BuildContext context) => new SettingPage(),
          "login": (BuildContext context) => new LoginPage()
        },
        color: Colors.grey[400],
        showSemanticsDebugger: false,
        showPerformanceOverlay: false,
        theme: ThemeData(
          platform: TargetPlatform.iOS,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.blue
          )
        ),
        home: MainPage());
  }
}

class MainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainPage();
  }

}

class _MainPage extends State<MainPage>{

  String version;

  getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      if(ToolMethods.checkVersion(version, packageInfo.version)){
        version=packageInfo.version;
      }
    });
  }

  _openWeb(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('${StaticLanguage.staticStrings['settingPage.canNotOpenWeb']}'),
      ));
    }
  }

  checkUpdate()async{
    DataBase dataBase=DataBase();
    version=await dataBase.getVersion();
    await getVersionInfo();
    CustomHttp http = CustomHttp();
    var response = await http.checkUpdate();
    if (response.statusCode == 200) {
      String lastVersion = response.data['tag_name'].substring(1);
      if(version==''){
        dataBase.setVersion(lastVersion);
        return;
      }
      bool update = ToolMethods.checkVersion(version, lastVersion);
      if (update) {
        dataBase.setVersion(lastVersion);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title:
                Text('版本点亮：${response.data['tag_name']}'),
                content: Container(
                  width: 300,
                  height: 300,
                  child: MarkdownWidget(data: response.data['body']),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('更新'),
                    onPressed: () {
                      _openWeb('${response.data['html_url']}');
                    },
                  ),
                  FlatButton(
                    child: Text('取消'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
      print('check update success');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUpdate();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 4,
      child: new Scaffold(
          appBar: new AppBar(
            title: Text('大妈之家(?)'),
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
    );
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
