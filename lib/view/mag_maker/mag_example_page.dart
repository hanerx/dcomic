import 'dart:convert';

import 'package:code_editor/code_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:dcomic/component/CustomDrawer.dart';

class MagExamplePage extends StatelessWidget {
  final String example;

  const MagExamplePage({Key key, this.example}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('标准实例'),
      ),
      body: Builder(builder: (context)=>Container(
          child: CodeEditor(
            disableNavigationbar: true,
            model: EditorModel(
                styleOptions: EditorModelStyleOptions(heightOfContainer: MediaQuery.of(context).size.height-Scaffold.of(context).appBarMaxHeight),
                files: [
                  FileEditor(code: example, language: 'json', name: 'meta.json')
                ]),
            edit: false,
          )),
      ),
      endDrawer: CustomDrawer(
        widthPercent: 0.9,
        child: Scaffold(
          appBar: AppBar(
            title: Text('标准实例'),
          ),
          body: Builder(builder: (context) {
            try {
              return SingleChildScrollView(
                child: JsonViewerWidget(jsonDecode(example)),
              );
            } catch (e) {
              return Center(
                child: Text('你的json好像没写对啊，没法渲染啊'),
              );
            }
          }),
        ),
      ),
    );
  }
}
