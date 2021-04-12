import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/database/database.dart';
import 'package:dcomic/database/databaseCommon.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/view/database_detail_page.dart';
import 'package:dcomic/view/settings/debug_test_page.dart';
import 'package:logger_flutter/logger_flutter.dart';



class DebugSettingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DebugSettingPage();
  }

}
class _DebugSettingPage extends State<DebugSettingPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).SettingPageMainDebugTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(S.of(context).SettingPageDebugTestTitle),
            subtitle: Text(S.of(context).SettingPageDebugTestSubtitle),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DebugTestPage()));
            },
          ),
          Divider(),
          ListTile(
            title: Text(S.of(context).SettingPageDatabaseDetailTitle),
            subtitle: Text(S.of(context).SettingPageDatabaseDetailSubtitle),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DatabaseDetailPage()));
            },
          ),
          ListTile(
            title: Text(S.of(context).SettingPageResetDatabaseTitle),
            subtitle: Text(S.of(context).SettingPageResetDatabaseSubtitle),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                          S.of(context).SettingPageResetDatabaseConfirmTitle),
                      content: Text(S
                          .of(context)
                          .SettingPageResetDatabaseConfirmDescription),
                      actions: [
                        FlatButton(
                          child: Text(S.of(context).Cancel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).Confirm),
                          onPressed: () {
                            DatabaseCommon.resetDataBase();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
            },
          ),
          Divider(),
          ListTile(
            title: Text(S.of(context).SettingPageResetDioCacheTitle),
            subtitle: Text(S.of(context).SettingPageResetDioCacheSubtitle),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                          S.of(context).SettingPageResetDioCacheConfirmTitle),
                      content: Text(S
                          .of(context)
                          .SettingPageResetDioCacheConfirmDescription),
                      actions: [
                        FlatButton(
                          child: Text(S.of(context).Cancel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).Confirm),
                          onPressed: () {
                            CustomHttp().clearCache();
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
            },
          ),


          Divider(),
          ListTile(
            title: Text(S.of(context).SettingPageLogConsoleTitle),
            subtitle: Text(S.of(context).SettingPageLogConsoleSubtitle),
            onTap: () {
              LogConsole.open(context);
            },
          ),
        ],
      ),
    );
  }

}