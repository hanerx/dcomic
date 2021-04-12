import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:provider/provider.dart';

class ComicSourcePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicSourcePage();
  }
}

class _ComicSourcePage extends State<ComicSourcePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).SettingPageSourcePageSourceTitle),
      ),
      body: EasyRefresh(
          child: ListView.builder(
        itemBuilder: Provider.of<SourceProvider>(context).getSourceConfigWidget,
        itemCount: Provider.of<SourceProvider>(context).sources.length,
      )),
    );
  }
}
