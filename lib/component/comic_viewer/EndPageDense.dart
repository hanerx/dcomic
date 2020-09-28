import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EndPageDense extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 100,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text("没有更多信息了~"),
            ),
          )
        ],
      ),
    );
  }

}