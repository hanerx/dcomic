import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/model/novelFavoriteModel.dart';
import 'package:provider/provider.dart';

class NovelFavoritePage extends StatefulWidget {
  final String uid;

  const NovelFavoritePage({Key key, this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelFavoritePage();
  }
}

class _NovelFavoritePage extends State<NovelFavoritePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => NovelFavoriteModel(widget.uid),
      builder: (context, child) {
        return EasyRefresh(
          scrollController: ScrollController(),
          onRefresh: () async {
            await Provider.of<NovelFavoriteModel>(context, listen: false)
                .refresh();
          },
          onLoad: () async {
            await Provider.of<NovelFavoriteModel>(context, listen: false)
                .nextPage();
          },
          emptyWidget: Provider.of<NovelFavoriteModel>(context).empty
              ? EmptyView()
              : null,
          firstRefresh: true,
          firstRefreshWidget: LoadingCube(),
          child: Container(
            padding: EdgeInsets.fromLTRB(2, 7, 2, 0),
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 0.6,
              children: Provider.of<NovelFavoriteModel>(context)
                  .getFavoriteWidget(context),
            ),
          ),
        );
      },
    );
  }
}
