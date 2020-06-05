import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SettingPage();
  }
}

class _SettingPage extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('设置'),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: Text('清除数据库内容'),
              subtitle:
                  Text('危险操作，包括登录信息，漫画记录均会被删除，仅用于出现bug后的补救功能(也许会造成更大的bug？)'),
              onTap: () {
                DataBase dataBase = DataBase();
                dataBase.resetDataBase();
                Navigator.of(context).pop();
              },
            ),
            Divider(),
            ListTile(
              title: Text('免责声明'),
              subtitle: Text('不管有没有，先写了再说'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text('免责声明'),
                        children: <Widget>[
                          SimpleDialogOption(
                            child: Text(
                                '1. 本程序为第三方APP，所有程序内容由动漫之家提供，本程序不保证内容安全性和可靠性。'),
                          ),
                          SimpleDialogOption(
                            child: Text(
                                '2. 本程序的所有接口均为官方APP抓包获取，本程序承诺不受集任何内容交予任何第三方机构。'),
                          ),
                          SimpleDialogOption(
                            child: Text(
                                '3. 本程序的登录功能并非官方登录功能，是抓取的官方接口实现，您使用本程序登录功能即代表您了解并愿意承担由于使用本程序登录造成的风险。'),
                          )
                        ],
                      );
                    });
              },
            ),
            ListTile(
              title: Text('常见问题'),
              subtitle: Text('?'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text('FAQ'),
                        children: <Widget>[
                          ListTile(
                            title: Text('Q:为啥会有这个东西？'),
                            subtitle: Text('A:因为bug有点多，代码有点乱，我还修不了~'),
                          ),
                          ListTile(
                            title: Text('Q:图标好丑啊。'),
                            subtitle: Text('A:在？那你能帮帮我吗？'),
                          ),
                          ListTile(
                            title: Text('Q:为啥和官方的比起来缺了那么多功能？'),
                            subtitle: Text('A:简单APP!简单APP!!(写个完整的头发都要掉光了'),
                          ),
                          ListTile(
                            title: Text('Q:那些功能会不会在后续更新里加上？'),
                            subtitle: Text('A:也许？(要不爽哥结婚的时候再说？)'),
                          ),
                          ListTile(
                            title: Text('Q:有没有iOS版'),
                            subtitle: Text('A:苹果那是人开发的东西吗？99美刀呢，感觉这应用卖了也不值这个价，而且第三方APP有法律风险的('),
                          ),
                          ListTile(
                            title: Text('Q:用户名密码是什么？'),
                            subtitle: Text(
                                'A:你大妈之家用户名密码是啥就是啥，没做第三方登录，大妈之家的接口爬起来太恶心了。'),
                          ),
                          ListTile(
                            title: Text('Q:有没有下载功能？'),
                            subtitle: Text(
                                'A:下载功能。。。原本想做的，但是因为大妈之家的图片加载你懂的，我用了带缓存的图片插件，速度是快起来了，但是没法写下载了，flutter又没有原生的，估计实现还得找插件(头发要紧，头发要紧)'),
                          ),
                          ListTile(
                            title: Text('Q:我软件特别卡怎么办？'),
                            subtitle: Text(
                                'A:也不知道为啥，大妈之家的接口用起来就是卡卡的，我已经用了带缓存的请求插件了，理论上应该会越用越顺畅？'),
                          ),
                          ListTile(
                            title: Text('Q:内容看不见怎么办？'),
                            subtitle: Text(
                                'A:这个真不好说，有的是因为网卡等等就加载出来了，有的不知道为啥就是尬住了，重进就好了，还有的由于各位众所周知的问题是本来就没有内容的('),
                          ),
                          ListTile(
                            title: Text('Q:开发的初衷是啥？'),
                            subtitle: Text('A:大妈之家官方的APP有点卡，没想到自己的也好卡，现在感觉是服务器问题？'),
                          ),

                          ListTile(
                            title: Text('Q:源代码怎么这么丑？'),
                            subtitle: Text(
                                'A:哦豁，你看源代码啦。小伙子，有没有兴趣来提交一个Pull request？(你以为我是菜，其实是吃人陷阱，这波我在第五层)'),
                          ),
                        ],
                      );
                    });
              },
            ),
            ListTile(
              title: Text('关于'),
              subtitle: Text('想不到设置里面能塞啥'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AboutDialog(
                        applicationName: '大妈之家(?)',
                        applicationVersion: 'v1.0.0',
                        applicationIcon: Icon(Icons.adb),
                        children: <Widget>[
                          Text('基于flutter的第三方动漫之家简单app'),
                        ],
                      );
                    });
              },
            ),
            Divider(),
            ListTile(
              title: Text('退出'),
              subtitle: Text('其实你点外面的退出一样的'),
              onTap: () {
                DataBase dataBase = DataBase();
                dataBase.setLoginState(false).then(() {
                  Navigator.of(context).pop();
                });
              },
            )
          ],
        ));
  }
}
