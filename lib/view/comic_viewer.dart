import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdmzj/component/CustomDrawer.dart';
import 'package:flutterdmzj/component/comic_viewer/ComicPage.dart';
import 'package:flutterdmzj/component/comic_viewer/HorizontalPageView.dart';
import 'package:flutterdmzj/component/comic_viewer/VerticalPageView.dart';
import 'package:flutterdmzj/database/database.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/comic.dart';
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
    setState(() {
      this.hitBox = hitBox;
      this.range = range;
      this.direction = direction;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
        create: (_) =>
            ComicModel(widget.comicId, widget.chapterId, widget.chapterList),
        builder: (context, test) {
          return Scaffold(
              body: _buildViewer(context),
              endDrawer: CustomDrawer(
                widthPercent: 0.9,
                child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: AppBar(
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
        key: GlobalKey(),
        builder: (context, index) =>
            Provider.of<ComicModel>(context).builder(index),
        left: Provider.of<ComicModel>(context).left,
        right: Provider.of<ComicModel>(context).right,
        count: Provider.of<ComicModel>(context).length + 1,
        onEnd: Provider.of<ComicModel>(context).nextChapter,
        onTop: Provider.of<ComicModel>(context).previousChapter,
        debug: debug,
        hitBox: hitBox,
        onPageChange: (index) {
          SystemChrome.setEnabledSystemUIOverlays([]);
        },
        onTap: (index) {
          SystemChrome.setEnabledSystemUIOverlays(
              [SystemUiOverlay.top, SystemUiOverlay.bottom]);
        },
      );
    } else {
      return VerticalPageView(
        key: GlobalKey(),
        builder: (context, index) =>
            Provider.of<ComicModel>(context).builder(index),
        refreshState: Provider.of<ComicModel>(context).refreshState,
        left: Provider.of<ComicModel>(context).left,
        right: Provider.of<ComicModel>(context).right,
        count: Provider.of<ComicModel>(context).length + 1,
        onEnd: Provider.of<ComicModel>(context).nextChapter,
        onTop: Provider.of<ComicModel>(context).previousChapter,
        debug: debug,
        hitBox: hitBox,
        range: range,
        onPageChange: (index) {
          SystemChrome.setEnabledSystemUIOverlays([]);
        },
        onTap: (index) {
          SystemChrome.setEnabledSystemUIOverlays(
              [SystemUiOverlay.top, SystemUiOverlay.bottom]);
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
}
