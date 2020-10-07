import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/utils/static_language.dart';
import 'package:flutterdmzj/view/dark_side_page.dart';
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
  bool darkSide=false;
  bool blackBox=false;

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

  getDarkSide() async{
    DataBase dataBase=DataBase();
    bool state=await dataBase.getDarkSide();
    setState(() {
      darkSide=state;
    });
  }

  getBlackBox() async{
    DataBase dataBase=DataBase();
    bool state=await dataBase.getBlackBox();
    setState(() {
      blackBox=state;
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
    getBlackBox();
  }

  @override
  Widget build(BuildContext context) {
    List list=buildList(context);
    // TODO: implement build
    return new Drawer(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: list.length,
        itemBuilder: (context,index){
          return list[index];
        },
      ),
    );
  }

  List<Widget> buildList(BuildContext context){
    List<Widget> list=<Widget>[
      UserAccountsDrawerHeader(
        accountName: Text('$nickname'),
        accountEmail: Text(
          StaticLanguage.staticStrings['drawer.email'],
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
            child: Icon(
              login ? Icons.exit_to_app : Icons.group_add,
              color: Colors.white,
            ),
            onPressed: () {
              if (login) {
                setState(() {
                  login = false;
                  nickname = StaticLanguage.staticStrings['drawer.pleaseLogin'];
                  avatar = 'https://avatar.dmzj.com/default.png';
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
        title: Text(StaticLanguage.staticStrings['favorite']),
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
        title: Text(StaticLanguage.staticStrings['history']),
        leading: Icon(Icons.history),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("history");
        },
      ),
      ListTile(
        title: Text("下载管理"),
        leading: Icon(Icons.file_download),
        onTap: (){
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("download");
        },
      )
    ];
    if(darkSide){
      list+=<Widget>[
        Divider(),
        ListTile(title: Text('黑暗面'),leading: Icon(Icons.block),onTap: (){
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return DarkSidePage();
          }));
        },)
      ];
    }
    if(blackBox){
      list+=<Widget>[
        Divider(),
        ListTile(
          title: Text('黑匣子'),
          leading: Icon(Icons.inbox),
          onTap: (){
            Navigator.of(context).pop();
          },
        )
      ];
    }
    list+=<Widget>[Divider(),
      ListTile(
        title: Text(StaticLanguage.staticStrings['settings']),
        leading: Icon(Icons.settings),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("settings");
        },
      )];
    return list;
  }
}
