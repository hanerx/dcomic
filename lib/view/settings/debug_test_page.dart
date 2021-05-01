import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/comic_source/KuKuSourceModel.dart';
import 'package:dcomic/model/comic_source/ManHuaGuiSourceModel.dart';
import 'package:dcomic/model/comic_source/MangabzSourceModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/utils/ProxyCacheManager.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ipfs/ipfs.dart';

import '../comic_detail_page.dart';

class DebugTestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DebugTestPage();
  }
}

class _DebugTestPage extends State<DebugTestPage> {
  String _data;
  List<ComicDetail> _subs = [];
  var image;
  var channel = MethodChannel('top.hanerx/ipfs-lite');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // startPeer();
    print(DateTime.now().millisecondsSinceEpoch);
  }

  startPeer() async {
    try {
      channel.invokeMethod('startPeer', {
        'debug': false,
        'path': (await getTemporaryDirectory()).path + '/ipfs/'
      });
    } catch (e) {
      print('started');
    }
  }

  stopPeer() async {
    channel.invokeMethod('stopPeer');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stopPeer();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).SettingPageDebugTestTitle),
          bottom: TabBar(isScrollable: true, tabs: [
            Tab(
              text: 'mangabz漫画爬取',
            ),
            Tab(
              text: 'kuku搜索爬取',
            ),
            Tab(
              text: 'mangabz漫画获取',
            ),
            Tab(
              text: '漫画台搜索爬取',
            ),
            Tab(
              text: '获取订阅',
            ),
            Tab(
              text: 'Decode',
            ),
            Tab(
              text: '代理图片测试',
            )
          ]),
        ),
        body: TabBarView(children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: () async {
                      var response = await UniversalRequestModel
                          .mangabzRequestHandler
                          .getChapterImage('m161157', 0);
                      var data =
                          await ToolMethods.eval(response.data.toString());
                      setState(() {
                        _data =
                            '${response.data.toString()}\n${jsonDecode(data)}';
                      });
                    },
                  ),
                  Text('$_data')
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: () async {
                      print((await KuKuSourceModel().get(title: '哥布林杀手'))
                          .getChapters());
                    },
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: () async {
                      print(await MangabzSourceModel().get(title: '想要成为影之实力者'));
                    },
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: () async {
                      var comic = await (await ManHuaGuiSourceModel()
                              .get(title: 'EX-ARM'))
                          .getChapter(chapterId: '467538');
                      comic.init();
                    },
                  )
                ],
              ),
            ),
          ),
          EasyRefresh(
            onRefresh: () async {
              // var response = await CustomHttp().getSubscribeWeb();
              // if (response.statusCode == 200) {
              //   var list = jsonDecode(response.data);
              //   for (var item in list) {
              //     var data =
              //         await Provider.of<SourceProvider>(context, listen: false)
              //             .active
              //             .get(comicId: item['sub_id'].toString());
              //     setState(() {
              //       _subs.add(data);
              //     });
              //   }
              // }
            },
            child: ListView.builder(
              itemBuilder: (context, index) {
                var data = _subs[index];
                return _CustomListTile(
                    data.cover,
                    data.title,
                    data.tags.map((e) => e.title).toList().join('/'),
                    data.updateTime,
                    data.comicId,
                    data.authors.map((e) => e.title).toList().join('/'));
              },
              itemCount: _subs.length,
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('Test'),
                    onPressed: () async {
                      // Ipfs ipfs = Ipfs(baseUrl: 'hanerx.top',port: 5001);
                      // ipfs.getPeers();
                      // String cid = 'QmSY5BqPor7aQD8EsSJvXdixkgLoAdQHP3uq5yX28jGwsT';
                      // var item=await ipfs.catObject(cid);
                      // setState(() {
                      //   image=Uint8List.fromList(item);
                      // });

                      var data=ToolMethods.decrypt("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");
                    print(data);
                    print(utf8.decode(unicode2utf8(data)));

                      },
                  )
                ],
              ),
            ),
          ),
          Center(
            child: CachedNetworkImage(
              imageUrl:
                  'https://i.pximg.net/img-original/img/2019/08/04/00/12/45/76062188_p0.jpg',
              // cacheManager: ProxyCacheManager('192.168.123.47', 7890),
              httpHeaders: {'referer': 'https://www.pixiv.net/'},
            ),
          )
        ]),
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String types;
  final String date;
  final String authors;
  final String comicId;

  _CustomListTile(this.cover, this.title, this.types, this.date, this.comicId,
      this.authors);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ComicDetailPage(
            id: comicId,
            title: title,
          );
        },settings: RouteSettings(name: 'comic_detail_page')));
      },
      child: Card(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: '$cover',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                child:
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: 100,
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.supervisor_account,
                              color: Colors.grey[500],
                            ),
                            Text(
                              authors,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.category,
                              color: Colors.grey[500],
                            ),
                            Text(
                              types,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.history,
                              color: Colors.grey[500],
                            ),
                            Text(
                              date,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    ));
  }
}
