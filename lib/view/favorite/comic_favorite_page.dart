import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/model/comicFavoriteModel.dart';
import 'package:provider/provider.dart';

class ComicFavoritePage extends StatefulWidget {
  final String uid;

  const ComicFavoritePage({Key key, this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ComicFavoritePage();
  }
}

class _ComicFavoritePage extends State<ComicFavoritePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ComicFavoriteModel(widget.uid),
      builder: (context, child) {
        return EasyRefresh(
          firstRefresh: true,
          firstRefreshWidget: LoadingCube(),
          scrollController: ScrollController(),
          onRefresh: () async {
            await Provider.of<ComicFavoriteModel>(context, listen: false)
                .refresh();
          },
          onLoad: () async {
            await Provider.of<ComicFavoriteModel>(context, listen: false)
                .nextPage();
          },
          emptyWidget: Provider.of<ComicFavoriteModel>(context).empty
              ? EmptyView()
              : null,
          child: Container(
            padding: EdgeInsets.fromLTRB(2, 7, 2, 0),
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 0.6,
              children: Provider.of<ComicFavoriteModel>(context)
                  .getFavoriteWidget(context),
            ),
          ),
        );
      },
    );
  }
}
