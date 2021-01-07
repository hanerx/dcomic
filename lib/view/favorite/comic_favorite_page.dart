import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
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
  List list = <Widget>[];
  int page = 0;
  int _row = 3;
  bool refreshState = false;

  Future<void> getSubscribe() async {
    CustomHttp http = CustomHttp();
    DataBase dataBase = DataBase();
    var response = await http.getSubscribe(int.parse(widget.uid), page);
    if (response.statusCode == 200 && mounted) {
      var unreadList = await dataBase.getAllUnread();
      setState(() {
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
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return EasyRefresh(
      firstRefresh: true,
      firstRefreshWidget: LoadingCube(),
      scrollController: ScrollController(),
      onRefresh: ()async{
        setState(() {
          page=0;
          refreshState=true;
          list.clear();
        });
        await getSubscribe();
      },
      onLoad: ()async{
        setState(() {
          page++;
          refreshState=true;
        });
        await getSubscribe();
      },
      header: ClassicalHeader(
          refreshedText: '刷新完成',
          refreshFailedText: '刷新失败',
          refreshingText: '刷新中',
          refreshText: '下拉刷新',
          refreshReadyText: '释放刷新'),
      footer: ClassicalFooter(
          loadReadyText: '下拉加载更多',
          loadFailedText: '加载失败',
          loadingText: '加载中',
          loadedText: '加载完成',
          noMoreText: '没有更多内容了'
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(2, 7, 2, 0),
        child: Column(
          children: list,
        ),
      ),
    );
  }
}
