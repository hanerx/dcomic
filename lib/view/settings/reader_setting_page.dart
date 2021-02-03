import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/generated/l10n.dart';

class ReaderSettingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ReaderSettingPage();
  }

}

class _ReaderSettingPage extends State<ReaderSettingPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).SettingPageMainReadingTitle),
      ),
      body: ListView(
        children: [

        ],
      ),
    );
  }

}