import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/component/comic/ComicListTile.dart';
import 'package:dcomic/model/comicRankingListModel.dart';
import 'package:dcomic/model/comic_source/sourceProvider.dart';
import 'package:dcomic/view/comic_detail_page.dart';
import 'package:provider/provider.dart';

class RankingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RankingPage();
  }
}

class _RankingPage extends State<RankingPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ComicRankingListModel(Provider.of<SourceProvider>(context).activeHomeModel),
      builder: (context, child) => DirectSelectContainer(
          child: Column(
        children: [
          // _buildFilter(context),
          Expanded(
            child: EasyRefresh(
              firstRefreshWidget: LoadingCube(),
              firstRefresh: true,
              onRefresh: () async {
                await Provider.of<ComicRankingListModel>(context, listen: false)
                    .refresh();
                return;
              },
              onLoad: () async {
                await Provider.of<ComicRankingListModel>(context, listen: false)
                    .next();
                return;
              },
              emptyWidget:
                  Provider.of<ComicRankingListModel>(context).length == 0
                      ? EmptyView()
                      : null,
              child: ListView.builder(
                itemCount: Provider.of<ComicRankingListModel>(context).length,
                itemBuilder: (context, index) {
                  var item =
                      Provider.of<ComicRankingListModel>(context).data[index];
                  return ComicListTile(
                    title: item.title,
                    cover: item.cover,
                    tag: item.types,
                    authors: item.authors,
                    date: item.timestamp,
                    headers: item.headers,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ComicDetailPage(
                                id: item.comicId,
                                title: item.title,
                                model: Provider.of<SourceProvider>(context)
                                    .activeSources
                                    .first,
                              ),
                          settings: RouteSettings(name: 'comic_detail_page')));
                    },
                  );
                },
              ),
            ),
          )
        ],
      )),
    );
  }

  // Widget _buildFilter(context) {
  //   return Container(
  //     height: 45,
  //     child: Row(
  //       children: <Widget>[
  //         Expanded(
  //           flex: 2,
  //           child: Padding(
  //             child: DirectSelectList<String>(
  //               values:
  //                   Provider.of<ComicRankingListModel>(context).dateTypeList,
  //               defaultItemIndex:
  //                   Provider.of<ComicRankingListModel>(context).filterDate,
  //               itemBuilder: (String value) => DirectSelectItem<String>(
  //                   itemHeight: 56,
  //                   value: value,
  //                   itemBuilder: (context, value) {
  //                     return Container(
  //                       child: Text(
  //                         value,
  //                         textAlign: TextAlign.center,
  //                       ),
  //                     );
  //                   }),
  //               onItemSelectedListener: (item, index, context) {
  //                 Provider.of<ComicRankingListModel>(context, listen: false)
  //                     .filterDate = index;
  //                 Provider.of<ComicRankingListModel>(context, listen: false)
  //                     .refresh();
  //               },
  //               focusedItemDecoration: BoxDecoration(
  //                 border: BorderDirectional(
  //                   bottom: BorderSide(width: 1, color: Colors.black12),
  //                   top: BorderSide(width: 1, color: Colors.black12),
  //                 ),
  //               ),
  //             ),
  //             padding: EdgeInsets.only(left: 15),
  //           ),
  //         ),
  //         Expanded(
  //           child: Icon(
  //             Icons.unfold_more,
  //             color: Theme.of(context).disabledColor,
  //           ),
  //         ),
  //         Expanded(
  //             flex: 2,
  //             child: Padding(
  //               child: DirectSelectList<int>(
  //                 values: Provider.of<ComicRankingListModel>(context)
  //                     .tagTypeList
  //                     .keys
  //                     .toList(),
  //                 defaultItemIndex: Provider.of<ComicRankingListModel>(context)
  //                     .tagTypeList
  //                     .keys
  //                     .toList()
  //                     .indexOf(Provider.of<ComicRankingListModel>(context)
  //                         .filterTag),
  //                 itemBuilder: (int value) => DirectSelectItem<int>(
  //                     itemHeight: 56,
  //                     value: value,
  //                     itemBuilder: (context, value) {
  //                       return Container(
  //                         child: Text(
  //                           Provider.of<ComicRankingListModel>(context,
  //                                   listen: false)
  //                               .tagTypeList[value],
  //                           textAlign: TextAlign.center,
  //                         ),
  //                       );
  //                     }),
  //                 onItemSelectedListener: (item, index, context) {
  //                   Provider.of<ComicRankingListModel>(context, listen: false)
  //                       .filterTag = item;
  //                   Provider.of<ComicRankingListModel>(context, listen: false)
  //                       .refresh();
  //                 },
  //                 focusedItemDecoration: BoxDecoration(
  //                   border: BorderDirectional(
  //                     bottom: BorderSide(width: 1, color: Colors.black12),
  //                     top: BorderSide(width: 1, color: Colors.black12),
  //                   ),
  //                 ),
  //               ),
  //               padding: EdgeInsets.only(left: 15),
  //             )),
  //         Expanded(
  //           child: Icon(
  //             Icons.unfold_more,
  //             color: Theme.of(context).disabledColor,
  //           ),
  //         ),
  //         Expanded(
  //             flex: 2,
  //             child: Padding(
  //               child: DirectSelectList<String>(
  //                 values:
  //                     Provider.of<ComicRankingListModel>(context).typeTypeList,
  //                 defaultItemIndex:
  //                     Provider.of<ComicRankingListModel>(context).filterType,
  //                 itemBuilder: (String value) => DirectSelectItem<String>(
  //                     itemHeight: 56,
  //                     value: value,
  //                     itemBuilder: (context, value) {
  //                       return Container(
  //                         child: Text(
  //                           value,
  //                           textAlign: TextAlign.center,
  //                         ),
  //                       );
  //                     }),
  //                 onItemSelectedListener: (item, index, context) {
  //                   Provider.of<ComicRankingListModel>(context, listen: false)
  //                       .filterType = index;
  //                   Provider.of<ComicRankingListModel>(context, listen: false)
  //                       .refresh();
  //                 },
  //                 focusedItemDecoration: BoxDecoration(
  //                   border: BorderDirectional(
  //                     bottom: BorderSide(width: 1, color: Colors.black12),
  //                     top: BorderSide(width: 1, color: Colors.black12),
  //                   ),
  //                 ),
  //               ),
  //               padding: EdgeInsets.only(left: 15),
  //             )),
  //         Expanded(
  //           child: Icon(
  //             Icons.unfold_more,
  //             color: Theme.of(context).disabledColor,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
