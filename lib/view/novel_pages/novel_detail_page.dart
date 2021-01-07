import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_parallax/flutter_parallax.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/model/novelDetail.dart';
import 'package:provider/provider.dart';

import '../comic_detail_page.dart';
import '../login_page.dart';

class NovelDetailPage extends StatefulWidget {
  final int id;

  const NovelDetailPage({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelDetailPage();
  }
}

class _NovelDetailPage extends State<NovelDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => NovelDetailModel(widget.id),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${Provider.of<NovelDetailModel>(context).title}'),
            actions: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(
                      Provider.of<NovelDetailModel>(context).sub
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (Provider.of<NovelDetailModel>(context, listen: false)
                          .loading) {
                        Scaffold.of(context).showSnackBar(
                            new SnackBar(content: Text('订阅信息还在加载中!')));
                      } else if (!Provider.of<NovelDetailModel>(context,
                          listen: false)
                          .login) {
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content: Text('请先登录!'),
                          action: SnackBarAction(
                            label: '去登录',
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return LoginPage();
                                  }));
                            },
                          ),
                        ));
                      } else {
                        Provider.of<NovelDetailModel>(context, listen: false)
                            .sub = !Provider.of<NovelDetailModel>(context,
                            listen: false)
                            .sub;
                      }
                    },
                  );
                },
              ),
            ],
          ),
          body: EasyRefresh(
            onRefresh: ()async{
              await Provider.of<NovelDetailModel>(context,listen: false).getNovel(widget.id);
              await Provider.of<NovelDetailModel>(context,listen: false).getChapter(widget.id);
              await Provider.of<NovelDetailModel>(context,listen: false).getIfSubscribe(widget.id);
            },
            firstRefreshWidget: LoadingCube(),
            firstRefresh: true,
            child: SingleChildScrollView(
              child: new Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Parallax.inside(
                          child: Image(
                              image: CachedNetworkImageProvider(
                                  Provider.of<NovelDetailModel>(context).cover,
                                  headers: {'referer': 'http://images.dmzj.com'}),
                              fit: BoxFit.cover),
                          mainAxisExtent: 200.0,
                        ),
                      )
                    ],
                  ),
                  _DetailCard(
                      Provider.of<NovelDetailModel>(context).title,
                      Provider.of<NovelDetailModel>(context).updateDate,
                      Provider.of<NovelDetailModel>(context).status,
                      Provider.of<NovelDetailModel>(context).author,
                      Provider.of<NovelDetailModel>(context).types,
                      Provider.of<NovelDetailModel>(context).hotNum,
                      Provider.of<NovelDetailModel>(context).subscribeNum,
                      Provider.of<NovelDetailModel>(context).description),
                  Card(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: ExpansionPanelList(
                      expansionCallback:
                      Provider.of<NovelDetailModel>(context).setExpand,
                      children: Provider.of<NovelDetailModel>(context)
                          .buildChapterWidget(context),
                    ),
                  )
                ],
              ),
            ),
          )
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String updateDate;
  final String status;
  final String author;
  final String types;
  final int hotNum;
  final int subscribeNum;
  final String description;

  _DetailCard(this.title, this.updateDate, this.status, this.author, this.types,
      this.hotNum, this.subscribeNum, this.description);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Padding(
          padding: EdgeInsets.fromLTRB(4, 2, 4, 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    '最后更新：$updateDate  $status',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.supervisor_account,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: Center(
                            child: Text('$author'),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.category,
                          color: Colors.grey,
                        ),
                        Expanded(
                            child: Center(
                          child: Text('$types'),
                        ))
                      ],
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.whatshot,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: Center(
                            child: Text('$hotNum'),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.favorite,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: Center(
                            child: Text('$subscribeNum'),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(description),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
