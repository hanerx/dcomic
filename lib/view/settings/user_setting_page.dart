import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/generated/l10n.dart';

class UserSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UserSettingPage();
  }
}

class _UserSettingPage extends State<UserSettingPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).SettingPageMainUserTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(S.of(context).SettingPageLogoutTitle),
            subtitle: Text(S.of(context).SettingPageLogoutSubtitle),
            onTap: () {
              DataBase dataBase = DataBase();
              dataBase.setLoginState(false).then(() {
                Navigator.of(context).pop();
              });
            },
          )
        ],
      ),
    );
  }
}
