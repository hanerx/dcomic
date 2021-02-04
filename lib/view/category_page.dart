import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/model/comicCategoryModel.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  final int type;

  const CategoryPage({Key key, this.type: 0}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CategoryPage();
  }
}

class _CategoryPage extends State<CategoryPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ComicCategoryModel(widget.type),
      builder: (context, child) {
        return EasyRefresh(
          scrollController: ScrollController(),
          onRefresh: () async {
            await Provider.of<ComicCategoryModel>(context, listen: false)
                .init();
          },
          firstRefresh: true,
          firstRefreshWidget: LoadingCube(),
          child: GridView.count(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            children: Provider.of<ComicCategoryModel>(context)
                .buildCategoryWidget(context),
          ),
        );
      },
    );
  }
}
