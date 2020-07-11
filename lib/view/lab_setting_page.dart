import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/utils/static_language.dart';
import 'package:url_launcher/url_launcher.dart';

class LabSettingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LabSettingPage();
  }

}
class _LabSettingPage extends State<LabSettingPage>{
  bool search=false;
  bool darkSide=false;

  _openWeb(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('${StaticLanguage.staticStrings['settingPage.canNotOpenWeb']}'),
      ));
    }
  }

  getDeepSearch()async{
    DataBase dataBase=DataBase();
    bool state= await dataBase.getDeepSearch();
    setState(() {
      search=state;
    });
  }

  setDeepSearch(){
    DataBase dataBase=DataBase();
    dataBase.setDeepSearch(search);
  }

  getDarkSide() async{
    DataBase dataBase=DataBase();
    bool state=await dataBase.getDarkSide();
    setState(() {
      darkSide=state;
    });
  }

  setDarkSide(){
    DataBase dataBase=DataBase();
    dataBase.setDarkSide(darkSide);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeepSearch();
    getDarkSide();
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
            subtitle: Text('通过调用奇葩的接口实现把一部分隐藏的漫画显示出来，该功能会讲搜索变成两部分，一部分使用普通搜索，另一部分使用隐藏搜索'),
            trailing: Switch(
              onChanged: (val){
                setState(() {
                  search=val;
                });
                setDeepSearch();
              },
              value: search,
            ),
            onTap: (){
              setState(() {
                search=!search;
              });
              setDeepSearch();
            },
          ),
          ListTile(
            enabled: false,
            title: Text('漫画追踪(未实现)'),
            subtitle: Text('在程序开启时检查追踪的漫画是否更新，适用于关注中被影藏的漫画，但是需要手动选择追踪的漫画'),
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
            subtitle: Text.rich(TextSpan(
              children: [
                TextSpan(text: '这个是通过GitHub上一位大佬的接口实现的影藏漫画查看功能，地址：'),
                TextSpan(text: 'https://github.com/torta/dark-dmzj',style: TextStyle(color: Theme.of(context).accentColor)),
                TextSpan(text: ' 长按跳转至项目')
              ]
            )),
            trailing: Switch(
              value: darkSide,
              onChanged: (bool value) {
                setState(() {
                  darkSide=value;
                });
                setDarkSide();
              },
            ),
            onLongPress: (){
              _openWeb('https://github.com/torta/dark-dmzj');
            },
            onTap: (){
              setState(() {
                darkSide=!darkSide;
              });
              setDarkSide();
            },
          ),
          Divider(),
          ListTile(
            enabled: false,
            title: Text('小说功能(未实现)'),
            subtitle: Text('不是很想实现啊，因为毕竟是个漫画app，搞啥小说啊'),
          )
        ],
      ),
    );
  }
}