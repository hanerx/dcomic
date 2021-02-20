
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/model/comicDetail.dart';
import 'package:flutterdmzj/model/comic_source/baseSourceModel.dart';
import 'package:flutterdmzj/model/comic_source/sourceProvider.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:provider/provider.dart';

class EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: SizedBox(),
            flex: 2,
          ),
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: Icon(
              FontAwesome.folder_open_empty,
              size: 60,
              color: Theme.of(context).disabledColor,
            ),
          ),
          Text(
            S.of(context).NoData,
            style: TextStyle(
                fontSize: 16.0, color: Theme.of(context).disabledColor),
          ),
          Expanded(
            child: SizedBox(),
            flex: 3,
          ),
        ],
      ),
    );
  }
}

class ComicDetailEmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: SizedBox(),
            flex: 2,
          ),
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: Icon(
              FontAwesome.folder_open_empty,
              size: 60,
              color: Theme.of(context).disabledColor,
            ),
          ),
          Text(
            S.of(context).NoComicData,
            style: TextStyle(
                fontSize: 16.0, color: Theme.of(context).disabledColor),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20,right: 20),
            child: Row(
              children: [
                Padding(
                  child: Text(
                    '数据提供商',
                    style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).disabledColor),
                  ),
                  padding: EdgeInsets.only(left: 10),
                ),
                Expanded(
                  child: Padding(
                    child: DirectSelectList<BaseSourceModel>(
                      values: Provider.of<SourceProvider>(context).activeSources,
                      defaultItemIndex:
                      Provider.of<SourceProvider>(context).index,
                      itemBuilder: (BaseSourceModel value) =>
                          DirectSelectItem<BaseSourceModel>(
                              itemHeight: 56,
                              value: value,
                              itemBuilder: (context, value) {
                                return Container(
                                  child: Text(
                                    value.type.title,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Theme.of(context).disabledColor),
                                  ),
                                );
                              }),
                      onItemSelectedListener: (item, index, context) {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text(item.type.title)));
                        Provider.of<SourceProvider>(context, listen: false)
                            .active = item;
                        Provider.of<ComicDetailModel>(context, listen: false)
                            .changeModel(item);
                      },
                      focusedItemDecoration: BoxDecoration(
                        border: BorderDirectional(
                          bottom: BorderSide(width: 1, color: Colors.black12),
                          top: BorderSide(width: 1, color: Colors.black12),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
                  ),
                ),
                Padding(
                  child: Icon(
                    Icons.unfold_more,
                    color: Theme.of(context).disabledColor,
                  ),
                  padding: EdgeInsets.only(right: 10),
                )
              ],
            ),
          ),
          Expanded(
            child: SizedBox(),
            flex: 3,
          ),
        ],
      ),
    );
  }
}
