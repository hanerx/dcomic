import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewPointChip extends StatefulWidget {
  final String content;
  final String id;
  final int num;

  ViewPointChip({this.content, this.id, this.num});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ViewPointChip(content, id, num);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    // TODO: implement toString
    return '{content: $content, id: $id, num: $num, color: ${num ~/ 100 * 100 + 400}}';
  }
}

class _ViewPointChip extends State<ViewPointChip> {
  final String content;
  final String id;
  int num;

  _ViewPointChip(this.content, this.id, this.num);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.all(3),
      child: FlatButton(
        child: Chip(
            label: Text('$content'),
            avatar: CircleAvatar(
              child: Text('${num % 100}'),
              backgroundColor: Colors.blue[
                  num ~/ 100 * 100 + 400 > 800 ? 800 : num ~/ 100 * 100 + 400],
              foregroundColor: Colors.white,
            )),
        padding: EdgeInsets.all(0),
        onPressed: () {},
      ),
    );
  }
}
