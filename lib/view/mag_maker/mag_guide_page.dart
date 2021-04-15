import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:code_editor/code_editor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:dcomic/component/CustomDrawer.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:pretty_json/pretty_json.dart';

class MagGuidePage extends StatefulWidget {
  final GuideChapter guide;

  const MagGuidePage({Key key, this.guide}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MagGuidePage();
  }
}

class _MagGuidePage extends State<MagGuidePage> {
  String _code = '';
  String _text = '';

  String get code => _code;

  String get text => _text;

  set code(String code) {
    setState(() {
      _code = code;
    });
  }

  set text(String text) {
    setState(() {
      _text = text;
    });
  }

  int _index = 0;

  set index(int index) {
    setState(() {
      _index = index;
    });
  }

  int get index => _index;

  int step = 0;
  bool _play = true;

  Timer _mainTimer;
  Timer timer;
  Lock lock = Lock();

  int stepDuration = 100;
  int duration = 2;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    play();
  }

  play() async {
    _mainTimer = Timer.periodic(Duration(seconds: duration), (timer) async {
      if (_index >= widget.guide.length) {
        _mainTimer.cancel();
        return;
      }
      if (!lock.locked) {
        await show(widget.guide[_index]);
      }
    });
  }

  show(GuideAction data, {animate: true}) async {
    lock.lock();
    if (_index < 0 || _index >= widget.guide.length) {
      lock.unlock();
      return;
    }
    data.show(this, animate: animate);
  }

  showStep(data, type) async {
    if (step >= data.length) {
      setState(() {
        step = 0;
        _index++;
      });
      timer.cancel();
      lock.unlock();
      return;
    }
    if (type == GuideType.showText) {
      setState(() {
        _text += data[step];
        step++;
      });
    } else if (type == GuideType.showCode) {
      setState(() {
        _code += data[step];
        step++;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_mainTimer != null) {
      _mainTimer.cancel();
    }
    if (timer != null) {
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('新手上路'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.arrow_left), title: Text('上一步')),
          BottomNavigationBarItem(
              icon: Icon(_play ? Icons.pause : Icons.play_arrow),
              title: Text(_play ? '暂停' : '播放')),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: Text('设置')),
          BottomNavigationBarItem(
              icon: Icon(Icons.arrow_right), title: Text('下一步'))
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              _mainTimer.cancel();
              timer.cancel();
              lock.unlock();
              setState(() {
                _play = false;
                if (step == 0) {
                  if (_index > 0) {
                    _index--;
                  } else {
                    _index = 0;
                  }
                }
                step = 0;
              });
              show(widget.guide[_index], animate: false);
              break;
            case 1:
              setState(() {
                _play = !_play;
              });
              if (_play) {
                play();
              } else {
                _mainTimer.cancel();
                timer.cancel();
                lock.unlock();
              }
              break;
            case 2:
              showModalBottomSheet(
                  context: context,
                  builder: (context) => StatefulBuilder(
                        builder: (context,
                                void Function(void Function()) setState) =>
                            Container(
                          height: 200,
                          child: ListView(
                            padding: EdgeInsets.only(top: 20),
                            children: [
                              ListTile(
                                title: Text('打字间隔时间(ms)'),
                                subtitle: Slider(
                                  value: stepDuration.toDouble(),
                                  min: 0,
                                  max: 1000,
                                  divisions: 100,
                                  onChanged: (value) {
                                    setState(() {
                                      stepDuration = value.toInt();
                                    });
                                  },
                                  label: '$stepDuration',
                                ),
                              ),
                              ListTile(
                                title: Text('间隔时间(s)'),
                                subtitle: Slider(
                                  value: duration.toDouble(),
                                  min: 1,
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (value) {
                                    setState(() {
                                      duration = value.toInt();
                                    });
                                  },
                                  label: '$duration',
                                ),
                              )
                            ],
                          ),
                        ),
                      ));
              break;
            case 3:
              _mainTimer.cancel();
              timer.cancel();
              lock.unlock();
              setState(() {
                _play = false;
                if (step == 0) {
                  if (_index < widget.guide.length - 1) {
                    _index++;
                  } else {
                    _index = widget.guide.length - 1;
                  }
                }
                step = 0;
              });
              show(widget.guide[_index], animate: false);
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
              return SingleChildScrollView(
                  child: JsonViewerWidget(jsonDecode(_code)));
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
              FileEditor(code: _code, language: 'json', name: 'meta.json')
            ]),
            onSubmit: (lang, value) {
              setState(() {
                _code = value;
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
                      child: MarkdownWidget(data: '$_text'),
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

enum GuideType { showText, showCode, showDrawer, closeDrawer }

class GuideChapter {
  GuideChapter();

  Future<void> initFromString(String string) async {
    var data = jsonDecode(string);
    for (var item in data) {
      _list.add(await parse(item));
    }
  }

  Future<GuideAction> parse(Map map) async {
    switch (GuideType.values[map['type']]) {
      case GuideType.showText:
        if (map['data'] is String) {
          return TextAction(map['data'], replace: map['replace']);
        } else if (map['data'] is Map) {
          switch (map['data']['type']) {
            case 0:
              File file = File(map['data']['path']);
              if (await file.exists()) {
                return TextAction(await file.readAsString(),
                    replace: map['replace']);
              }
              break;
            case 1:
              return TextAction(
                  await rootBundle.loadString(map['data']['path']),
                  replace: map['replace']);
              break;
            case 2:
              return TextAction(prettyJson(map['data']['data']),
                  replace: map['replace']);
              break;
          }
        }
        return TextAction('', replace: false);
        break;
      case GuideType.showCode:
        if (map['data'] is String) {
          return CodeAction(map['data'], replace: map['replace']);
        } else if (map['data'] is Map) {
          switch (map['data']['type']) {
            case 0:
              File file = File(map['data']['path']);
              if (await file.exists()) {
                return CodeAction(await file.readAsString(),
                    replace: map['replace']);
              }
              break;
            case 1:
              return CodeAction(
                  await rootBundle.loadString(map['data']['path']),
                  replace: map['replace']);
              break;
            case 2:
              return CodeAction(prettyJson(map['data']['data']),
                  replace: map['replace']);
              break;
          }
        }
        return CodeAction('', replace: false);
        break;
      case GuideType.showDrawer:
        return OpenDrawerAction();
        break;
      case GuideType.closeDrawer:
        return CloseDrawerAction();
        break;
    }
    return null;
  }

  List<GuideAction> _list = [];

  int get length => _list.length;

  GuideAction operator [](int index) {
    // TODO: implement ==
    return _list[index];
  }
}

abstract class GuideAction {
  GuideType get type;

  show(_MagGuidePage state, {bool animate: true});
}

abstract class StringAction extends GuideAction {
  String data;
  bool replace;

  StringAction(this.data, {this.replace: true});

  @override
  show(_MagGuidePage state, {bool animate: true}) {
    // TODO: implement show
    if (animate) {
      state.timer = Timer.periodic(Duration(milliseconds: state.stepDuration),
          (timer) async {
        await state.showStep(data, type);
      });
    }
  }
}

class TextAction extends StringAction {
  TextAction(data, {replace}) : super(data, replace: replace);

  @override
  // TODO: implement type
  GuideType get type => GuideType.showText;

  @override
  show(_MagGuidePage state, {bool animate: true}) {
    // TODO: implement show
    if (animate) {
      if (replace && state.step == 0) {
        state.text = '';
      }
      return super.show(state, animate: animate);
    } else {
      if (replace) {
        state.text = data;
      } else {
        state.text += data;
      }
      state.lock.unlock();
    }
  }
}

class CodeAction extends StringAction {
  CodeAction(data, {replace}) : super(data, replace: replace);

  @override
  // TODO: implement type
  GuideType get type => GuideType.showCode;

  @override
  show(_MagGuidePage state, {bool animate: true}) {
    // TODO: implement show
    if (animate) {
      if (replace && state.step == 0) {
        state.code = '';
      }
      return super.show(state, animate: animate);
    } else {
      if (replace) {
        state.code = data;
      } else {
        state.code += data;
      }
      state.lock.unlock();
    }
  }
}

class OpenDrawerAction extends GuideAction {
  @override
  show(_MagGuidePage state, {bool animate = true}) {
    // TODO: implement show
    if (animate) {
      state.scaffoldKey.currentState.openEndDrawer();
      state.index++;
    }
    state.lock.unlock();
  }

  @override
  // TODO: implement type
  GuideType get type => GuideType.showDrawer;
}

class CloseDrawerAction extends GuideAction {
  @override
  show(_MagGuidePage state, {bool animate = true}) {
    // TODO: implement show
    if (animate) {
      Navigator.of(state.context).pop();
      state.index++;
    }
    state.lock.unlock();
  }

  @override
  // TODO: implement type
  GuideType get type => GuideType.closeDrawer;
}
