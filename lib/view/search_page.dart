import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/DeepSearchTab.dart';
import 'package:flutterdmzj/component/SearchListTile.dart';
import 'package:flutterdmzj/component/SearchTab.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';

import 'comic_detail_page.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchPage();
  }
}

class _SearchPage extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  FocusNode _node = FocusNode();
  String keyword = '';
  bool deepSearch=false;

  List normalTabs=<Tab>[
    Tab(text: '普通搜索',),
  ];
  List deepTabs=<Tab>[
    Tab(text: '普通搜索',),
    Tab(text: '影藏搜索',)
  ];




  getDeepSearch()async{
    DataBase dataBase=DataBase();
    bool state =await dataBase.getDeepSearch();
    setState(() {
      deepSearch=state;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeepSearch();
  }

  @override
  Widget build(BuildContext context) {

    List views=<Widget>[
      SearchTab(key: UniqueKey(),keyword: keyword),

    ];
    if(deepSearch){
      views.add(DeepSearchTab(key:UniqueKey(),keyword: keyword,));
    }
    // TODO: implement build
    return DefaultTabController(
      length: deepSearch?2:1,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            focusNode: _node,
            autofocus: true,
            controller: _controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '输入关键词',
              hintStyle: TextStyle(color: Colors.white),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (val) {
              _node.unfocus();
              setState(() {
                keyword = _controller.text;
              });
            },
          ),
          bottom: TabBar(
            tabs: deepSearch?deepTabs:normalTabs,
          ),
          actions: <Widget>[
            FlatButton(
              child: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                _node.unfocus();
                setState(() {
                  keyword = _controller.text;
                });
              },
            )
          ],
        ),
        body: TabBarView(
          children:views,
        ),
      ),
    );
  }
}


