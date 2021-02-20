import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/EmptyView.dart';
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
        firstRefresh: true,
        firstRefreshWidget: LoadingCube(),
        emptyWidget: Provider.of<TrackerModel>(context).empty?EmptyView():null,
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
