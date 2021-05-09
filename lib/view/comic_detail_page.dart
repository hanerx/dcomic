import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_parallax/flutter_parallax.dart';
import 'package:dcomic/component/Authors.dart';
import 'package:dcomic/component/CustomDrawer.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/FancyFab.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/component/SearchDialog.dart';
import 'package:dcomic/component/TypeTags.dart';
import 'package:dcomic/model/comicDetail.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/model/systemSettingModel.dart';
import 'package:dcomic/model/trackerModel.dart';
import 'package:dcomic/view/comment_page.dart';
import 'package:dcomic/view/login_page.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'comic_viewer.dart';

class ComicDetailPage extends StatefulWidget {
  final String id;
  final String title;
  final BaseSourceModel model;

  ComicDetailPage({this.id, this.title, this.model});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicDetailPage();
  }
}

class _ComicDetailPage extends State<ComicDetailPage> {
  bool _lock = true;

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
    if (widget.model != null && _lock) {
      // 初始化默认的model，解决后面多model的问题
      Provider.of<SourceProvider>(context, listen: false)
          .setActiveWithoutNotify(widget.model);
      _lock = false;
    }
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
                        Provider.of<ComicDetailModel>(context, listen: false)
                            .detail
                            .share());
                    Provider.of<SystemSettingModel>(context, listen: false)
                        .analytics
                        .logShare(
                            contentType: 'String',
                            itemId: Provider.of<ComicDetailModel>(context,
                                    listen: false)
                                .detail
                                .share(),
                            method: 'share');
                  },
                ),
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: Icon(
                        !Provider.of<ComicDetailModel>(context).loading &&
                                Provider.of<ComicDetailModel>(context).sub
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (Provider.of<ComicDetailModel>(context,
                                listen: false)
                            .sourceDetail
                            .canSubscribe) {
                          if (Provider.of<ComicDetailModel>(context,
                                  listen: false)
                              .loading) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                new SnackBar(content: Text('订阅信息还在加载中!')));
                          } else if (Provider.of<ComicDetailModel>(context,
                                      listen: false)
                                  .login ==
                              UserStatus.logout) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(new SnackBar(
                              content: Text('请先登录!'),
                              action: SnackBarAction(
                                label: '去登录',
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) {
                                            return LoginPage();
                                          },
                                          settings: RouteSettings(
                                              name: 'login_page')));
                                },
                              ),
                            ));
                          } else {
                            Provider.of<ComicDetailModel>(context,
                                    listen: false)
                                .sub = !Provider.of<ComicDetailModel>(context,
                                    listen: false)
                                .sub;
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              new SnackBar(content: Text('该源不支持订阅！')));
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            endDrawer: CustomDrawer(
              child: CommentPage(
                  detail: Provider.of<ComicDetailModel>(context).detail),
              widthPercent: 0.9,
            ),
            floatingActionButton: Provider.of<ComicDetailModel>(context)
                        .error !=
                    null
                ? null
                : Builder(
                    builder: (context) {
                      return FancyFab(
                        isSubscribe: Provider.of<TrackerModel>(context)
                            .ifSubscribe(
                                Provider.of<ComicDetailModel>(context)),
                        onMessage: () {
                          Scaffold.of(context).openEndDrawer();
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) {
                                      return ComicViewPage(
                                        comic: comic,
                                      );
                                    },
                                    settings: RouteSettings(
                                        name: 'comic_view_page')));
                          } else if (Provider.of<ComicDetailModel>(context,
                                      listen: false)
                                  .lastChapterId ==
                              '') {
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) {
                                      return ComicViewPage(
                                        comic: comic,
                                      );
                                    },
                                    settings: RouteSettings(
                                        name: 'comic_view_page')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                            if (Provider.of<SourceProvider>(context,
                                        listen: false)
                                    .active
                                    .type
                                    .name ==
                                'dmzj') {
                              int flag = await Provider.of<TrackerModel>(
                                      context,
                                      listen: false)
                                  .subscribe(Provider.of<ComicDetailModel>(
                                      context,
                                      listen: false));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content:
                                    Text('${flag == 1 ? '加入' : '取消加入'}黑匣子成功'),
                              ));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('该漫画源不支持黑匣子功能，请将当前漫画源调整为动漫之家漫画源'),
                              ));
                            }
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
                                  insetPadding: EdgeInsets.all(10),
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
                emptyWidget: Provider.of<ComicDetailModel>(context).error !=
                        null
                    ? ComicDetailEmptyView(
                        exception: Provider.of<ComicDetailModel>(context).error,
                        title: widget.title,
                        comicId: widget.id,
                      )
                    : null,
                child: new Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Parallax.inside(
                            child: Image(
                                image: buildProvider(context),
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
                        margin: EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text('源漫画ID: '),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: SelectableText(
                                      '${Provider.of<ComicDetailModel>(context).rawComicId}'),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text('绑定漫画ID: '),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: SelectableText(
                                      '${Provider.of<ComicDetailModel>(context).comicId}'),
                                ),
                              ),
                              IconButton(
                                tooltip: '重新绑定漫画ID',
                                icon: Icon(Icons.refresh),
                                onPressed: () async {
                                  var flag = await showDialog(
                                      context: context,
                                      builder: (context) => StatefulBuilder(
                                              builder: (context, state) {
                                            return SearchDialog(
                                              model:
                                                  Provider.of<SourceProvider>(
                                                          context)
                                                      .active,
                                              keyword: widget.title,
                                              comicId: widget.id,
                                            );
                                          }));
                                  if (flag != null && flag) {
                                    Provider.of<ComicDetailModel>(context,
                                            listen: false)
                                        .init();
                                  }
                                },
                              ),
                            ],
                          ),
                        )),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                        margin: EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Row(
                            children: [
                              TextButton.icon(
                                  onPressed: () {
                                    Provider.of<ComicDetailModel>(context,
                                            listen: false)
                                        .block = !Provider.of<ComicDetailModel>(
                                            context,
                                            listen: false)
                                        .block;
                                  },
                                  icon: Icon(
                                    Provider.of<ComicDetailModel>(context).block
                                        ? Icons.apps
                                        : Icons.list,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                  ),
                                  label: Text(
                                      '${Provider.of<ComicDetailModel>(context).block ? '棋盘' : '列表'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1)),
                              Expanded(child: Container()),
                              TextButton.icon(
                                  onPressed: () {
                                    Provider.of<ComicDetailModel>(context,
                                                listen: false)
                                            .reverse =
                                        !Provider.of<ComicDetailModel>(context,
                                                listen: false)
                                            .reverse;
                                  },
                                  icon: Icon(
                                      Provider.of<ComicDetailModel>(context)
                                              .reverse
                                          ? FontAwesome5.sort_amount_down_alt
                                          : FontAwesome5.sort_amount_down,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color),
                                  label: Text(
                                    '${Provider.of<ComicDetailModel>(context).reverse ? '正序' : '倒序'}',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ))
                            ],
                          ),
                        )),
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

  ImageProvider buildProvider(context) {
    if (Provider.of<ComicDetailModel>(context).pageType == PageType.local) {
      return FileImage(File(Provider.of<ComicDetailModel>(context).cover));
    }
    return CachedNetworkImageProvider(
        Provider.of<ComicDetailModel>(context).cover,
        headers: Provider.of<ComicDetailModel>(context).headers);
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
