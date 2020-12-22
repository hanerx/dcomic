import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/LoadingRow.dart';
import 'package:flutterdmzj/component/SubscribeCard.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';

class ComicFavoritePage extends StatefulWidget {
  final String uid;

  const ComicFavoritePage({Key key, this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicFavoritePage();
  }
}

class _ComicFavoritePage extends State<ComicFavoritePage> {
  ScrollController _controller = ScrollController();
  List list = <Widget>[LoadingRow()];
  int page = 0;
  int _row = 3;
  bool refreshState = false;

  void getSubscribe() async {
    CustomHttp http = CustomHttp();
    DataBase dataBase = DataBase();
    var response = await http.getSubscribe(int.parse(widget.uid), page);
    if (response.statusCode == 200 && mounted) {
      var unreadList = await dataBase.getAllUnread();
      setState(() {
        if (page == 0) {
          list.clear();
        } else {
          list.removeLast();
        }
        if (response.data.length == 0) {
          refreshState = true;
          if (page == 0) {
            list.add(Center(
              child: Text('看起来你没收藏啥，请先去收藏'),
            ));
          }
          return;
        }
        var cardList = <Widget>[];
        var position = 0;
        for (var item in response.data) {
          if (position >= _row) {
            list.add(Row(
              children: cardList,
            ));
            position = 0;
            cardList = <Widget>[];
          }
          bool unread = item['sub_readed'] == 0;
          if (unreadList[item['id'].toString()] != null &&
              unreadList[item['id'].toString()] >= item['sub_uptime'] * 1000) {
            unread = false;
          }
          cardList.add(SubscribeCard(item['sub_img'], item['name'],
              item['sub_update'], item['id'].toString(), unread));
          position++;
        }
        if (cardList.length > 0 && position < _row) {
          list.add(Row(
            children: cardList,
          ));
        }
        refreshState = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSubscribe();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !refreshState) {
        setState(() {
          refreshState = true;
          page++;
          list.add(LoadingRow());
        });
        getSubscribe();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scrollbar(
        child: SingleChildScrollView(
      controller: _controller,
      child: Column(
        children: list,
      ),
    ));
  }
}
