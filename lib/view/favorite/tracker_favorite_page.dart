import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/model/trackerModel.dart';
import 'package:provider/provider.dart';

class TrackerFavoritePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TrackerFavoritePage();
  }
}

class _TrackerFavoritePage extends State<TrackerFavoritePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return EasyRefresh(
        scrollController: ScrollController(),
        onRefresh: () async {
          await Provider.of<TrackerModel>(context, listen: false).init();
        },
        header: ClassicalHeader(
            refreshedText: '刷新完成',
            refreshFailedText: '刷新失败',
            refreshingText: '刷新中',
            refreshText: '下拉刷新',
            refreshReadyText: '释放刷新'),
        footer: ClassicalFooter(
            loadReadyText: '下拉加载更多',
            loadFailedText: '加载失败',
            loadingText: '加载中',
            loadedText: '加载完成',
            noMoreText: '没有更多内容了'),
        firstRefresh: true,
        firstRefreshWidget: LoadingCube(),
        child: Container(
            padding: EdgeInsets.fromLTRB(2, 7, 2, 0),
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 0.6,
              children:
                  Provider.of<TrackerModel>(context).getFavoriteWidget(context),
            )));
  }
}
