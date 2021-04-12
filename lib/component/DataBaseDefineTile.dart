import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/database/databaseCommon.dart';

class DatabaseDefineTile extends StatelessWidget {
  final DatabaseStaticModel model;
  final String table;

  const DatabaseDefineTile({Key key, this.model, this.table}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      dense: true,
      title: Text.rich(TextSpan(children: [
        TextSpan(text: '$table', style: TextStyle(fontSize: 20)),
        TextSpan(text: ' '),
        TextSpan(
            text: '最后更新版本：${model.version}',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: ListTileTheme.of(context).textColor))
      ])),
      subtitle: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: model.tables.keys
                .map<Widget>((e) => ListTile(
                      dense: true,
                      title: Text('$e',style: TextStyle(color: Theme.of(context).textSelectionColor),),
                      subtitle: Text('${model.tables[e]}'),
                    ))
                .toList() +
            <Widget>[Divider()],
      ),
    );
  }
}
