import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/database/database.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:provider/provider.dart';

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
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Provider.of<SourceProvider>(context, listen: false)
              .activeSources[index]
              .userConfig
              .getSettingWidget(context);
        },
        itemCount: Provider.of<SourceProvider>(context).activeSources.length,
      ),
    );
  }
}
