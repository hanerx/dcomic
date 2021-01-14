import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/utils/static_language.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LabSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LabSettingPage();
  }
}

class _LabSettingPage extends State<LabSettingPage> {
  bool search = false;
  bool darkSide = false;
  bool novel = false;

  _openWeb(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
            '${StaticLanguage.staticStrings['settingPage.canNotOpenWeb']}'),
      ));
    }
  }

  getDeepSearch() async {
    DataBase dataBase = DataBase();
    bool state = await dataBase.getDeepSearch();
    setState(() {
      search = state;
    });
  }

  setDeepSearch() {
    DataBase dataBase = DataBase();
    dataBase.setDeepSearch(search);
  }

  getDarkSide() async {
    DataBase dataBase = DataBase();
    bool state = await dataBase.getDarkSide();
    setState(() {
      darkSide = state;
    });
  }

  setDarkSide() {
    DataBase dataBase = DataBase();
    dataBase.setDarkSide(darkSide);
  }

  setNovel() {
    DataBase dataBase = DataBase();
    dataBase.setNovelState(novel);
  }

  getNovel() async {
    DataBase dataBase = DataBase();
    bool state = await dataBase.getNovelState();
    setState(() {
      novel = state;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeepSearch();
    getDarkSide();
    getNovel();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('实验功能'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('隐藏漫画搜索功能'),
            subtitle: Text(
                '通过调用奇葩的接口实现把一部分隐藏的漫画显示出来，该功能会讲搜索变成两部分，一部分使用普通搜索，另一部分使用隐藏搜索'),
            trailing: Switch(
              onChanged: (val) {
                setState(() {
                  search = val;
                });
                setDeepSearch();
              },
              value: search,
            ),
            onTap: () {
              setState(() {
                search = !search;
              });
              setDeepSearch();
            },
          ),
          // ListTile(
          //   title: Text('备用API'),
          //   subtitle: Text('通过另一个奇葩接口实现之前API无法返回的东西'),
          //   trailing: Switch(
          //     value: Provider.of<SystemSettingModel>(context).backupApi,
          //     onChanged: (val) {
          //       Provider.of<SystemSettingModel>(context,listen: false).backupApi = val;
          //     },
          //   ),
          //   onTap: (){
          //     Provider.of<SystemSettingModel>(context,listen: false).backupApi = !Provider.of<SystemSettingModel>(context,listen: false).backupApi;
          //   },
          // ),
          ListTile(
            title: Text('黑匣子'),
            subtitle: Text('在本地记录漫画id，方便想看的时候直接找，适用于在订阅里消失的漫画'),
            onTap: () {
              Provider.of<SystemSettingModel>(context, listen: false).blackBox =
                  !Provider.of<SystemSettingModel>(context, listen: false)
                      .blackBox;
            },
            trailing: Switch(
              value: Provider.of<SystemSettingModel>(context).blackBox,
              onChanged: (bool value) {
                Provider.of<SystemSettingModel>(context, listen: false)
                    .blackBox = value;
              },
            ),
          ),
          ListTile(
            enabled: false,
            title: Text('章节保存(未实现)'),
            subtitle: Text('每次都保存漫画的章节详情，如果漫画被删除可以通过该功能尝试恢复漫画'),
          ),
          ListTile(
            enabled: false,
            title: Text('第三方记录源(未实现)'),
            subtitle: Text('以后可能会实现第三方的记录源，让部分漫画能通过第三方重新可以浏览，不过话说我这个应该算第几方了'),
          ),
          ListTile(
            title: Text('黑暗面'),
            subtitle: Text.rich(TextSpan(children: [
              TextSpan(text: '这个是通过GitHub上一位大佬的接口实现的影藏漫画查看功能，地址：'),
              TextSpan(
                  text: 'https://github.com/torta/dark-dmzj',
                  style: TextStyle(color: Theme.of(context).accentColor)),
              TextSpan(text: ' 长按跳转至项目')
            ])),
            trailing: Switch(
              value: darkSide,
              onChanged: (bool value) {
                setState(() {
                  darkSide = value;
                });
                setDarkSide();
              },
            ),
            onLongPress: () {
              _openWeb('https://github.com/torta/dark-dmzj');
            },
            onTap: () {
              setState(() {
                darkSide = !darkSide;
              });
              setDarkSide();
            },
          ),
          Divider(),
          ListTile(
            title: Text('小说功能'),
            subtitle: Text('欸，我还真把卫星放下来了'),
            trailing: Switch(
              value: novel,
              onChanged: (value) {
                setState(() {
                  novel = value;
                });
                setNovel();
              },
            ),
            onTap: () {
              setState(() {
                novel = !novel;
              });
              setNovel();
            },
          )
        ],
      ),
    );
  }
}
