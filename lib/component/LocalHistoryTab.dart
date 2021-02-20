import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/EmptyView.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/database/database.dart';

import 'HistoryListTile.dart';

class LocalHistoryTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LocalHistoryTab();
  }
}

class _LocalHistoryTab extends State<LocalHistoryTab> {
  String uid = '';
  int page = 0;
  List list = <Widget>[];

  @override
  void deactivate() {
    super.deactivate();
    var bool = ModalRoute.of(context).isCurrent;
    if (bool) {
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        getHistory();
      });
    }
  }

  getHistory() async {
    DataBase dataBase = DataBase();
    var result=await dataBase.getReadHistory();
    if(mounted){
      setState(() {
        list.clear();
        for(var item in result.first){
          list.add(HistoryListTile(
              item['cover'],
              item['title'],
              item['last_chapter'],
              item['timestamp'],
              item['comicId'].toString()));
        }
        list=list.reversed.toList();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return EasyRefresh(
      scrollController: ScrollController(),
      child: ListView.builder(
          itemCount: list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return list[index];
          }),
      onRefresh: () async {
        setState(() {
          list.clear();
        });
        await getHistory();
        return;
      },
      firstRefreshWidget: LoadingCube(),
      firstRefresh: true,
      emptyWidget: list.length==0?EmptyView():null,
    );
  }
}
