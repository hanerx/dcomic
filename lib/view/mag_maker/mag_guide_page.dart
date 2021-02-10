import 'dart:convert';
import 'dart:async';

import 'package:code_editor/code_editor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:flutterdmzj/component/CustomDrawer.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:markdown_widget/markdown_helper.dart';

class MagGuidePage extends StatefulWidget {
  final List guide;

  const MagGuidePage({Key key, this.guide}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MagGuidePage();
  }
}

class _MagGuidePage extends State<MagGuidePage> {
  String code = '';
  String text = '';

  int _index = 0;
  int _step = 0;
  bool _play = true;

  Timer _mainTimer;
  Timer _timer;
  Lock _lock=Lock();

  GlobalKey<ScaffoldState> _scaffoldKey=GlobalKey();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    play();
  }

  play() async {
    _mainTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_index >= widget.guide.length) {
        _mainTimer.cancel();
        return;
      }
      if(!_lock.locked){
        await show(widget.guide[_index]);
      }
    });
  }

  show(data,{animate:true}) async {
    _lock.lock();
    if(_index<0||_index>=widget.guide.length){
      _lock.unlock();
      return;
    }
    switch (data['type']) {
      case 0:
        if(data['replace']&&_step==0){
          setState(() {
            text='';
          });
        }
        if(animate){
          _timer=Timer.periodic(Duration(milliseconds: 100), (timer) async{await showStep(data['data'], 0); });
        }else{
          setState(() {
            text=data['data'];
          });
          _lock.unlock();
        }
        break;
      case 1:
        if(data['replace']&&_step==0){
          setState(() {
            code='';
          });
        }
        if(animate){
          _timer=Timer.periodic(Duration(milliseconds: 100), (timer) async{await showStep(data['data'], 1); });
        }else{
          setState(() {
            code=data['data'];
          });
          _lock.unlock();
        }
        break;
      case 2:
        if(animate){
          _scaffoldKey.currentState.openEndDrawer();
          setState(() {
            _index++;
          });
        }
        _lock.unlock();
        break;
      case 3:
        if(animate){
          Navigator.of(context).pop();
          setState(() {
            _index++;
          });
        }
        _lock.unlock();
        break;
    }
  }

  showStep(data, type) async {
    if (_step >= data.length) {
      setState(() {
        _step = 0;
        _index++;
      });
      _timer.cancel();
      _lock.unlock();
      return;
    }
    if (type == 0) {
      setState(() {
        text += data[_step];
        _step++;
      });
    } else {
      setState(() {
        code += data[_step];
        _step++;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(_mainTimer!=null){
      _mainTimer.cancel();
    }
    if(_timer!=null){
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('新手上路'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.arrow_left), title: Text('上一步')),
          BottomNavigationBarItem(
              icon: Icon(_play?Icons.pause:Icons.play_arrow), title: Text(_play?'暂停':'播放')),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text('设置')),
          BottomNavigationBarItem(
              icon: Icon(Icons.arrow_right), title: Text('下一步'))
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              _mainTimer.cancel();
              _timer.cancel();
              _lock.unlock();
              setState(() {
                _play=false;
                if(_step==0){
                  if(_index>0){
                    _index--;
                  }else{
                    _index=0;
                  }
                }
                _step=0;
              });
              show(widget.guide[_index],animate: false);
              break;
            case 1:
              setState(() {
                _play = !_play;
              });
              if (_play) {
                play();
              }else{
                _mainTimer.cancel();
                _timer.cancel();
                _lock.unlock();
              }
              break;
            case 3:
              _mainTimer.cancel();
              _timer.cancel();
              _lock.unlock();
              setState(() {
                _play=false;
                if(_step==0){
                  if(_index<widget.guide.length-1){
                    _index++;
                  }else{
                    _index=widget.guide.length-1;
                  }
                }
                _step=0;
              });
              show(widget.guide[_index],animate: false);
              break;
          }
        },
      ),
      endDrawer: CustomDrawer(
        widthPercent: 0.9,
        child: Scaffold(
          appBar: AppBar(
            title: Text('新手上路'),
          ),
          body: Builder(builder: (context) {
            try {
              return JsonViewerWidget(jsonDecode(code));
            } catch (e) {
              return Center(
                child: Text('你的json好像没写对啊，没法渲染啊'),
              );
            }
          }),
        ),
      ),
      body: Column(
        children: [
          CodeEditor(
            model: EditorModel(files: [
              FileEditor(code: code, language: 'json', name: 'meta.json')
            ]),
            onSubmit: (lang, value) {
              setState(() {
                code = value;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(FontAwesome5.quote_left),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text('$text'),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
