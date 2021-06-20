import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:yin_drag_sacle/core/drag_scale_widget.dart';

import 'Common.dart';

GlobalKey<_VerticalPageView> verticalKey = GlobalKey();

class VerticalPageView extends StatefulWidget {
  final IndexedWidgetBuilder builder;
  final BoolCallback onTop;
  final BoolCallback onEnd;
  final OnPageChangeCallback onPageChange;
  final OnPageChangeCallback onTap;
  final int count;
  final int index;
  final bool left;
  final bool right;
  final double hitBox;
  final bool debug;
  final bool refreshState;
  final double range;

  VerticalPageView(
      {Key key,
      @required this.builder,
      @required this.refreshState,
      this.count,
      this.onTop,
      this.onEnd,
      this.index: 1,
      this.left,
      this.right,
      this.onPageChange,
      this.onTap,
      this.hitBox: 100,
      this.debug: false,
      this.range: 500})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _VerticalPageView();
  }
}

class _VerticalPageView extends State<VerticalPageView> {
  ScrollController _controller;
  EasyRefreshController _easyRefreshController;
  CustomDelegate _delegate;
  int index = 0;
  double position = 100;
  bool loading = false;
  StreamSubscription _channel;

  _VerticalPageView();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new ScrollController(initialScrollOffset: 0);
    print("class: VerticalPageView, action: listenChannel");
    if(Platform.isAndroid){
      _channel = EventChannel("top.hanerx/volume")
          .receiveBroadcastStream()
          .listen((event) {
        if (event == 0) {
          print("class: VerticalPageView, action: VolumeUp, event: $event");
          this.previousPage();
        } else if (event == 1) {
          print("class: VerticalPageView, action: VolumeDown, event: $event");
          this.nextPage();
        }
      });
    }

