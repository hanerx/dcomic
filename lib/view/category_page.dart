import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/model/comicCategoryModel.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {

  const CategoryPage({Key key}) : super(key: key);

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
      create: (_) => ComicCategoryModel(Provider.of<SourceProvider>(context).activeHomeModel),
      builder: (context, child) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Padding(
                  child: Text('当前分类加载模式：'),
                  padding: EdgeInsets.only(left: 10),
                )),
                Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: OutlinedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(50))))),
                        child: Text(
                            '${Provider.of<ComicCategoryModel>(context).local ? "本地模式" : "云端模式"}'),
                        onPressed: () async {
                          Provider.of<ComicCategoryModel>(context,
                                  listen: false)
                              .local = !Provider.of<ComicCategoryModel>(context,
                                  listen: false)
                              .local;
                          await Provider.of<ComicCategoryModel>(context,
                                  listen: false)
                              .init();
                        }))
              ],
            ),
            Expanded(
                child: EasyRefresh(
              scrollController: ScrollController(),
              onRefresh: () async {
                await Provider.of<ComicCategoryModel>(context, listen: false)
                    .init();
              },
              firstRefresh: true,
              firstRefreshWidget: LoadingCube(),
              emptyWidget: Provider.of<ComicCategoryModel>(context).empty
                  ? EmptyView()
                  : null,
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                children: Provider.of<ComicCategoryModel>(context)
                    .buildCategoryWidget(context),
              ),
            ))
          ],
        );
      },
    );
  }
}
