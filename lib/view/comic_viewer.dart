import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/CustomDrawer.dart';
import 'package:flutterdmzj/component/EmptyView.dart';
import 'package:flutterdmzj/component/comic_viewer/HorizontalPageView.dart';
import 'package:flutterdmzj/component/comic_viewer/Tips.dart';
import 'package:flutterdmzj/component/comic_viewer/VerticalPageView.dart';
import 'package:flutterdmzj/model/comic.dart';
import 'package:flutterdmzj/model/comicViewerSettingModel.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';
import 'package:provider/provider.dart';

class ComicViewPage extends StatefulWidget {
  final Comic comic;

  const ComicViewPage({Key key, this.comic})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicViewPage();
  }
}

class _ComicViewPage extends State<ComicViewPage>
    with TickerProviderStateMixin {
  bool _show = false;
  int _initialIndex=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    print("class: ComicViewer, action: volumeChannelCancel");
    EventChannel("top.hanerx/volume")
        .receiveBroadcastStream()
        .listen((event) {})
        .cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
        create: (_) => ComicModel(widget.comic),
        builder: (context, test) {
          return Scaffold(
              backgroundColor: ComicViewerSettingModel.backgroundColors[Provider.of<ComicViewerSettingModel>(context).backgroundColor],
              body: Stack(
                children: [
                  _buildViewer(context),
                  AnimatedPositioned(
                    top: _show ? 0 : -80,
                    left: 0,
                    right: 0,
                    height: 80,
                    duration: Duration(milliseconds: 200),
                    child: AppBar(
                      backgroundColor: Colors.black54,
                      title: Text('${Provider.of<ComicModel>(context).title}'),
                    ),
                  ),
                  AnimatedPositioned(
                      bottom: _show ? 0 : -106,
                      left: 0,
                      right: 0,
                      height: 106,
                      duration: Duration(milliseconds: 200),
                      child: Column(
                        children: [
                          _buildSlider(context),
                          Builder(
                            builder: (context) {
                              return BottomNavigationBarTheme(
                                data: BottomNavigationBarThemeData(
                                    selectedItemColor: Colors.white),
                                child: BottomNavigationBar(
                                  type: BottomNavigationBarType.fixed,
                                  onTap: (index) async {
                                    switch (index) {
                                      case 0:
                                        await Provider.of<ComicModel>(context,
                                                listen: false)
                                            .previousChapter();
                                        if (Provider.of<ComicViewerSettingModel>(context,listen: false).direction) {
                                          horizontalKey.currentState
                                              .moveToTop();
                                        } else {
                                          verticalKey.currentState.moveToTop();
                                          verticalKey.currentState.onPreviousChapter();
                                        }
                                        break;
                                      case 1:
                                        Scaffold.of(context).openEndDrawer();
                                        setState(() {
                                          _initialIndex=0;
                                        });
                                        break;
                                      case 2:
                                        Scaffold.of(context).openEndDrawer();
                                        setState(() {
                                          _initialIndex=1;
                                        });
                                        break;
                                      case 3:
                                        Scaffold.of(context).openEndDrawer();
                                        setState(() {
                                          _initialIndex=2;
                                        });
                                        break;
                                      case 4:
                                        await Provider.of<ComicModel>(context,
                                                listen: false)
                                            .nextChapter();
                                        if (Provider.of<ComicViewerSettingModel>(context,listen: false).direction) {
                                          horizontalKey.currentState
                                              .moveToTop();
                                        } else {
                                          verticalKey.currentState.moveToTop();
                                          verticalKey.currentState.onNextChapter();
                                        }
                                        break;
                                    }
                                  },
                                  backgroundColor: Colors.black54,
                                  unselectedItemColor: Colors.white,
                                  unselectedLabelStyle:
                                      TextStyle(color: Colors.white),
                                  currentIndex: 1,
                                  items: [
                                    BottomNavigationBarItem(
                                      title: Text('上一话'),
                                      icon: Icon(Icons.arrow_drop_up),
                                    ),
                                    BottomNavigationBarItem(
                                      title: Text('吐槽'),
                                      icon: Icon(Icons.message),
                                    ),
                                    BottomNavigationBarItem(
                                      title: Text('目录'),
                                      icon: Icon(Icons.list),
                                    ),
                                    BottomNavigationBarItem(
                                      title: Text('设置'),
                                      icon: Icon(Icons.settings),
                                    ),
                                    BottomNavigationBarItem(
                                      title: Text('下一话'),
                                      icon: Icon(Icons.arrow_drop_down),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 300),
                    bottom: _show ? -27 : -1,
                    height: 27,
                    right: -1,
                    child: Tips(
                      title: Provider.of<ComicModel>(context).title,
                      index: Provider.of<ComicModel>(context).index + 1,
                      length: Provider.of<ComicModel>(context).length,
                    ),
                  )
                ],
              ),
              endDrawer: CustomDrawer(
                widthPercent: 0.9,
                child: DefaultTabController(
                  length: 3,
                  initialIndex: _initialIndex,
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.black54,
                      title: Text("${Provider.of<ComicModel>(context).title}"),
                      bottom: TabBar(
                        tabs: [Tab(text: "吐槽"), Tab(text: '目录',),Tab(text: "设定")],
                      ),
                    ),
                    body: TabBarView(
                      children: [
                        _buildViewPoint(context),
                        _buildCatalogue(context),
                        _buildConfig(context)
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  Widget _buildViewer(BuildContext context) {
    if (Provider.of<ComicViewerSettingModel>(context,listen: false).direction) {
      return HorizontalPageView(
        key: horizontalKey,
        builder: (context, index) =>
            Provider.of<ComicModel>(context).builder(index),
        left: Provider.of<ComicModel>(context).left,
        right: Provider.of<ComicModel>(context).right,
        count: Provider.of<ComicModel>(context).length + 2,
        onEnd: Provider.of<ComicModel>(context).nextChapter,
        onTop: Provider.of<ComicModel>(context).previousChapter,
        debug: Provider.of<ComicViewerSettingModel>(context).debug,
        hitBox: Provider.of<ComicViewerSettingModel>(context).hitBox,
        reverse: Provider.of<ComicViewerSettingModel>(context).reverse,
        onPageChange: (index) {
          Provider.of<ComicModel>(context, listen: false).index = index;
        },
        onTap: (index) {
          this.show = !this.show;
        },
        animation: Provider.of<ComicViewerSettingModel>(context).animation,
      );
    } else {
      return VerticalPageView(
        key: verticalKey,
        builder: (context, index) =>
            Provider.of<ComicModel>(context).builder(index),
        refreshState: Provider.of<ComicModel>(context).refreshState,
        left: Provider.of<ComicModel>(context).left,
        right: Provider.of<ComicModel>(context).right,
        count: Provider.of<ComicModel>(context).length,
        onEnd: Provider.of<ComicModel>(context).nextChapter,
        onTop: Provider.of<ComicModel>(context).previousChapter,
        debug: Provider.of<ComicViewerSettingModel>(context).debug,
        hitBox: Provider.of<ComicViewerSettingModel>(context).hitBox,
        range: Provider.of<ComicViewerSettingModel>(context).range,
        onPageChange: (index) {
          Provider.of<ComicModel>(context, listen: false).index = index;
        },
        onTap: (index) {
          this.show = !this.show;
        },
      );
    }
  }

  Widget _buildViewPoint(BuildContext context) {
    return EasyRefresh(
      scrollController: ScrollController(),
      onRefresh: ()async{
        await Provider.of<ComicModel>(context,listen: false).refreshViewPoint();
      },
      emptyWidget: Provider.of<ComicModel>(context).emptyViewPoint?EmptyView():null,
      child: Wrap(
        children: Provider.of<ComicModel>(context).buildViewPoint(context),
      ),
    );
  }

  Widget _buildConfig(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          title: Text("阅读方向"),
          subtitle: Text("${Provider.of<ComicViewerSettingModel>(context).direction ? '横向阅读' : '纵向阅读'}"),
          onTap: () {
            Provider.of<ComicViewerSettingModel>(context,listen: false).direction=!Provider.of<ComicViewerSettingModel>(context,listen:false).direction;
          },
        ),
        ListTile(
          title: Text('横向阅读方向'),
          subtitle: Text('${Provider.of<ComicViewerSettingModel>(context).reverse ? '从右到左' : '从左到右'}'),
          enabled: Provider.of<ComicViewerSettingModel>(context).direction,
          onTap: () {
            Provider.of<ComicViewerSettingModel>(context,listen: false).reverse=!Provider.of<ComicViewerSettingModel>(context,listen:false).reverse;
          },
        ),
        ListTile(
          title: Text('翻页动画设置'),
          subtitle: Text('${Provider.of<ComicViewerSettingModel>(context).animation ? '启用动画' : '禁用动画'}'),
          enabled: Provider.of<ComicViewerSettingModel>(context).direction,
          onTap: () {
            Provider.of<ComicViewerSettingModel>(context,listen: false).animation=!Provider.of<ComicViewerSettingModel>(context,listen:false).animation;
          },
        ),
        Divider(),
        ListTile(
          title: Text("显示碰撞箱"),
          subtitle: Text("可以调整上下点击翻页的触发面积，由于底层架构的升级不会出现手势打架的情况了"),
          trailing: Switch(
            value: Provider.of<ComicViewerSettingModel>(context).debug,
            onChanged: (state) {
              Provider.of<ComicViewerSettingModel>(context,listen: false).debug=state;
            },
          ),
        ),
        ListTile(
          title: Text('碰撞体积'),
          subtitle: Slider(
            min: 0,
            max: 200,
            value: Provider.of<ComicViewerSettingModel>(context).hitBox,
            onChanged: (value) {
              Provider.of<ComicViewerSettingModel>(context,listen: false).hitBox=value;
            },
          ),
        ),
        Divider(),
        ListTile(
          title: Text("翻页距离"),
          subtitle: Slider(
            label: "垂直翻页使用固定距离翻页法，在这调整翻页距离",
            min: 100,
            max: 1000,
            value: Provider.of<ComicViewerSettingModel>(context).range,
            onChanged: (value) {
              Provider.of<ComicViewerSettingModel>(context,listen: false).range=value;
            },
          ),
        ),
        Divider(),
        Container(
          child: ListTile(
            title: Text(
              '背景颜色',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Row(
              children: ComicViewerSettingModel.backgroundColors
                  .map<Widget>((e) => IconButton(
                        icon: Icon(
                          Icons.color_lens,
                          color: e,
                        ),
                        onPressed: () {
                          Provider.of<ComicViewerSettingModel>(context,listen: false).backgroundColor=ComicViewerSettingModel.backgroundColors.indexOf(e);
                        },
                      ))
                  .toList(),
            ),
          ),
          decoration: BoxDecoration(color: Colors.grey),
        ),
        Divider(),
        ListTile(
          title: Text("调试信息"),
          subtitle: Text(
              "chapterId: ${Provider.of<ComicModel>(context).chapterId}\n"
              "comicId: ${Provider.of<ComicModel>(context).comicId}\n"
              "chapterList: ${Provider.of<ComicModel>(context).chapters}\n"
              "length: ${Provider.of<ComicModel>(context).length}\n"
              "pageAt: ${Provider.of<ComicModel>(context).pageAt}\n"
              "left: ${Provider.of<ComicModel>(context).left} right: ${Provider.of<ComicModel>(context).right}\n"
              ""),
        )
      ],
    );
  }

  Widget _buildSlider(context) {
    if (Provider.of<ComicViewerSettingModel>(context,listen: false).direction) {
      return Container(
        color: Colors.black54,
        child: Slider(
          value: Provider.of<ComicModel>(context).index.toDouble() + 1.0,
          min: 0.0,
          max: Provider.of<ComicModel>(context).length.toDouble() >= 1.0
              ? Provider.of<ComicModel>(context).length.toDouble() + 1.0
              : 1.0,
          divisions: Provider.of<ComicModel>(context).length >= 1
              ? Provider.of<ComicModel>(context).length + 1
              : 1,
          onChanged: (index) {
            if (index >= 1 &&
                index <
                    Provider.of<ComicModel>(context, listen: false).length) {
              Provider.of<ComicModel>(context, listen: false).index =
                  index.toInt();
              if (Provider.of<ComicViewerSettingModel>(context,listen: false).direction) {
                horizontalKey.currentState.animateToPage(index.toInt());
              }
            }
          },
          label: '${Provider.of<ComicModel>(context).index + 1}',
        ),
      );
    } else {
      return Container(
        color: Colors.black54,
        child: Slider(
          min: 0,
          value: 0,
          max: 100,
          onChanged: null,
        ),
      );
    }
  }

  Widget _buildCatalogue(context){
    return ListView.builder(itemBuilder: Provider.of<ComicModel>(context).buildChapterWidget,itemCount: Provider.of<ComicModel>(context).catalogueLength,);
  }

  bool get show => _show;

  set show(bool show) {
    if (mounted) {
      setState(() {
        _show = show;
      });
    }
    if (_show) {
      Future.delayed(Duration(milliseconds: 500)).then((value) =>
          SystemChrome.setEnabledSystemUIOverlays(
              [SystemUiOverlay.top, SystemUiOverlay.bottom]));
    } else {
      Future.delayed(Duration(milliseconds: 500))
          .then((value) => SystemChrome.setEnabledSystemUIOverlays([]));
    }
  }
}
