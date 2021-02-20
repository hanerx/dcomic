
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/view/settings/about_setting_page.dart';
import 'package:flutterdmzj/view/settings/debug_setting_page.dart';
import 'package:flutterdmzj/view/settings/download_setting_page.dart';
import 'package:flutterdmzj/view/settings/lab_setting_page.dart';
import 'package:flutterdmzj/view/settings/reader_setting_page.dart';
import 'package:flutterdmzj/view/settings/source_setting_page.dart';
import 'package:flutterdmzj/view/settings/user_setting_page.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';

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
    List<Widget> list=[
      ListTile(
        leading: Icon(Icons.book),
        title: Text(S.of(context).SettingPageMainReadingTitle),
        subtitle: Text(S.of(context).SettingPageMainReadingSubtitle),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ReaderSettingPage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.cloud),
        title: Text(S.of(context).SettingPageMainSourceTitle),
        subtitle: Text(S.of(context).SettingPageMainSourceSubtitle),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SourceSettingPage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.file_download),
        title: Text(S.of(context).SettingPageMainDownloadTitle),
        subtitle: Text(S.of(context).SettingPageMainDownloadSubtitle),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DownloadSettingPage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.account_box),
        title: Text(S.of(context).SettingPageMainUserTitle),
        subtitle: Text(S.of(context).SettingPageMainUserSubtitle),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserSettingPage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.developer_mode),
        title: Text(S.of(context).SettingPageMainDebugTitle),
        subtitle: Text(S.of(context).SettingPageMainDebugSubtitle),
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => DebugSettingPage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.apps),
        title: Text(S.of(context).SettingPageMainAboutTitle),
        subtitle: Text(S.of(context).SettingPageMainAboutSubtitle),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AboutSettingPage()));
        },
      ),
    ];
    if(Provider.of<SystemSettingModel>(context,listen: false).labState){
      list.add(ListTile(
        leading: Icon(FontAwesome5.flask),
        title: Text(S.of(context).SettingPageMainLabTitle),
        subtitle: Text(S.of(context).SettingPageMainLabSubtitle),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LabSettingPage()));
        },
      ));
    }
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).Setting),
      ),
      body: ListView(
        children: list,
      ),
    );
  }
}
