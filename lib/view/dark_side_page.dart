import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/view/ranking_page.dart';

class DarkSidePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DarkSidePage();
  }
}

class _DarkSidePage extends State<DarkSidePage> {
  List list = <Widget>[];

  getDarkInfo() async {
    CustomHttp http = CustomHttp();
    var response = await http.getDarkInfo();
    if (response.statusCode == 200 && mounted) {
      setState(() {
        var data = jsonDecode(response.data);
        for (var item in data) {
          var authors = item['authors'].join('/');
          var types = item['types'].join('/');
          list.add(CustomListTile(item['cover'], item['title'], types,
              item['last_updatetime'], item['id'].toString(), authors));
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDarkInfo();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('黑暗面'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text('帮助'),
                      children: <Widget>[
                        SimpleDialogOption(
                          child: Text(
                              '这里是大妈之家黑暗面，这里存储了在光明面消失的部分漫画。注：本功能是通过调用别人的接口实现的，不知道什么时候就会消失，并且不一定在这里能看到详情的漫画就一定能看(有一些还是被阉割了的'),
                        )
                      ],
                    );
                  });
            },
          )
        ],
      ),
      body: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return list[index];
          }),
    );
  }
}
