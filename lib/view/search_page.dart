import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/search/DeepSearchTab.dart';
import 'package:flutterdmzj/component/search/NovelSearchTab.dart';
import 'package:flutterdmzj/component/search/SearchTab.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:provider/provider.dart';


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
  bool deepSearch = false;
  bool novelSearch = false;

  getDeepSearch() async {
    DataBase dataBase = DataBase();
    bool state = await dataBase.getDeepSearch();
    setState(() {
      deepSearch = state;
    });
  }

  getNovelSearch() async {
    DataBase dataBase = DataBase();
    bool state = await dataBase.getNovelState();
    setState(() {
      novelSearch = state;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeepSearch();
    getNovelSearch();
  }

  @override
  Widget build(BuildContext context) {
    List tabs = <Tab>[
      Tab(
        text: '普通搜索',
      ),
    ];
    List views = <Widget>[
      SearchTab(key: UniqueKey(), keyword: keyword),
    ];
    if (novelSearch) {
      tabs.add(Tab(
        text: '轻小说搜索',
      ));
      views.add(NovelSearchTab(
        keyword: keyword,
        key: UniqueKey(),
      ));
    }
    if (deepSearch) {
      tabs.add(Tab(
        text: '隐藏搜索',
      ));
      views.add(DeepSearchTab(
        key: UniqueKey(),
        keyword: keyword,
      ));
    }

    // TODO: implement build
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            enableInteractiveSelection: true,
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
              if (keyword == '宝塔镇河妖') {
                Provider.of<SystemSettingModel>(context, listen: false)
                    .backupApi = true;
              } else if (keyword == '天王盖地虎') {
                Provider.of<SystemSettingModel>(context, listen: false)
                    .backupApi = false;
              }
            },
          ),
          bottom: TabBar(
            tabs: tabs,
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
                if (keyword == '宝塔镇河妖') {
                  Provider.of<SystemSettingModel>(context, listen: false)
                      .backupApi = true;
                } else if (keyword == '天王盖地虎') {
                  Provider.of<SystemSettingModel>(context, listen: false)
                      .backupApi = false;
                }
              },
            )
          ],
        ),
        body: TabBarView(
          children: views,
        ),
      ),
    );
  }
}
