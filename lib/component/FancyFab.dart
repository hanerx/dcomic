import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class FancyFab extends StatefulWidget {
  final bool reverse;
  final VoidCallback onSort;
  final VoidCallback onPlay;
  final VoidCallback onBlackBox;
  final VoidCallback onDownload;

  FancyFab({this.reverse: false, this.onSort, this.onPlay, this.onBlackBox,this.onDownload});

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.orange,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget download(){
    return Container(
      child: FloatingActionButton(
        onPressed: (){
          animate();
          widget.onDownload();
        },
        heroTag: "download",
        tooltip: '下载',
        backgroundColor: Colors.deepOrange,
        elevation: isOpened ? 16 : 0,
        child: Icon(Icons.file_download),
      ),
    );
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        onPressed: (){
          animate();
          widget.onBlackBox();
        },
        heroTag: "inbox",
        tooltip: '黑匣子',
        backgroundColor: Colors.black,
        elevation: isOpened ? 16 : 0,
        child: Icon(Icons.inbox),
      ),
    );
  }

  Widget image() {
    return Container(
      child: FloatingActionButton(
        heroTag: "order",
        onPressed: widget.onSort,
        backgroundColor: Colors.green,
        tooltip: '排序',
        elevation: isOpened ? 16 : 0,
        child: Icon(widget.reverse
            ? FontAwesome5.sort_amount_down_alt
            : FontAwesome5.sort_amount_down),
      ),
    );
  }

  Widget inbox() {
    return Container(
      child: FloatingActionButton(
        onPressed: (){
          animate();
          widget.onPlay();
        },
        heroTag: "play",
        tooltip: '继续阅读',
        elevation: isOpened ? 16 : 0,
        child: Icon(Icons.play_arrow),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: '菜单',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 4.0,
            0.0,
          ),
          child: download(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 3.0,
            0.0,
          ),
          child: add(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: image(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: inbox(),
        ),
        toggle(),
      ],
    );
  }
}
