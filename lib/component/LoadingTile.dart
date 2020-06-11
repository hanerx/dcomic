import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/utils/static_language.dart';

class LoadingTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      leading: CircularProgressIndicator(),
      title: Text(StaticLanguage.staticStrings['loadingRow.loading']),
    );
  }
}
