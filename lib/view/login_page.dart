import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/view/settings/user_setting_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:dcomic/database/database.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('选择登录账号'),
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserSettingPage(),
                    settings: RouteSettings(name: 'user_setting_page')));
              })
        ],
      ),
      body: ListView.builder(
        itemCount: Provider.of<SourceProvider>(context).activeSources.length,
        itemBuilder: (context, index) {
          BaseSourceModel model =
              Provider.of<SourceProvider>(context, listen: false)
                  .activeSources[index];
          return Card(
            child: ListTile(
              title: Text('${model.type.title}登录'),
              subtitle: Text('${model.type.description}'),
              enabled: model.userConfig.status == UserStatus.logout,
              trailing: Icon(model.userConfig.status == UserStatus.login
                  ? Icons.cloud_done
                  : model.userConfig.status == UserStatus.logout
                      ? Icons.cloud_off
                      : Icons.cancel),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        model.userConfig.getLoginWidget(context),
                    settings:
                        RouteSettings(name: '${model.type.name}_login_page')));
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }
}
