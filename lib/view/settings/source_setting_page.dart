import 'package:dcomic/view/comic_source/comic_source_provider_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/view/comic_source/comic_source_page.dart';

class SourceSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SourceSettingPage();
  }
}

class _SourceSettingPage extends State<SourceSettingPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).SettingPageMainSourceTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(S.of(context).SettingPageSourcePageSourceTitle),
            subtitle: Text(S.of(context).SettingPageSourcePageSourceSubtitle),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ComicSourcePage(),
                  settings: RouteSettings(name: 'comic_source_page')));
            },
          ),
          ListTile(
            title: Text(S.of(context).SettingPageSourcePageSourceProviderTitle),
            subtitle:
                Text(S.of(context).SettingPageSourcePageSourceProviderSubtitle),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ComicSourceProviderPage(),
                  settings: RouteSettings(name: 'comic_source_provider_page')));
            },
          ),
        ],
      ),
    );
  }
}
