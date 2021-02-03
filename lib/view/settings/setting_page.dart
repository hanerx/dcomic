import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/model/versionModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/database_detail_page.dart';
import 'package:flutterdmzj/view/settings/debug_setting_page.dart';
import 'file:///C:/Users/hanerx/AndroidStudioProjects/flutter_dmzj/lib/view/settings/lab_setting_page.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart';

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
        title: Text(S.of(context).Setting),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.book),
            title: Text(S.of(context).SettingPageMainReadingTitle),
            subtitle: Text(S.of(context).SettingPageMainReadingSubtitle),
          ),
          ListTile(
            leading: Icon(Icons.cloud),
            title: Text(S.of(context).SettingPageMainSourceTitle),
            subtitle: Text(S.of(context).SettingPageMainSourceSubtitle),
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            title: Text(S.of(context).SettingPageMainUserTitle),
            subtitle: Text(S.of(context).SettingPageMainUserSubtitle),
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
          ),
        ],
      ),
    );
  }
}
