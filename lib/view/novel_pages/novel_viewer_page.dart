import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterdmzj/model/novel.dart';
import 'package:provider/provider.dart';

class NovelViewerPage extends StatefulWidget {
  final String title;
  final List chapters;
  final int novelID;
  final int volumeID;
  final int chapterID;

  const NovelViewerPage(
      {Key key,
      this.title,
      this.chapters,
      this.novelID,
      this.volumeID,
      this.chapterID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelViewerPage();
  }
}

class _NovelViewerPage extends State<NovelViewerPage>
    with SingleTickerProviderStateMixin {
  bool _show = false;
  ScrollController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller=ScrollController();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top,SystemUiOverlay.bottom]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => NovelModel(widget.title, widget.chapters, widget.novelID,
          widget.volumeID, widget.chapterID),
      builder: (context, child) {
        return Scaffold(
          endDrawer: Drawer(
            child: Scaffold(
              appBar: AppBar(
                title: Text('目录'),
                backgroundColor: Colors.black54,
              ),
              body: SingleChildScrollView(
                child: ExpansionPanelList(
                  expansionCallback: Provider.of<NovelModel>(context).setExpand,
                  children: Provider.of<NovelModel>(context)
                      .buildChapterWidget(context),
                ),
              ),
            ),
          ),
          body: GestureDetector(
            onTap: () {
              setState(() {
                _show=!_show;
              });
              if(_show){
                SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top,SystemUiOverlay.bottom]);
              }else{
                SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
              }
            },
            child: Stack(
              children: [
                EasyRefresh(
                  scrollController: ScrollController(),
                  header: BezierCircleHeader(),
                  footer: BezierBounceFooter(),
                  child: SingleChildScrollView(
                      controller: _controller,
                      child: Column(
                        children: [
                          HtmlWidget(Provider.of<NovelModel>(context).data),
                          Container(
                            height: 70,
                          )
                        ],
                      ),
                  ),
                  onRefresh: ()async{
                    await Provider.of<NovelModel>(context,listen: false).previous();
                  },
                  onLoad: ()async{
                    await Future.delayed(Duration(seconds: 1));
                    await Provider.of<NovelModel>(context,listen: false).next();
                    if(_controller.hasClients){
                      _controller.animateTo(0, duration: Duration(microseconds: 100), curve: Curves.easeIn);
                    }
                  },
                ),
                AnimatedPositioned(
                  duration: Duration(milliseconds: 200),
                  top: _show?0:-80,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: AppBar(
                    title: Text('${Provider.of<NovelModel>(context).title}'),
                    backgroundColor: Colors.black54,
                  ),
                ),

                AnimatedPositioned(
                  duration: Duration(milliseconds: 200),
                  bottom: _show?0:-70,
                  left: 0,
                  right: 0,
                  height: 70,
                  child: Builder(
                    builder: (context){
                      return BottomNavigationBarTheme(
                        data: BottomNavigationBarThemeData(
                          selectedItemColor: Colors.white
                        ),
                        child: BottomNavigationBar(
                          onTap: (index)async{
                            switch(index){
                              case 0:
                                await Provider.of<NovelModel>(context,listen: false).previous();
                                _controller.animateTo(0, duration: Duration(microseconds: 100), curve: Curves.easeIn);
                                break;
                              case 1:
                                Scaffold.of(context).openEndDrawer();
                                break;
                              case 2:
                                await Provider.of<NovelModel>(context,listen: false).next();
                                _controller.animateTo(0, duration: Duration(microseconds: 100), curve: Curves.easeIn);
                                break;
                            }
                          },
                          backgroundColor: Colors.black54,
                          unselectedItemColor: Colors.white,
                          unselectedLabelStyle: TextStyle(color: Colors.white),
                          currentIndex: 1,
                          items: [
                            BottomNavigationBarItem(
                              title: Text('上一话'),
                              icon: Icon(Icons.arrow_drop_up),
                            ),
                            BottomNavigationBarItem(
                              title: Text('目录'),
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
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
