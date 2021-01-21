import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:yin_drag_sacle/core/drag_scale_widget.dart';

import 'Common.dart';

GlobalKey<_HorizontalPageView> horizontalKey=GlobalKey();

class HorizontalPageView extends StatefulWidget {
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
  final bool enableClick;
  final PageController controller;
  final bool reverse;

  const HorizontalPageView(
      {Key key,
      this.builder,
      this.onTop,
      this.onEnd,
      this.count,
      this.index,
      this.left,
      this.right,
      this.hitBox: 100,
      this.onPageChange,
      this.controller,
      this.onTap,
      this.debug = false,
      this.enableClick, this.reverse})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HorizontalPageView();
  }
}

class _HorizontalPageView extends State<HorizontalPageView> {
  int index;
  PageController _controller;
  StreamSubscription _channel;

  _HorizontalPageView() {
    _controller = PageController(initialPage: 1);
    print("class: HorizontalPageView, action: listenChannel");
    _channel = EventChannel("top.hanerx/volume")
        .receiveBroadcastStream()
        .listen((event) {
      if (event == 0) {
        print("class: HorizontalPageView, action: VolumeUp, event: $event");
        if (_controller.hasClients) {
          if(widget.reverse){
            _controller.nextPage(
                duration: Duration(milliseconds: 200), curve: Curves.easeIn);
          }else{
            _controller.previousPage(
                duration: Duration(milliseconds: 200), curve: Curves.easeIn);
          }
        }
      } else if (event == 1) {
        print("class: HorizontalPageView, action: VolumeDown, event: $event");
        if (_controller.hasClients) {
          if(widget.reverse){
            _controller.previousPage(
                duration: Duration(milliseconds: 200), curve: Curves.easeIn);
          }else{
            _controller.nextPage(
                duration: Duration(milliseconds: 200), curve: Curves.easeIn);
          }
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> moveToTop()async{
    if (_controller.hasClients) {
      _controller.animateToPage(1, duration: Duration(microseconds: 500), curve: Curves.decelerate);
    }
  }

  Future<void> animateToPage(int index)async{
    if (_controller.hasClients) {
      _controller.animateToPage(index, duration: Duration(microseconds: 500), curve: Curves.decelerate);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        DragScaleContainer(
          doubleTapStillScale: false,
          child: _buildViewer(context),
        ),
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: SizedBox(
              width: widget.hitBox,
              child: widget.debug
                  ? Container(
                      color: Color.fromARGB(70, 0, 0, 0),
                    )
                  : null,
            ),
            onTap: () {
              if (_controller.hasClients) {
                if(widget.reverse){
                  _controller.nextPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeIn);
                }else{
                  _controller.previousPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeIn);
                }
              }
            },
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: SizedBox(
              width: widget.hitBox,
              child: widget.debug
                  ? Container(
                      color: Color.fromARGB(70, 0, 0, 0),
                    )
                  : null,
            ),
            onTap: () {
              if (_controller.hasClients) {
                if(widget.reverse){
                  _controller.previousPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeIn);
                }else{
                  _controller.nextPage(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeIn);
                }
              }
            },
          ),
        ),
        Positioned(
          left: widget.hitBox,
          right: widget.hitBox,
          bottom: 0,
          top: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: widget.debug
                ? Container(
                    color: Color.fromARGB(70, 0, 100, 255),
                  )
                : null,
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap(index);
              }
            },
          ),
        )
      ],
    );
  }

  Widget _buildViewer(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      onPageChanged: (index) async {
        if (widget.onPageChange != null) {
          widget.onPageChange(index - 1);
        }
        setState(() {
          this.index = index;
        });
        if (index == 0 && widget.onTop != null) {
          bool flag = await widget.onTop();
          if (flag && _controller.hasClients) {
            // _controller.nextPage(
            //     duration: Duration(seconds: 1), curve: Curves.decelerate);
            _controller.animateToPage(1, duration: Duration(microseconds: 500), curve: Curves.decelerate);
          }
        } else if (widget.count != null &&
            index >= widget.count-1 &&
            widget.onEnd != null) {
          bool flag = await widget.onEnd();
          if (flag && _controller.hasClients) {
            _controller.animateToPage(1,
                duration: Duration(microseconds: 500), curve: Curves.decelerate);
          }
        }
      },
      reverse: widget.reverse,
      itemCount: widget.count,
      itemBuilder: (context, index) {
        return Common.builder(context, index, widget.count, widget.builder,
            widget.left, widget.right,
            dense: false);
      },
    );
  }
}
