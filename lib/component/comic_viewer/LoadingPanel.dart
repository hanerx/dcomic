import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/utils/static_language.dart';

class LoadingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 100,
      child: Row(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10), child: CircularProgressIndicator()),
          Expanded(
            child: Center(
              child: Text(StaticLanguage.staticStrings['loadingRow.loading']),
            ),
          )
        ],
      ),
    );
  }
}
