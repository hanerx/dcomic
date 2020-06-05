import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';

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

  _login() async {
    CustomHttp http = CustomHttp();
    var response =
        await http.login(_usernameController.text, _passwordController.text);
    var responseData = response.data.toString();
    var data = jsonDecode(responseData.substring(1, responseData.length - 1));
    if (data['code'] == 1000) {
      DataBase dataBase = DataBase();
      for (var item in response.headers['set-cookie']) {
        var key = item.substring(0, item.indexOf("="));
        var value = item.substring(item.indexOf("=")+1);
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

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
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
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '密码',
                        icon: Icon(Icons.text_fields),
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
                      RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          '登录',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _login();
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
