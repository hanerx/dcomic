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
  var channel=MethodChannel('top.hanerx/ipfs-lite');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // startPeer();
    print(DateTime.now().millisecondsSinceEpoch);
  }

  startPeer()async{
    try{
      channel.invokeMethod('startPeer',{'debug':false,'path':(await getTemporaryDirectory()).path+'/ipfs/'});
    }catch(e){
      print('started');
    }
  }

  stopPeer()async{
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
              text: 'IPFS测试',
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
                      var response = await UniversalRequestModel()
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
                      print((await KuKuSourceModel().get(title: '哥布林杀手')).getChapters());
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
              var response = await CustomHttp().getSubscribeWeb();
              if (response.statusCode == 200) {
                var list = jsonDecode(response.data);
                for (var item in list) {
                  var data =
                      await Provider.of<SourceProvider>(context, listen: false)
                          .active
                          .get(comicId: item['sub_id'].toString());
                  setState(() {
                    _subs.add(data);
                  });
                }
              }
            },
            child: ListView.builder(
              itemBuilder: (context, index) {
                var data = _subs[index];
                return _CustomListTile(
                    data.cover,
                    data.title,
                    data.tags.map((e) => e['tag_name']).toList().join('/'),
                    data.updateTime,
                    data.comicId,
                    data.authors.map((e) => e['tag_name']).toList().join('/'));
              },
              itemCount: _subs.length,
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  OutlineButton(
                    child: Text('启动IPFS本地服务器'),
                    onPressed: ()async{
                      startPeer();
                    },
                  ),
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


                      print('start cat peer');
                      Uint8List data=await channel.invokeMethod('cat',{'cid':'QmSY5BqPor7aQD8EsSJvXdixkgLoAdQHP3uq5yX28jGwsT'});
                      print(data);
                      setState(() {
                        image=data;
                      });
                    },
                  ),
                  image==null?Text('还没返回值'):Image.memory(image)
                ],
              ),
            ),
          ),
          Center(
            child: CachedNetworkImage(
              imageUrl: 'https://i.pximg.net/img-original/img/2019/08/04/00/12/45/76062188_p0.jpg',
              cacheManager: ProxyCacheManager('192.168.123.47', 7890),
              httpHeaders: {'referer':'https://www.pixiv.net/'},
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
        }));
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
