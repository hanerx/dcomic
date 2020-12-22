import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NovelMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelMainPage();
  }
}

class _NovelMainPage extends State<NovelMainPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('轻小说站'),
      ),
      body: Center(
        child: Text('主页懒得写了，等我记起来再说'),
      ),
    );
  }
}
