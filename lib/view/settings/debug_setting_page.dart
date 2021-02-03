import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/generated/l10n.dart';

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
    );
  }

}