    _controller.addListener(() async {
      if (_controller.hasClients) {
        if ((_controller.position.pixels - position).abs() > 500) {
          if (widget.onPageChange != null) {
            widget.onPageChange((_delegate.first + _delegate.last) ~/ 2);
          }
          setState(() {
            position = _controller.position.pixels;
            index = (_delegate.first + _delegate.last) ~/ 2;
          });
        }
        // if (widget.count>=4&&
        //     _controller.position.pixels >=
        //         _controller.position.maxScrollExtent &&
        //     widget.onEnd != null &&
        //     !widget.refreshState &&
        //     !loading) {
        //   setState(() {
        //     loading = true;
        //   });
        //   bool flag = await widget.onEnd();
        //   if (flag) {
        //     _controller.animateTo(100,
        //         duration: Duration(microseconds: 500),
        //         curve: Curves.decelerate);
        //     if (mounted) {
        //       setState(() {
        //         loading = false;
        //       });
        //     }
        //   }
        // } else if (widget.count>=4&&
        //     _controller.position.pixels <
        //         _controller.position.minScrollExtent &&
        //     widget.onTop != null &&
        //     !widget.refreshState &&
        //     !loading) {
        //   setState(() {
        //     loading = true;
        //   });
        //   bool flag = await widget.onTop();
        //   if (flag) {
        //     _controller.animateTo(100,
        //         duration: Duration(microseconds: 500),
        //         curve: Curves.decelerate);
        //     if (mounted) {
        //       setState(() {
        //         loading = false;
        //       });
        //     }
        //   }
        // }
      }
    });
    _easyRefreshController = EasyRefreshController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> moveToTop() async {
    if (_controller.hasClients) {
      _controller.animateTo(0,
          duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    }
  }

  Future<void> previousPage()async{
    if (_controller.hasClients) {
      _controller.animateTo(_controller.position.pixels - widget.range,
          duration: Duration(milliseconds: 200), curve: Curves.decelerate);
      if(_controller.position.pixels - widget.range<=0){
        _easyRefreshController.callRefresh();
      }
    }
  }

  Future<void> nextPage()async{
    if (_controller.hasClients) {
      _controller.animateTo(_controller.position.pixels + widget.range,
          duration: Duration(milliseconds: 200), curve: Curves.decelerate);
      if(_controller.position.pixels+ widget.range>=_controller.position.maxScrollExtent){
        _easyRefreshController.callLoad();
      }
    }
  }

  void onPreviousChapter(){
    _easyRefreshController.resetLoadState();
    _easyRefreshController.finishRefresh(
        success: true, noMore: widget.left);
  }

  void onNextChapter(){
    _easyRefreshController.resetRefreshState();
    _easyRefreshController.finishLoad(
        success: true, noMore: widget.right);
  }

  @override
  Widget build(BuildContext context) {
    _delegate = new CustomDelegate((context, index) {
      return Common.builderVertical(context, index, widget.count,
          widget.builder, widget.left, widget.right,
          dense: true);
    }, widget.count);
    // TODO: implement build
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: DragScaleContainer(
            doubleTapStillScale: false,
            child: EasyRefresh.custom(
              controller: _easyRefreshController,
              scrollController: _controller,
              taskIndependence: true,
              onRefresh: () async {
                await widget.onTop();
                _easyRefreshController.resetLoadState();
                _easyRefreshController.finishRefresh(
                    success: true, noMore: widget.left);
              },
              onLoad: () async {
                await Future.delayed(Duration(seconds: 1));
                bool flag = await widget.onEnd();
                if (flag) {
                  this.moveToTop();
                }
                _easyRefreshController.resetRefreshState();
                _easyRefreshController.finishLoad(
                    success: true, noMore: widget.right);
              },
              // header: ClassicalHeader(
              //   refreshedText: '加载完成',
              //   refreshFailedText: '加载失败',
              //   refreshingText: '加载中',
              //   refreshText: '下拉加载上一话',
              //   refreshReadyText: '释放加载上一话',
              //   noMoreText: '没有更多内容了',
              // ),
              // footer: ClassicalFooter(
              //     triggerDistance: 100,
              //     loadReadyText: '上拉加载下一话',
              //     loadFailedText: '加载失败',
              //     loadingText: '加载中',
              //     loadedText: '加载完成',
              //     noMoreText: '没有更多内容了',
              //     overScroll: true),
              header: BezierCircleHeader(),
              footer: BezierBounceFooter(),
              // footer: MaterialFooter(),
              // child: ListView.custom(
              //   padding: EdgeInsets.zero,
              //   controller: _controller,
              //   childrenDelegate: _delegate,
              // ),
              slivers: [
                SliverList(
                  delegate: _delegate,
                )
              ],
            ),
          ),
        ),
        Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                height: widget.hitBox,
                child: widget.debug
                    ? Container(
                        color: Color.fromARGB(70, 0, 0, 0),
                      )
                    : null,
              ),
              onTap: () {
                this.previousPage();
              },
            )),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                height: widget.hitBox,
                child: widget.debug
                    ? Container(
                        color: Color.fromARGB(70, 0, 0, 0),
                      )
                    : null,
              ),
              onTap: () {
                this.nextPage();
              },
            )),
        Positioned(
          left: 0,
          right: 0,
          bottom: widget.hitBox,
          top: widget.hitBox,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: widget.debug
                ? Container(
                    color: Color.fromARGB(70, 0, 100, 255),
                  )
                : null,
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap(_delegate.last);
              }
            },
          ),
        )
      ],
    );
  }

  double get value {
    if (_controller.hasClients) {
      return _controller.position.pixels;
    }
    return 100;
  }

  double get max {
    if (_controller.hasClients) {
      return _controller.position.maxScrollExtent;
    }
    return 0;
  }

  set value(double value) {
    if (_controller.hasClients) {
      _controller.animateTo(value,
          duration: Duration(microseconds: 500), curve: Curves.decelerate);
    }
  }
}

class CustomDelegate extends SliverChildBuilderDelegate {
  int last = 0;
  int first = 0;

  CustomDelegate(builder, int count) : super(builder, childCount: count);

  @override
  double estimateMaxScrollOffset(int firstIndex, int lastIndex,
      double leadingScrollOffset, double trailingScrollOffset) {
    // TODO: implement estimateMaxScrollOffset
    return super.estimateMaxScrollOffset(
        firstIndex, lastIndex, leadingScrollOffset, trailingScrollOffset);
  }

  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    // TODO: implement didFinishLayout
    if (lastIndex != last) {
      last = lastIndex;
    }
    if (firstIndex != first) {
      first = firstIndex;
    }
    super.didFinishLayout(firstIndex, lastIndex);
  }

  @override
  // TODO: implement addAutomaticKeepAlives
  bool get addAutomaticKeepAlives => true;

  @override
  // TODO: implement addRepaintBoundaries
  bool get addRepaintBoundaries => true;

  @override
  // TODO: implement addSemanticIndexes
  bool get addSemanticIndexes => true;
}
