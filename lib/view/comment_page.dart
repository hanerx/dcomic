import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/EmptyView.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:markdown_widget/markdown_helper.dart';

class CommentPage extends StatefulWidget {
  final String id;
  final int type;

  CommentPage(this.id, this.type);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CommentPage();
  }
}

class _CommentPage extends State<CommentPage> {
  List icons = [Icons.fiber_new, Icons.whatshot];
  int type = 0;
  int page = 0;
  bool refreshState = true;
  bool canGo = true;
  List list = <Widget>[
  ];
  EasyRefreshController _controller=EasyRefreshController();

  _CommentPage();

  getComment() async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getComicComment(widget.id, page, type);
      if (response.statusCode == 200 && mounted) {
        setState(() {
          if (response.data.length == 0) {
            refreshState = false;
            _controller.finishLoad(success: true,noMore: true);
            return;
          }
          for (var item in response.data) {
            list.add(ListTile(
              leading: ClipRRect(
                child: CachedNetworkImage(
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
                borderRadius: BorderRadius.circular(5),
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
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
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
                  list = <Widget>[];
                });
                getComment();
              }
            },
          )
        ],
      ),
      body: EasyRefresh(
        onRefresh: () async {
            setState(() {
              page = 0;
              refreshState = true;
              list.clear();
            });
            _controller.resetLoadState();
            await getComment();
          return;
        },
        firstRefresh: true,
        firstRefreshWidget: LoadingCube(),
        onLoad: ()async{
          setState(() {
            refreshState = true;
            page++;
          });
          getComment();
        },
        emptyWidget: list.length==0?EmptyView():null,
        child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return list[index];
            }),
      ),
    );
  }
}
