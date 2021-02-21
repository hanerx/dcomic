import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/http/UniversalRequestModel.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/comic_source/ManHuaGuiSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/MangabzSourceModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';

class DebugTestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DebugTestPage();
  }
}

class _DebugTestPage extends State<DebugTestPage> {
  String _data;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).SettingPageDebugTestTitle),
          bottom: TabBar(
            isScrollable: true,
              tabs: [
            Tab(
              text: 'mangabz漫画爬取',
            ),
            Tab(
              text: 'mangabz搜索爬取',
            ),
            Tab(
              text: 'mangabz漫画获取',
            ),
                Tab(text: '漫画台搜索爬取',)
          ]),
        ),
        body: TabBarView(children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: () async {
                      var response=await UniversalRequestModel().mangabzRequestHandler.getChapterImage('m161157', 0);
                      var data=await ToolMethods.eval(response.data.toString());
                      setState(() {
                        _data = '${response.data.toString()}\n${jsonDecode(data)}';
                      });
                    },
                  ),
                  Text('$_data')
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: (){
                      MangabzSourceModel().search('影之实力');
                    },
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: ()async{
                      print(await MangabzSourceModel().get(title: '想要成为影之实力者'));
                    },
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: ()async{
                      var comic=await (await ManHuaGuiSourceModel().get(title: 'EX-ARM')).getChapter(chapterId: '467538');
                      comic.init();
                    },
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
