import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/view/favorite_page.dart';
import 'package:flutterdmzj/view/login_page.dart';

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
        nickname = '加载中';
      });
      getAccountInfo();
    }
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
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('$nickname'),
            accountEmail: Text(
              'dmzj',
              style: TextStyle(color: Colors.white60),
            ),
            currentAccountPicture: CachedNetworkImage(
              imageUrl: '$avatar',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            otherAccountsPictures: <Widget>[
              FlatButton(
                child: Icon(
                  login ? Icons.exit_to_app : Icons.group_add,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (login) {
                    setState(() {
                      login = false;
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
            title: Text('我的订阅'),
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
            title: Text('历史记录'),
            leading: Icon(Icons.history),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed("history");
            },
          ),
          Divider(color: Colors.grey[700]),
          ListTile(
            title: Text('设置'),
            leading: Icon(Icons.settings),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed("settings");
            },
          )
        ],
      ),
    );
  }
}
