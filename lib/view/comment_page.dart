import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/LoadingTile.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';

class CommentPage extends StatefulWidget {
  final String comicId;

  CommentPage(this.comicId);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CommentPage(comicId);
  }
}

class _CommentPage extends State<CommentPage> {
  final String comicId;
  List icons = [Icons.fiber_new, Icons.whatshot];
  int type = 0;
  int page = 0;
  bool refreshState = true;
  bool canGo = true;
  List list = <Widget>[
    LoadingTile()
  ];
  ScrollController _controller = ScrollController();

  _CommentPage(this.comicId);

  getComment() async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getComicComment(comicId, page, type);
      if (response.statusCode == 200 && mounted) {
        setState(() {
          if (page == 0) {
            list.clear();
          } else {
            list.removeLast();
          }
          if (response.data.length == 0) {
            refreshState = false;
            canGo = false;
            list.add(ListTile(leading: Icon(Icons.clear),title: Text('没有更多了'),));
            return;
          }
          for (var item in response.data) {
            list.add(ListTile(
              leading: CachedNetworkImage(
                imageUrl: item['avatar_url'],
                httpHeaders: {'referer': 'http://images.dmzj.com'},
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl: 'https://avatar.dmzj.com/default.png',
                  httpHeaders: {'referer': 'http://images.dmzj.com'},
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(Icons.warning),
                  ),
                ),
              ),
              title: Text('${item['content']}'),
              subtitle: Text(
                  '${ToolMethods.formatTimestamp(item['createtime'])} ${item['nickname']} ↑${item['hot_comment_amount']}'),
            ));
            list.add(Divider());
          }
          refreshState = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        refreshState = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComment();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !refreshState &&
          canGo) {
        setState(() {
          refreshState = true;
          page++;
          list.add(LoadingTile());
        });
        getComment();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text('评论'),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              icons[type],
              color: Colors.white,
            ),
            onPressed: () {
              if (!refreshState) {
                setState(() {
                  page = 0;
                  type++;
                  if (type >= icons.length) {
                    type = 0;
                  }
                  refreshState = true;
                  list = <Widget>[
                    LoadingTile()
                  ];
                });
                getComment();
              }
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!refreshState) {
            setState(() {
              page = 0;
              refreshState = true;
            });
            await getComment();
          }
          return;
        },
        child: ListView.builder(
            controller: _controller,
            itemCount: list.length,
            itemBuilder: (context, index) {
              return list[index];
            }),
      ),
    );
  }
}
