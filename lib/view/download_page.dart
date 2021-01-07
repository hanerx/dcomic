import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/model/download.dart';
import 'package:provider/provider.dart';

class DownloadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DownloadPage();
  }
}

class _DownloadPage extends State<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => DownloadModel(),
      builder: (context, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text('下载管理'),
            ),
            body: EasyRefresh(
              firstRefresh: true,
              firstRefreshWidget: LoadingCube(),
              onRefresh: () async {
                await Provider.of<DownloadModel>(context, listen: false)
                    .getComic();
                return true;
              },
              header: ClassicalHeader(
                  refreshedText: '刷新完成',
                  refreshFailedText: '刷新失败',
                  refreshingText: '刷新中',
                  refreshText: '下拉刷新',
                  refreshReadyText: '释放刷新'),
              child: ListView.builder(
                itemBuilder:
                    Provider.of<DownloadModel>(context).buildComicListTile,
                itemCount: Provider.of<DownloadModel>(context).length,
              ),
            ));
      },
    );
  }
}
