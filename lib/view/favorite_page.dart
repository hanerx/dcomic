import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';

class FavoritePage extends StatefulWidget {
  final String uid;

  FavoritePage(this.uid);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FavoritePage(uid);
  }
}

class _FavoritePage extends State<FavoritePage> {
  final String uid;

  _FavoritePage(this.uid);

  int page = 0;
  int _row = 3;
  List list = <Widget>[Center(child: CircularProgressIndicator())];
  ScrollController _controller = ScrollController();
  bool refreshState = false;

  void getSubscribe() async {
    CustomHttp http = CustomHttp();
    var response = await http.getSubscribe(int.parse(uid), page);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        if (page == 0) {
          list.clear();
        }
        if (response.data.length == 0) {
          refreshState = true;
          if (page == 0) {
            list.add(Center(child: Text('看起来你没收藏啥，请先去收藏'),));
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
          cardList.add(SubscribeCard(item['sub_img'], item['name'],
              item['sub_update'], item['id'].toString()));
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
        });
        getSubscribe();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('我的订阅'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (mounted) {
                setState(() {
                  list = <Widget>[Center(child: CircularProgressIndicator())];
                  refreshState = true;
                  page = 0;
                });
                getSubscribe();
              }
            },
          )
        ],
      ),
      body: new Scrollbar(
          child: SingleChildScrollView(
            controller: _controller,
            child: Column(
              children: list,
            ),
          )),
    );
  }
}

class SubscribeCard extends StatelessWidget {
  final String cover;
  final String title;
  final String subTitle;
  final String comicId;

  SubscribeCard(this.cover, this.title, this.subTitle, this.comicId);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
      child: FlatButton(
        padding: EdgeInsets.all(0),
        child: Card(
          child: Column(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: '$cover',
                httpHeaders: {'referer': 'http://images.dmzj.com'},
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Text(
                '$title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '最近更新：$subTitle',
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ComicDetailPage(comicId);
          }));
        },
      ),
    );
  }
}
