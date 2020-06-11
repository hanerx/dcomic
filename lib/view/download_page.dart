import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@Deprecated('未实装页面')
class DownloadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DownloadPage();
  }
}
@Deprecated('未实装页面')
class _DownloadPage extends State<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('下载管理'),
      ),
      body: new Scrollbar(
          child: SingleChildScrollView(
        child: new Row(),
      )),
    );
  }
}
