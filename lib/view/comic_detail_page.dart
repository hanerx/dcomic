import 'package:cached_network_image/cached_network_image.dart';
import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_parallax/flutter_parallax.dart';
import 'package:flutterdmzj/component/Authors.dart';
import 'package:flutterdmzj/component/CustomDrawer.dart';
import 'package:flutterdmzj/component/EmptyView.dart';
import 'package:flutterdmzj/component/FancyFab.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/component/TypeTags.dart';
import 'package:flutterdmzj/model/comicDetail.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/sourceProvider.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/model/trackerModel.dart';
import 'package:flutterdmzj/view/comment_page.dart';
import 'package:flutterdmzj/view/login_page.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'comic_viewer.dart';

class ComicDetailPage extends StatefulWidget {
  final String id;
  final String title;

  ComicDetailPage({this.id, this.title});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicDetailPage();
  }
}

class _ComicDetailPage extends State<ComicDetailPage> {
  _ComicDetailPage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
    // var bool = ModalRoute.of(context).isCurrent;
    // if (bool) {
    //   Future.delayed(Duration(milliseconds: 200)).then((e) {
    //     loadComic();
    //     getIfSubscribe();
    //     addReadHistory();
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
//     if (error) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('好像出了点问题！'),
//         ),
//         body: Center(
//           child: Text('漫画找不到了！'),
//         ),
//       );
//     }
//     // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ComicDetailModel(
          Provider.of<SourceProvider>(context).active, widget.title, widget.id),
      builder: (context, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text(Provider.of<ComicDetailModel>(context).title),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share(
                        '【${Provider.of<ComicDetailModel>(context, listen: false).title}】 https://m.dmzj.com/info/${Provider.of<ComicDetailModel>(context, listen: false).comicId}.html');
                  },
                ),
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: Icon(
                        Provider.of<ComicDetailModel>(context).sub
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (Provider.of<ComicDetailModel>(context,
                                listen: false)
                            .loading) {
                          Scaffold.of(context).showSnackBar(
                              new SnackBar(content: Text('订阅信息还在加载中!')));
                        } else if (!Provider.of<ComicDetailModel>(context,
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
                          Provider.of<ComicDetailModel>(context, listen: false)
                              .sub = !Provider.of<ComicDetailModel>(context,
                                  listen: false)
                              .sub;
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            endDrawer: CustomDrawer(
              child: CommentPage(
                  Provider.of<ComicDetailModel>(context, listen: false).comicId,
                  0),
              widthPercent: 0.9,
            ),
            floatingActionButton: Provider.of<ComicDetailModel>(context).error
                ? null
                : Builder(
                    builder: (context) {
                      return FancyFab(
                        reverse: Provider.of<ComicDetailModel>(context).reverse,
                        isSubscribe: Provider.of<TrackerModel>(context)
                            .ifSubscribe(
                                Provider.of<ComicDetailModel>(context)),
                        onSort: () {
                          Provider.of<ComicDetailModel>(context, listen: false)
                              .reverse = !Provider.of<ComicDetailModel>(context,
                                  listen: false)
                              .reverse;
                        },
                        onPlay: () async {
                          if (Provider.of<ComicDetailModel>(context,
                                      listen: false)
                                  .lastChapterId !=
                              '') {
                            // 由于navigator里面context不包含provider，所以要先放在外面
                            var lastChapterId = Provider.of<ComicDetailModel>(
                                    context,
                                    listen: false)
                                .lastChapterId;
                            Comic comic = await Provider.of<ComicDetailModel>(
                                    context,
                                    listen: false)
                                .detail
                                .getChapter(chapterId: lastChapterId);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ComicViewPage(
                                comic: comic,
                              );
                            }));
                          } else if (Provider.of<ComicDetailModel>(context,
                                      listen: false)
                                  .lastChapterId ==
                              '') {
                            var comicId = Provider.of<ComicDetailModel>(context,
                                    listen: false)
                                .comicId;
                            var lastChapterId = '';
                            var lastChapterList = Provider.of<ComicDetailModel>(
                                    context,
                                    listen: false)
                                .chapters[0]['data']
                                .map((value) => value['chapter_id'].toString())
                                .toList();
                            if (lastChapterList.length > 0) {
                              lastChapterId =
                                  lastChapterList[lastChapterList.length - 1];
                            }
                            Comic comic = await Provider.of<ComicDetailModel>(
                                    context,
                                    listen: false)
                                .detail
                                .getChapter(chapterId: lastChapterId);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ComicViewPage(
                                comic: comic,
                              );
                            }));
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('好像没得记录，没法继续阅读'),
                            ));
                          }
                        },
                        onBlackBox: () async {
                          if (!Provider.of<SystemSettingModel>(context,
                                  listen: false)
                              .blackBox) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    children: [
                                      SimpleDialogOption(
                                        child: Text("Ops! 你遇到了一个没有用的按钮"),
                                      )
                                    ],
                                  );
                                });
                          } else {
                            int flag = await Provider.of<TrackerModel>(context,
                                    listen: false)
                                .subscribe(Provider.of<ComicDetailModel>(
                                    context,
                                    listen: false));
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('${flag == 1 ? '加入' : '取消加入'}黑匣子成功'),
                            ));
                          }
                        },
                        onDownload: () async {
                          List<Widget> list =
                              await Provider.of<ComicDetailModel>(context,
                                      listen: false)
                                  .buildDownloadWidgetList(context);
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Container(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: list,
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                      );
                    },
                  ),
            body: DirectSelectContainer(
              child: EasyRefresh(
                scrollController: ScrollController(),
                onRefresh: () async {
                  await Provider.of<ComicDetailModel>(context, listen: false)
                      .init();
                },
                firstRefresh: true,
                firstRefreshWidget: LoadingCube(),
                emptyWidget: Provider.of<ComicDetailModel>(context).error
                    ? ComicDetailEmptyView()
                    : null,
                child: new Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Parallax.inside(
                            child: Image(
                                image: CachedNetworkImageProvider(
                                    Provider.of<ComicDetailModel>(context)
                                        .cover,
                                    headers:
                                        Provider.of<ComicDetailModel>(context)
                                            .headers),
                                fit: BoxFit.cover),
                            mainAxisExtent: 200.0,
                          ),
                        )
                      ],
                    ),
                    DetailCard(
                        Provider.of<ComicDetailModel>(context).title,
                        Provider.of<ComicDetailModel>(context).updateDate,
                        Provider.of<ComicDetailModel>(context).status,
                        Provider.of<ComicDetailModel>(context).author,
                        Provider.of<ComicDetailModel>(context).types,
                        Provider.of<ComicDetailModel>(context).hotNum,
                        Provider.of<ComicDetailModel>(context).subscribeNum,
                        Provider.of<ComicDetailModel>(context).description),
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Row(
                        children: [
                          Padding(
                            child: Text(
                              '数据提供商',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Expanded(
                            child: Padding(
                              child: DirectSelectList<BaseSourceModel>(
                                values: Provider.of<SourceProvider>(context)
                                    .activeSources,
                                defaultItemIndex:
                                    Provider.of<SourceProvider>(context).index,
                                itemBuilder: (BaseSourceModel value) =>
                                    DirectSelectItem<BaseSourceModel>(
                                        itemHeight: 56,
                                        value: value,
                                        itemBuilder: (context, value) {
                                          return Container(
                                            child: Text(
                                              value.type.title,
                                              textAlign: TextAlign.start,
                                            ),
                                          );
                                        }),
                                onItemSelectedListener: (item, index, context) {
                                  Scaffold.of(context).showSnackBar(
                                      SnackBar(content: Text(item.type.title)));
                                  Provider.of<SourceProvider>(context,
                                          listen: false)
                                      .active = item;
                                  Provider.of<ComicDetailModel>(context,
                                          listen: false)
                                      .changeModel(item);
                                },
                                focusedItemDecoration: BoxDecoration(
                                  border: BorderDirectional(
                                    bottom: BorderSide(
                                        width: 1, color: Colors.black12),
                                    top: BorderSide(
                                        width: 1, color: Colors.black12),
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
                            ),
                          ),
                          Padding(
                            child: Icon(
                              Icons.unfold_more,
                              color: Theme.of(context).disabledColor,
                            ),
                            padding: EdgeInsets.only(right: 10),
                          )
                        ],
                      ),
                    ),
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Column(
                        children: Provider.of<ComicDetailModel>(context)
                            .buildChapterWidgetList(context),
                      ),
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }
}

class DetailCard extends StatelessWidget {
  final String title;
  final String updateDate;
  final String status;
  final List author;
  final List types;
  final int hotNum;
  final int subscribeNum;
  final String description;

  DetailCard(this.title, this.updateDate, this.status, this.author, this.types,
      this.hotNum, this.subscribeNum, this.description);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
        elevation: 0,
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
                          child: Authors(author),
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
                        Expanded(child: TypeTags(types))
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
