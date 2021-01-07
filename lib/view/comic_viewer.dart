import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdmzj/component/CustomDrawer.dart';
import 'package:flutterdmzj/component/comic_viewer/ComicPage.dart';
import 'package:flutterdmzj/component/comic_viewer/HorizontalPageView.dart';
import 'package:flutterdmzj/component/comic_viewer/Tips.dart';
import 'package:flutterdmzj/component/comic_viewer/VerticalPageView.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/comic.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:provider/provider.dart';

class ComicViewPage extends StatefulWidget {
  final String comicId;
  final String chapterId;
  final List chapterList;

  const ComicViewPage({Key key, this.comicId, this.chapterId, this.chapterList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicViewPage();
  }
}

class _ComicViewPage extends State<ComicViewPage>
    with TickerProviderStateMixin {
  bool direction = false;
  bool debug = false;
  double hitBox = 100;
  double range = 500;
  bool _show = false;
  bool reverse = false;
  int backgroundColor = 0;
  static List colors = [
    Colors.white,
    Colors.black,
    Colors.brown,
    Colors.blueGrey,
    Color.fromARGB(100, 242, 235, 217),
    Color.fromRGBO(239, 217, 176, 1),
    Color.fromRGBO(255, 240, 205, 1)
  ];

  DataBase _dataBase;
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dataBase = DataBase();
    _tabController = TabController(length: 2, vsync: this);
    init();
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

  init() async {
    var hitBox = await _dataBase.getControlSize();
    var range = await _dataBase.getRange();
    var direction = await _dataBase.getReadDirection();
    var backgroundColor = await _dataBase.getBackground();
    var reverse = await _dataBase.getHorizontalDirection();
    setState(() {
      this.hitBox = hitBox;
      this.range = range;
      this.direction = direction;
      this.backgroundColor = backgroundColor;
      this.reverse = reverse;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
        create: (_) => ComicModel(
            widget.comicId,
            widget.chapterId,
            widget.chapterList,
            Provider.of<SystemSettingModel>(context).backupApi),
        builder: (context, test) {
          return Scaffold(
              backgroundColor: colors[backgroundColor],
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
                                  onTap: (index) async {
                                    switch (index) {
                                      case 0:
                                        await Provider.of<ComicModel>(context,
                                                listen: false)
                                            .previousChapter();
                                        if (direction) {
                                          horizontalKey.currentState
                                              .moveToTop();
                                        } else {
                                          verticalKey.currentState.moveToTop();
                                        }
                                        break;
                                      case 1:
                                        Scaffold.of(context).openEndDrawer();
                                        break;
                                      case 2:
                                        await Provider.of<ComicModel>(context,
                                                listen: false)
                                            .nextChapter();
                                        if (direction) {
                                          horizontalKey.currentState
                                              .moveToTop();
                                        } else {
                                          verticalKey.currentState.moveToTop();
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
                                      icon: Icon(Icons.list),
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
                  length: 2,
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.black54,
                      title: Text("${Provider.of<ComicModel>(context).title}"),
                      bottom: TabBar(
                        tabs: [Tab(text: "吐槽"), Tab(text: "设定")],
                      ),
                    ),
                    body: TabBarView(
                      children: [
                        _buildViewPoint(context),
                        _buildConfig(context)
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  Widget _buildViewer(BuildContext context) {
    if (direction) {
      return HorizontalPageView(
        key: horizontalKey,
        builder: (context, index) =>
            Provider.of<ComicModel>(context).builder(index),
        left: Provider.of<ComicModel>(context).left,
        right: Provider.of<ComicModel>(context).right,
        count: Provider.of<ComicModel>(context).length + 2,
        onEnd: Provider.of<ComicModel>(context).nextChapter,
        onTop: Provider.of<ComicModel>(context).previousChapter,
        debug: debug,
        hitBox: hitBox,
        reverse: reverse,
        onPageChange: (index) {
          // SystemChrome.setEnabledSystemUIOverlays([]);
          // setState(() {
          //   _show = false;
          // });
          Provider.of<ComicModel>(context, listen: false).index = index;
        },
        onTap: (index) {
          this.show = !this.show;
        },
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
        debug: debug,
        hitBox: hitBox,
        range: range,
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
    return SingleChildScrollView(
      child: Wrap(
        children: Provider.of<ComicModel>(context).viewPoints,
      ),
    );
  }

  Widget _buildConfig(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          title: Text("阅读方向"),
          subtitle: Text("${direction ? '横向阅读' : '纵向阅读'}"),
          onTap: () {
            _dataBase.setReadDirection(!direction);
            setState(() {
              direction = !direction;
            });
          },
        ),
        ListTile(
          title: Text('横向阅读方向'),
          subtitle: Text('${reverse ? '从右到左' : '从左到右'}'),
          enabled: direction,
          onTap: () {
            _dataBase.setHorizontalDirection(!reverse);
            setState(() {
              reverse = !reverse;
            });
          },
        ),
        Divider(),
        ListTile(
          title: Text("显示碰撞箱"),
          subtitle: Text("可以调整上下点击翻页的触发面积，由于底层架构的升级不会出现手势打架的情况了"),
          trailing: Switch(
            value: debug,
            onChanged: (state) {
              setState(() {
                debug = !debug;
              });
            },
          ),
        ),
        ListTile(
          title: Text('碰撞体积'),
          subtitle: Slider(
            min: 0,
            max: 200,
            value: hitBox,
            onChanged: (value) {
              _dataBase.setControlSize(value);
              setState(() {
                hitBox = value;
              });
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
            value: range,
            onChanged: (value) {
              _dataBase.setRange(value);
              setState(() {
                range = value;
              });
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
              children: colors
                  .map<Widget>((e) => IconButton(
                        icon: Icon(
                          Icons.color_lens,
                          color: e,
                        ),
                        onPressed: () {
                          _dataBase.setBackground(colors.indexOf(e));
                          setState(() {
                            backgroundColor = colors.indexOf(e);
                          });
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
              "chapterList: ${Provider.of<ComicModel>(context).chapterList}\n"
              "length: ${Provider.of<ComicModel>(context).length}\n"
              "pageAt: ${Provider.of<ComicModel>(context).pageAt}\n"
              "previous: ${Provider.of<ComicModel>(context).previous}\n"
              "next: ${Provider.of<ComicModel>(context).next}\n"
              "left: ${Provider.of<ComicModel>(context).left} right: ${Provider.of<ComicModel>(context).right}\n"
              ""),
        )
      ],
    );
  }

  Widget _buildSlider(context) {
    if (direction) {
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
              if (direction) {
                horizontalKey.currentState.animateToPage(index.toInt() + 1);
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
