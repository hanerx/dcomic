import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/model/comic_source/KuKuSourceModel.dart';
import 'package:dcomic/model/comic_source/ManHuaGuiSourceModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/utils/ProxyCacheManager.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:path_provider/path_provider.dart';

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
  // var channel = MethodChannel('top.hanerx/ipfs-lite');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // startPeer();
    print(DateTime.now().millisecondsSinceEpoch);
  }

  // startPeer() async {
  //   try {
  //     channel.invokeMethod('startPeer', {
  //       'debug': false,
  //       'path': (await getTemporaryDirectory()).path + '/ipfs/'
  //     });
  //   } catch (e) {
  //     print('started');
  //   }
  // }
  //
  // stopPeer() async {
  //   channel.invokeMethod('stopPeer');
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // stopPeer();
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
                      final Trace myTrace = FirebasePerformance.instance.newTrace("test_trace");
                      myTrace.start();

                      var item="";
                      if (item != null) {
                        myTrace.incrementMetric("item_cache_hit", 1);
                      } else {
                        myTrace.incrementMetric("item_cache_miss", 1);
                      }

                      myTrace.stop();
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

                      // var response=await UniversalRequestModel.dmzjv4requestHandler.getComicDetail('51433');
                      // print(response);
                      var decode=ToolMethods.decrypt('cbiR0cnlxmKMRtwW73X2r2yigUC8PUrBcMuU7C8R2bIpN/A+LJN6HPkTA+yuun3AT910BB0UIdJdSep+RPQ5ZrZJKdy1A7JSX4fUxfprD0p/LgeLn24bzOm8kB/mx8RDdnQB7Ju98NE+e03dO+gOKrHqnNhak8RsQpHbHoKiR3erArBrPbh9irenSMKFGArx7yP9com3Qwawy4v30vfZLWw83EXrDMpJmtc9aYIEkJFF43/7Y59H+m6IxV7l4DOr5LT4fxB637t2+eBvqb7Jo4XmG1NPKKBfga/d7PvpKjVpVYQ+KU5xRPhJm5Zz29x5KbdJ/K6elWOtBcMnCrz4onKKsTORorgw5sWZu9iafIm++Xoe9Nwj+t7ng55hI3TxbmPV6bXuVqOsCUixLHyhMw7uBdYYYXOpd2OTGzWgrrwk0qVTWU8A/x1oZwptmfmDzwooVYhQdVoi28CIztdqddTz+oA3sWdwhchq3PC08r1o5tGgsrWMH63PlqQabAAwMKg0ZqOZb7f4WtW9ving/G8G6MwTn1N7FeKIZdOBWsoSbfZE+7BXbd7McefCWOFLg55ctk06omTayykh3HnnJv3L7xEmAWEhu39c9tFXr3EMrHsxJ0FGRcO4sxBJrx1bZ+EgI1MU6EnZTitHyEbdkEbjcqlFqiZBIKJCra7CtdQvRYKpVHXcvG+tNNBSeQuf6fLqey9Dv2EaIxK+Jxzu2phexBu5IAivf1nf4OD+jok46Utv1+pmjRd82xwc3xfljdbn38f6bR8HVc7P2QbIPVLX+aa+bqDBPNDuj76ukqYZVnwfdEmbcczSvLsh1HXH2YSFyB96Zl4YnJEIVWx4g6sCnpPm3AB/9AqPM0kFWko3Fx9B3GGo/VAQgoQL1qefBwh3oEH3jOltmKXIXXOY6shb5F+kpAG1+o32KvxRUn3HJr/ooxNVfhIB3ZtXZyv6i2ibu7+rsk04pt/ov/e3vGP5EjlyRqrY7kVx8HmDO0tgLWYfGy8bKrrMP4CreLosreLxbnJOyXL0bqCfm4vyYDF+/vsP/17hd+e0XOjdZAabGH1MkXJhzRRUzjyRD/zENsXzSqng3oj22rFUux7AQuWK67NufSD8ARHGeb/OA7QcWW+QHwecx6djkiwx++xqO49Kqqcqbh4Pb8gSvZaApBv/xFwpFqRuZkJAX3RZY8IuVFW6O5Bi9XPZp+T7AiZ+J0PDClsUCKkdWhy+9fVw2lP5/QKE/9Lrltu/F9KVFWuQzMdD6MVudme5QrgNJJ9QVUNsJlzCFObYpLUpOkULLPWAZDYU80rgARV72tW1jrJpbSkEmWVyYN/z79muNBYhoQHpTY5RgYSNHHoKaRbBf0KKKVpSqkPE04uBsEYeIqzq/losnte+dwv9Rl0CJ66YlscFyVp41f0Vz3/ZwazkiPIyGFQDflydLeqvSwa6zzCPp81SgrS2DBS/N8O0cF+mw7A+QFpPHZIqPfF6PYbSrvG9wz6u2HEbaxXdk1l4wmL6e+1LYMvUz927HOmNVX3yhvt+bdwbqRCJDIAd/J9XhHXEHS63V2aLDoD/IyFL8tHgLexXiS/pS2CHae9e87DGl73SeZYoAthSZUZu8lQaO4R3Eypr6pzD3NKbBSwBGRDEo4vD5JCMGKP0IfnIGvd7k2ZKcoutn5JVx+u7w9utKc+SPTTcFcvkQIfu71lmd9qjLSHmyq+YlYAdvgrELJPeifOpcBa+sdSFsb1HTDzFUwiwSKwRqMty9fqaw9T8LkKY8HHFwwlHapUnkzUBwO32Mj6OpSdqbsPPNq2C+LeOtVG6THhlhTd8b1yx5Mrn4NLjiOa293ccfc7iveNujJ5SoNOj9ppqb8gFxV/m6fDHCX88w8pLtEFVMLJDmkIt3C97/03MnD8CbWYdOimRxCAl21PibCd7OP1lWTJXmor/bsI+xmVvjk5mWNbR5NFiwDSnqLarHjqc6Kdxdn9hinRViderdjN8wxlIIUEWS+y1o578uXZHBRI2NuN61CJBneF5LMc6XpXBgOyNfc+/ysohB7zV2hYB3WIllX90FJeOxNtscwgTsrlJtEYzKqyUkJTCq+juQWPsA2l3nxq7qybyeTkqSdi0QEf8yTYjoqf+aqicbP84t4ShOzNafTyhS8b6lAtIEVttaThbFDuzyEoQ4Ld1ied53ZLFEtEVTMaGcblWdOYKHh0jsEHvAZKcn1Qc8GNFYf00WmNaTMfjcd+Rdsd+ItlsUNi9qeWGbgZMWdQd+7oxSra62kVL0yziewgrECpz0zQ2rGrS6EJE8+26p0BYF2RyK+gKbAso4BK1svQ6yH65YbUaSDYm2OmIGLk9l+rZn2mQP1SFTuuWZ16MT3pOWd36XRt9lDkpzJfhZUkS6nwumJKMxeChxpkXHfC127ZhwRv12XJI5bdL2mGYFEvxHLQln8AzARF4m7HKK8YJR8ET+Q9+6PtfnIi7h17khc2PUfFuF95seAsa02xNmWCDUYRAMHGiGeQ0W9f1sAbuwyx5b/kTFt2vLtEkX6lFUVhdHMzCH5/bqBupn/3fqvbUQDexMigpPnj97AQfQWMaJI+jF+OG9ehVbKVF9FVlYc+W0yAepz6ROW54Vhufo1uL7C9Aw9v5eoZ/Ocp5ltSYQDWGUD+GbLxh8uEQ6KTDWqAcAaH3+ceYvNT0lrQRTSddPiNVhdk3FBBjv2sGl3fhlHIgbYk40FA+WS3tieBusFWzgh/9X5lWt30frnAw3Jy6X1jEkjObT9+Qz+E8N0CLBbuEbBtQNWhkOjEHIl2whJUlJK2GQgyOHl17YF2wI/MOpJCdMNcai9WvJK47jwuUbdrMMxwN2/d/dKnZ/yOM5tH/uhJP1hJTNGn7UV87TuF47cJpuq7Ed7o5vsGMYnkUf6zq1bHDfNZsc9qdmHS0YpLBz3KL1Hk5XRBJgpaoBfl1I2GvYBYcToo+Iv+RLUmjuufWg8s0vpOq4NVXBBZQDQLIVYYdbl8+V47csn2VAqqYObw4AbRmzXQtB2KMPM1F1pinviu9dmAQKwAurWLInGllIEBAtNOBbRBkv7UyVvWTAZlgEty0xAa7mnbAyQikCpyTjMDTnLaKfoQN695kWr/pNOAdSgNzynMH6ae56NomMUerUgcjd8el6h0PSWqJY17DQEpCF3bpITOjXjiAoZgKFfHL0+OiawtGIF+HnyCIgzPUbqSvjfUlKqzI+urVuAtgudQB1oy7PVpjFX0XndmgPD0369CRPmXWOU/p1Nl+e3IaeY4e6Iim8GiLQPdAVO4DGXPUGtc9v1/SAJY8Ni2PY0K3c3QVrph24PR+Icy+4m7YslDev6YxIDq3bSrWBSUS1CcA78ElH7qcYubYVDKgQLvGqNYui5zxfswN8SPAvPrw6H5GJkfFGItj1jbkN5LkQXq+YN8Bn8z0MXQCzH38eZchfbBJZ1hm2/PKiEn7tnEOUMLU71IJ7gAqP+Ir5S5RloIy2sZUaAnQ2FT09cS7eeteyIbfng/pwxcBMWRhVjt/dZlYSH4oxA9OFfI5mzspQcMlwHVL4kwXZeLf0MqNPKV3lJshaTMsb2AQgsgK+U2JNnT0bXRlILgA1g/s4vwaZnhp8KNnJagq4kHeot5YwALMxc2AKCkThreSuf9+GIfEldnTECAAS7Lmu6D9kgDayvVURt4DNVa/NIQOeNS/auzmM/UfzU8dGjT9vNX7DcA4YeGQbS/ZjkBjr7mjMBtD6ALV0+lcDTtrT6t82pqEShUWOFDB7QG90bJadQLVMhWubTr3zCT9Uk9quFwg362W36/4+ppOv4oHUIxYaYrKMTyAO5daim5tuWJIsh5+sltW9bQpLgNtdgqcWIcoLpAzOVHZzgRk93aZafAq+XK3TREFtsbUVOD4uewc4IA0kO7jFv5zcaJr2QWRRaD1ZDnMMKUCnwwM14SI1c+GagnqbPpXo0sEdLMbgn2E0mwSDSObW1uWBXMfGSgK9+PwGwPbSvGQUtgn0rXOo9pdKchXZaHJmI3CbT1GGP3WbhFKBW8z7m3Ut02w6rzK/K9190JxH/Kk1IY37q4UhZ+xmrstus4jrlRTRxd0xWq0bDlS03h+x1ypKgq0pOfGiNfqsJxxxHv8kIf/Y2kxp+g41IVEz6JzUzKugbRdPcFD40HHLTnJwDBmw567SAg37Uwt8Ft8AK/zT16Srr6WEbZM/HUGxXl0PebEeb/Go6y7Ffa5tqO1T1kvf4+AQFo+BYgeoseKagFFHMFuBVbmGCEh8rC9LmoKs6bopYAW5m/PU175TiEkOJ1XgVERfFmbMThu1TEkighRpkHv4gIqs9KDSq7RUp6HGKU86WOzkFF3oAm5WWxwXCQJ5wqLVS/r+Q5oYasPqyFZ+Ai1yupCWhY1nK8zRO5WkV6+AyRikxgifNPu68nZVh26lr6o9Z/kiYRF9EzYU40g0Kw2RK7fnJKY+f2kOhexqiysaS+RESZnOkjEUcCzvg+mZ7mZiXm9WCBhZnW39ru0ELRn0NFuHF6u5dHlFHTS5VTV4d5a/MVyl/3Sj34qsLyh4cFVuxOgroGK5s7jaRfmwBbGifeOfyiV6TXCSiVHOOjKvD6MyyvDbHuI9/iUYg/q3N+urRczZbkc6Go3eNEjnRQEHpc/Xw2Zo5nPJdXfsxoZWtO6XSsKdQFvsECWt+2UUE5EB8M4XSBA7YXk8VWzXjtjoFtB4lNUnw/DEQ3fVa0hnvYM+7/3h6bkmns504jeTft5cpnMs3JJUsOl/PWXXimOMGn1DeWlBU+ASIS5vnpbrXC7B5aF5ic2qqune2jfS+ks+KaTXzMci2VQqhOMPJzyhtIaupj5PBkeq7Ox5oIARNS6VY4J+32ysqf8a91OmfCGLUIj9vuzpFRnverUor3c5acRV6mjj8psNxS9WPCaA/70zfHiILUnr52hN7+mMmdqUCsAyl3WZbOUQczT6ocrW5qFBnPx71dMePKBNO6wJCRyQLACl+iS7LWxh0O0OTpwoHRPeiUxar4NDtlBqFE/dzvh8/RZ3j46T+XhmqjL8mmN+M8y7Ez6DXCiqtWgpz1ar9XuS4Os+K0X9hkwbShvqamI+PLf/98odoTvNoCc3HC1Bmo4a/1qGoY4FsoFlV6dUc3vdK8whti2ORR1pb2HBpiA5WhWNCic6MpZjU3UwgtqU2OQ/Tc6H7hDvRINq/om53Bq3laxZ3iFJ5By8ym4jXg72l6hbP5VFNp/u0hNbSQ9C4K9QGKARG4dQC0W7De0+ZCfYBZnqhxtNsGtHg5nXKi9672efnU85XcJC08HLfOvsh5y/dkAXh8MK98QDJlMS75ZnWiiVHwYmmO+09qXPcRJ1qoxeHKmeiOF5tSKrqVZI1j973aIA8p2PeN+/37ip9QCb4/EPbVW8viuEnzdvUiZ+n0f1b/ko7jTZVGka5q1eh/QY0RihVqTrpgwHlZrxfN2XKF9VxBgqaZPyv/96O3FJXtmU7YCMq3sUQRVQ0lWQQ7BRjygEG9ZbaF6yjHhhpf63fkcgEwSn0t2V4RxsWCsXD2HPQx62KNr3I7+XExR9Kl3t7KnTc6ZLB5YXSvOkvW5EjL0qosOBzaDL7hRb4kz7lySEfXHsWbOQUtMxUYet1a7AfB5dMfuMV752YUwQ4cTxIA9CJDbuTsyKinGkZahdz7vf/hly1W6j3W8fvOw3iBkfMe54eIDcTp2k8HPg1qioo8Wt1tXt4zp6ROnNdWmPXTw7Ouu9xFOixuuu6W25KBRGqNG10QmWm7eBqWIAbNptWP72rPkxLSOaRGVcN8C+j08lByJ3LSxkeux7fFW/83f7v+j7Iiu/tKQH9D7fOWZLh0qSxJgPv2jTgaNzEkupl71P8UdMcea6egHXx5WIVyQE86s91abCC7D8FkYdDMQ1yaq5VtoFmgFtvxiTgvAel8GHORuElXTkqBT9n3aMMoOzLUiP9o2SQthrgCzp3PJ/B5GctYQSFh8TYiorWbeTmBL4eC3Y6/LFFq3gG+qME1Qb02N7rEYVQ396CrjXz6Fn3DcrAbWnDP6wHHB0qQQs0eJRUYnM83v9CoqjiRzaYp2LySy5ijtB2LUa9sSF7OnY9egRGHGDFXb5zmk/yctud0F58d8WtG6pPAoMJFgPB/4RnR4D6nzKPf6Q7CIRL6KXjGA1epd6EItrVubrz/sIMof5xRlg2CzImCwIus2dsvRWX8G6lAzklgn40ssRPBWs7blQ5Z8a6qhVUZCs0fiz/XaWMrVEAeYIF2wTxPqdDvmJbxLhxThMx9g1vEymhYe+5pufujnjsbyizm364wlzc6AYaLQKR21+T6mc5vckLOP0ZbTRl+/BkuolecyUwmTz7/lqtp+kOhC1Nc8MVUNr2eBjd16bjMyWbj98cIDEw6Ir5l03D02S2VJMf17IXpw6Ca4r1GrtcoTGD5/N+yt3j1jomb/s3MpoJ5/cKGxD1X/MIfllgOJ6V2gAwMu2XwDOHWKd7o5gMpyxT/fOhet4sYSUhqzj1dlRzMAYpke6QSlyhFeh0/GDtcC2k4BX5ieuQGSmaYR3GEM+S1BEE7wXc/cCxpc5D+4GNlKfPQSKYcbuZrMY32wci1Zyx4E2RKDfW/7EUbSBowL0eGVkC7/xnfq+AKn8ZBfnPSEpkDkPp50lFD4NI9dzX0mFNM93q4z+OCBLWyXUL9ifJGNmLcfNxfRGZasyMYq7EaqQRPvOaPE0tvr0UllBusApLSuweFp0HvYRjaG3/7hFvCB5avMGp0kInw2ygOkqAYmHUZwT8minxrc18Oh0GRTvvennp/5lJh5FY1AvkD//3CqZbdrXf2kURLH0DNXDC2lzUa7kLJe/DCba4Nr7VdOT7HMDc0T7UpiEDhaM3BL9WQ60ZeJn06/djDTILynn3IGiTJH/0UZUhGZe/OYZWsAoES0vEDopK7euNANOL/Q8EcX2Xbk6LEopNL8Q92eS6ZVZ20l+GvOpdT4gyfS59oXor9O7fmS+xjZW2s+3cNxDP584twphqsnGl2FMLMd/WgZpF/dphBwUGnPeeIenfvC4Xfrpbo3T9UOs8B7pZFrvJ1YlKNGG0zeh5FzgVtKPAZNPwa1Sl/a6HJZXmcucxXyby88fjoA6sAcLwlDiffHY/YsULRE/yKxJZyU8pkFaayn/AvE/8Rno3Bt5FBrUQwyf+n2q7l3JqAePkTLcYdZ6GzGPDzIL4p49Nc+m+hC6PhmFDW6DfckEGV8FPAXeKdJWtmL/o9SK1wblyMrtm/DLDSCMJgxx6S0hR0HACo2Ho3LpzhhJsJiyzRg+3KfcCepboIBhVP0RjtRKRN2Va6+4u9odaHwQuh6uPEFuAJydc21klQqnebfxYQpM5w9DlhlauKpJY9by2yFZ7DTQ/eM2nUEc8OMX9o5MbGcuLvsss8uFL2w+v5vra0SIlsv+5Q43nc9m0oD/mtrxTie0ejC8JPZZEsMASN5/GGSb74wzWezRx+txqMvriiyKhNzYOEuGg+IY0qEhRBlYpL2C73PGDf0LqweXrfhJmeDMFyilKKjxF94Kdtaq6ZEjGPNiXSzfuL1yRE909YleHjW9ra/SNZS8IYUWXacTy2JvEAtcW2O8ab6VbmsYBZZok5TGsSLscNCFlDq08B7RBnb2Yfp/MRD2XhJhg0Bd633UNo3RAtnr5rn8NvoejFuV0LVZQeoP/bTpRxEzLDfJtZ3kDBrkxKFM9a/mA+Ok1aVM8CyVa1RpfSYmMTdUoaE2h+iv3H6cdyDKBIoO7WwzlPar17lR7ywWy7OBXhZHPYQVHXIKPkAgmRatDkpfrxtDAo5hXiHHskGH8ZSBiLWLUy3ChNA4O2D/hm8ZrYpWkVq0Vz+52dUzVgO+QThxBVvn/a4RpN8BGClE2d7UK3X70C+lkDN9nIw7l7G89CLXX9uaPdG8mlOvDZAuRWldfbcirvyEEMTPE0GTwVyioxmAksb2T7tqfCu0CQ5LyIad2LhbOk0xoq3TPJTkomngvAJnlGfOI1CB3hCCXz8dlKzfjwb6SNnMMuIzybs4+Ufo5I4UAESh6tUe5VnVVtClgUhOXDGCLbRjSVzKVBOBqKMeLW2nYYbxgLjZx0HfFL4rqYnj5ycEJQysVtsoicL6i4ddTkr6xbvWeGG1Ovm90rguwP1+6FAoMZxnZKUmajkhV9FDacZwX74UonGHtM+XtVDW8GPf+CrbM1VCB6yIhlMHiJ6YPiXnUNayKKUwaAnUfY7agWAJ2AOu4+eYmlI5JrGYOl66DfqquYXMM6ZGG5H+N/571EXI01tUPcnngv9i+H0frd9MsFpV8BBxRah/JNyYLA69N1djtwMO2EoH2MOiCxn8zETh/igiPNyywQpUsN5ZF215Mufd96CPs/1iKTZCNHUU37QYa/kf8Z384Cgu7VY2QCLMFYxe/U3mf8kZpFudmWzn47T9fDgRqWkFsCfK7lFwlVN3wDQgDjhXlQYpUZeHf4pkcp3Q63bfhnnPCVmLgoeF5DCQE4TN3ZZAHKlhklwbiSxTRKAFPs8CyKgfzkI0oa2LpgpagkkOm2ODnOY3sPk6IZN3cVB85QiQ6EjPJBt4UE4q83i18V7Fp5gl9zL4myoSFjZKi+MNirvpZjnVAcC8/m7oqIP9xljwmZkCbUTij2C5FR0LeRhJsYItrmHnpiFxGxgsdpiNHKQwL/Jkd2uDX0A9pQ1AUr2IwNTeX8REbNPbbAwm9FAdfm4UuvQN2Ths9yDrvx0JdG5tvR69cuz2wNS9t98BTX4xHAs1npWvukoBtb1TV1eC6yXJDTKpmmkn3+llu/S+IuTDimEqxYVbKqQ/wMAsclnrCKn1gn8DbjhT5fItVkbsTPX3RfSlLakj8jIZg4/gQxnDe+ENbKy8Exp4nelip3OU8wQXVXZnQd0PYC3SGiaYu9+TUQSv5e+sVdUXiNyIlOBoMRNZjLVccU/FJvI+0/j2z0bDPdw+x79N63lC8KkHuWNuGopbznnfXeqNGnJP0uhQwjNu/20Zjrr0mu0DVpIDuHnJXUsQPOyv7S+lVC+TGl15SZR+jJzkVDEqF09vC4ANmyqN1ZaQmvHOXMMpvJJCfxSR5QR47PeSy7flkAJJ/bWxQc1HFG6zvNDb/BQanG8JdWAG8+lFYoOl4VV9eZZZTad7a48ZlkoWBttbJ9xo8FkdA/8vXEeefqWG1/xiLLgMVC2mzE8xfZV7+PKYSjkqLUrI9LpvdasJejuXnvgrWNn6aVUgFVTL4hfXI/z945B8EL8pjnmvOKiFLXvCOszbT1kI24Ehz/nVFT6ZrN1xAWvtGWoFVVyLJe4i8r6jWXbPlDhkozJNXRyTbPnWGiCRwHw3RHBxuGtpvnexGMzYSNtZUHtbUiwXLEdhfBV8MhQXOXgzeTQMlTnOSmRNk+zQEqiYUM9bKqqEZTX5savbqk1gR5QGaUE9Eh7N7IVHCTd1/573Ekc5pV8qzAHtVIlF39m41BCCdi8c8GnlTW9sYAzu40gm1tos0vcvqxSn0ESZp6JlblN2m40r7t3KZq0QOBdFXmbwvPKy2H4JwNQDXF7tQKh+iJ99qVrn7zNwnlAw6UhTb4v5JkgT7L0Ggghd7FNebtt5jGRSdRnoiHjJsH/p3txVhhG0IyibdB0kkrGTwkxWnDedqKUnzprXJkR+8EoyUuuq45490v9T+D0+tZj+XQK7PSYa83ZkXdFCXGlgxUxhtVJfiPI/4/bmS/x');
                      var file=File((await getExternalStorageDirectory()).path+'/test');
                      file.writeAsBytesSync(decode);
                      FormData data = FormData.fromMap({
                        "image": await MultipartFile.fromFile(
                          file.path, //图片名称
                        )
                      });
                      var response=await Dio().post('http://192.168.123.47:8080/upload/image',data: data);
                      print(response.data);
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
              cacheManager: ProxyCacheManager(ipAddr:'192.168.123.47', port:7890),
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