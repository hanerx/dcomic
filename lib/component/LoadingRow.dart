import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: <Widget>[
        Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()),
        Expanded(
          child: Center(
            child: Text('加载中...'),
          ),
        )
      ],
    );
  }
}
