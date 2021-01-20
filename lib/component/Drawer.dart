import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/view/dark_side_page.dart';
import 'package:flutterdmzj/view/favorite_page.dart';
import 'package:flutterdmzj/view/login_page.dart';
import 'package:flutterdmzj/view/novel_pages/novel_main_page.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CustomDrawerState();
  }
}

class CustomDrawerState extends State<CustomDrawer> {
  bool login = false;
  String avatar = 'https://avatar.dmzj.com/default.png';
  String nickname = '请先登录';
  String uid = '';
  bool darkSide = false;
  bool novel = false;

  static const List darkMode=[
    Icons.brightness_4,
    Icons.brightness_5,
    Icons.brightness_2
  ];

  getAccountInfo() async {
    if (login) {
      DataBase dataBase = DataBase();
      uid = await dataBase.getUid();
      CustomHttp http = CustomHttp();
      var response = await http.getUserInfo(uid);
      if (response.statusCode == 200 && mounted) {
        setState(() {
          nickname = response.data['nickname'];
          avatar = response.data['cover'];
        });
      }
    }
  }

  getLoginState() async {
    DataBase dataBase = DataBase();
    var state = await dataBase.getLoginState();
    if (mounted) {
      setState(() {
        login = state;
        nickname = state ? '加载中' : '请先登录';
      });
      getAccountInfo();
    }
  }

  getDarkSide() async {
    DataBase dataBase = DataBase();
    bool state = await dataBase.getDarkSide();
    setState(() {
      darkSide = state;
    });
  }


  getNovel() async {
    DataBase dataBase = DataBase();
    bool state = await dataBase.getNovelState();
    setState(() {
      novel = state;
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        getLoginState();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoginState();
    getDarkSide();
    getNovel();
  }

  @override
  Widget build(BuildContext context) {
    List list = buildList(context);
    // TODO: implement build
    return new Drawer(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: list.length,
        itemBuilder: (context, index) {
          return list[index];
        },
      ),
    );
  }

  List<Widget> buildList(BuildContext context) {
    List<Widget> list = <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text('$nickname'),
        accountEmail: Text(
          S.of(context).DrawerEmail,
          style: TextStyle(color: Colors.white60),
        ),
        currentAccountPicture: CachedNetworkImage(
          imageUrl: '$avatar',
          httpHeaders: {'referer': 'http://images.dmzj.com'},
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => CachedNetworkImage(
            imageUrl: 'https://avatar.dmzj.com/default.png',
            httpHeaders: {'referer': 'http://images.dmzj.com'},
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => Center(
              child: Icon(Icons.warning),
            ),
          ),
        ),
        otherAccountsPictures: <Widget>[
          FlatButton(
            child: Icon(darkMode[Provider.of<SystemSettingModel>(context).darkState],color: Colors.white,),
            onPressed: (){
              if (Provider.of<SystemSettingModel>(context,listen: false).darkState < darkMode.length - 1) {
                Provider.of<SystemSettingModel>(context,listen: false).darkState++;
              } else {
                Provider.of<SystemSettingModel>(context,listen: false).darkState=0;
              }
            },
            shape: CircleBorder(),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          ),
          FlatButton(
            child: Icon(
              login ? Icons.exit_to_app : Icons.group_add,
              color: Colors.white,
            ),
            onPressed: () {
              if (login) {
                setState(() {
                  login = false;
                  nickname = S.of(context).DrawerPlsLogin;
                  avatar = S.of(context).DefaultAvatar;
                });
                DataBase dataBase = DataBase();
                dataBase.setLoginState(false);
              } else {
                Navigator.pushNamed(context, 'login');
              }
            },
            shape: CircleBorder(),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          )
        ],
      ),
      ListTile(
        title: Text(S.of(context).Favorite),
        leading: Icon(Icons.favorite),
        onTap: () {
          Navigator.of(context).pop();
          if (login && uid != '') {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FavoritePage(uid);
            }));
          } else if (!login) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return LoginPage();
            }));
          }
        },
      ),
      ListTile(
        title: Text(S.of(context).History),
        leading: Icon(Icons.history),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("history");
        },
      ),
      ListTile(
        title: Text(S.of(context).Download),
        leading: Icon(Icons.file_download),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("download");
        },
      )
    ];
    if (darkSide) {
      list += <Widget>[
        Divider(),
        ListTile(
          title: Text(S.of(context).DarkSide),
          leading: Icon(Icons.block),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return DarkSidePage();
            }));
          },
        )
      ];
    }
    if (novel) {
      list += <Widget>[
        Divider(),
        ListTile(
          title: Text(S.of(context).Novel),
          leading: Icon(Icons.book),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return NovelMainPage();
            }));
          },
        )
      ];
    }

    list += <Widget>[
      Divider(),
      ListTile(
        title: Text(S.of(context).Setting),
        leading: Icon(Icons.settings),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("settings");
        },
      )
    ];
    return list;
  }
}
