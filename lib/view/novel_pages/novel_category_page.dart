import 'package:dcomic/model/novelCategoryModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:provider/provider.dart';

class NovelCategoryPage extends StatefulWidget {

  const NovelCategoryPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NovelCategoryPage();
  }
}

class _NovelCategoryPage extends State<NovelCategoryPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => NovelCategoryModel(),
      builder: (context, child) {
        return Column(
          children: [
            Expanded(
                child: EasyRefresh(
              scrollController: ScrollController(),
              onRefresh: () async {
                await Provider.of<NovelCategoryModel>(context, listen: false)
                    .init();
              },
              firstRefresh: true,
              firstRefreshWidget: LoadingCube(),
              emptyWidget: Provider.of<NovelCategoryModel>(context).empty
                  ? EmptyView()
                  : null,
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                children: Provider.of<NovelCategoryModel>(context)
                    .buildCategoryWidget(context),
              ),
            ))
          ],
        );
      },
    );
  }
}
