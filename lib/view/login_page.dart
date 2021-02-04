import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  _login(context) async {
    EasyLoading.instance..indicatorType = EasyLoadingIndicatorType.fadingCube;
    EasyLoading.instance..maskType = EasyLoadingMaskType.black;
    EasyLoading.show(status: "登录中");
    try {
      CustomHttp http = CustomHttp();
      var response =
          await http.login(_usernameController.text, _passwordController.text);
      var responseData = response.data.toString();
      var data = jsonDecode(responseData.substring(1, responseData.length - 1));
      if (data['code'] == 1000) {
        DataBase dataBase = DataBase();
        for (var item in response.headers['set-cookie']) {
          var key = item.substring(0, item.indexOf("="));
          var value = item.substring(item.indexOf("=") + 1);
          await dataBase.insertCookies(key, value);
          if (key == 'my') {
            var detail = value.substring(0, value.indexOf(";"));
            var decodeDetail = Uri.decodeComponent(Uri.decodeComponent(detail));
            var list = decodeDetail.split("|");
            print(list);
            await dataBase.setUid(list[0]);
          }
        }
        await dataBase.setLoginState(true);
        EasyLoading.dismiss();
        Navigator.pop(context);
      } else if (data['code'] == 801 || data['code'] == 803) {
        EasyLoading.dismiss();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('用户名或密码错误！'),
        ));
      } else {
        EasyLoading.dismiss();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('俺也不知道啥错误，反正服务器说出问题了'),
        ));
      }
    } catch (e) {
      EasyLoading.dismiss();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('连接爆了，网炸了？'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlutterEasyLoading(
        child: Scaffold(
      appBar: AppBar(
        title: Text('登录'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text('说明'),
                      children: <Widget>[
                        SimpleDialogOption(
                          child: Text(
                              '本程序为第三方程序，登录采用调用动漫之家官方的接口实现。本程序承诺除保存登录凭证外不会收集任何数据信息，同时不会将您的信息透露给任何第三方机构。由于本程序并未获得动漫之家官方授权，您的账号使用本程序登录可能造成不可预见的风险，您使用本程序登录即代表您了解并同意承担本程序可能带来的风险。'),
                        )
                      ],
                    );
                  });
            },
          )
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://static.dmzj.com/public/images/logo-new.png',
                  httpHeaders: {'referer': 'http://images.dmzj.com'},
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '用户名',
                      icon: Icon(Icons.account_circle),
                      helperText: '昵称/手机号/邮箱'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '密码',
                      icon: Icon(Icons.lock),
                      helperText: '动漫之家登录密码'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '*本程序为第三方登录程序，存在登录风险',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        return RaisedButton(

                          child: Text(
                            '登录',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _login(context);
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          FontAwesome5.qq,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          EasyLoading.instance
                            ..indicatorType =
                                EasyLoadingIndicatorType.fadingCube;
                          EasyLoading.instance
                            ..maskType = EasyLoadingMaskType.black;
                          EasyLoading.show(status: "登录中");
                          FlutterWebviewPlugin webview = FlutterWebviewPlugin();
                          var state = false;
                          webview.onUrlChanged.listen((String url) {
                            print(url);
//                            if (url.indexOf("wtloginmqq://") != -1) {
//                              print("尝试拉起：$url");
//                              _openWeb(url);
//                            }
                            if (url == 'https://m.dmzj.com/') {
                              print(true);
                              webview
                                  .evalJavascript("document.cookie")
                                  .then((value) async {
                                if (!state) {
                                  try {
                                    state = true;
                                    print(value);
                                    webview.close();
                                    DataBase dataBase = DataBase();
                                    var data = value
                                        .replaceAll(" ", "")
                                        .replaceAll("\"", "")
                                        .split(';');
                                    print(data);
                                    for (var item in data) {
                                      var key =
                                          item.substring(0, item.indexOf("="));
                                      var value =
                                          item.substring(item.indexOf("=") + 1);
                                      await dataBase.insertCookies(key, value);
                                      if (key == 'my') {
                                        var decodeDetail = Uri.decodeComponent(
                                            Uri.decodeComponent(value));
                                        var list = decodeDetail.split("|");
                                        print(list);
                                        await dataBase.setUid(list[0]);
                                      }
                                    }
                                    await dataBase.setLoginState(true);
                                    Navigator.pop(context);
                                  } catch (e) {
                                    print(e);
                                    Navigator.pop(context);
                                  }
                                }
                              });
                            }
                          });
                          webview.onBack.listen((url) async {
                            if (!await webview.canGoBack()) {
                              webview.close();
                              Navigator.pop(context);
                              EasyLoading.dismiss();
                            }
                          });
                          webview.launch(
                              'https://graph.qq.com/oauth2.0/authorize?client_id=101144087&display=pc&redirect_uri=https://i.dmzj.com/login/qq&response_type=code&state=http://m.dmzj.com/',
                            userAgent: 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36'
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
