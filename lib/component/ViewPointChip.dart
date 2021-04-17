import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewPointChip extends StatelessWidget {
  final String content;
  final String id;
  final int num;

  ViewPointChip({this.content, this.id, this.num});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.all(3),
      child: TextButton(
        child: Chip(
            label: Text('$content'),
            avatar: CircleAvatar(
              child: Text('${num % 100}'),
              backgroundColor: Colors.blue[
              num ~/ 100 * 100 + 400 > 800 ? 800 : num ~/ 100 * 100 + 400],
              foregroundColor: Colors.white,
            )),
        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
        onPressed: () {},
      ),
    );
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    // TODO: implement toString
    return '{content: $content, id: $id, num: $num, color: ${num ~/ 100 * 100 + 400}}';
  }
}
