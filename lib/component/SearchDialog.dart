import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:dcomic/model/sourceSearchProvider.dart';
import 'package:provider/provider.dart';

import 'EmptyView.dart';

class SearchDialog extends StatefulWidget {
  final BaseSourceModel model;
  final String keyword;
  final String comicId;

  const SearchDialog({Key key, this.model, this.keyword, this.comicId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchDialog();
  }
}

class _SearchDialog extends State<SearchDialog> {
  TextEditingController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController(text: widget.keyword);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => SourceSearchProvider(widget.model, widget.keyword,widget.comicId),
      builder: (context, build) => Dialog(
        child: Container(
          child: Column(
            children: [
              ClipRRect(
                child: AppBar(
                  title: TextField(
                    enableInteractiveSelection: true,
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '输入关键词',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (val) async {
                      Provider.of<SourceSearchProvider>(context, listen: false)
                          .keyword = val;
                      await Provider.of<SourceSearchProvider>(context,
                              listen: false)
                          .refresh();
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        Provider.of<SourceSearchProvider>(context,
                                listen: false)
                            .keyword = _controller.text;
                        await Provider.of<SourceSearchProvider>(context,
                                listen: false)
                            .refresh();
                      },
                    )
                  ],
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
              Expanded(
                child: EasyRefresh(
                    emptyWidget:
                        Provider.of<SourceSearchProvider>(context).length == 0
                            ? EmptyView()
                            : null,
                    onRefresh: () async {
                      await Provider.of<SourceSearchProvider>(context,
                              listen: false)
                          .refresh();
                    },
                    firstRefresh: true,
                    firstRefreshWidget: LoadingCube(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: Provider.of<SourceSearchProvider>(context)
                          .buildListTile,
                      itemCount:
                          Provider.of<SourceSearchProvider>(context).length,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class SearchListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String types;
  final String authors;
  final String comicId;

  SearchListTile(
      this.cover, this.title, this.types,this.comicId, this.authors);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
          padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
          onPressed: () async{
            await Provider.of<SourceSearchProvider>(context,listen: false).boundComicId(comicId);
            Navigator.of(context).pop(true);
          },
          child: Card(
            child: Row(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: '$cover',
                  httpHeaders: {'referer': 'http://images.dmzj.com'},
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                        child:
                        CircularProgressIndicator(value: downloadProgress.progress),
                      ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  width: 100,
                ),
                Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '$title',
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.supervisor_account,
                                      color: Colors.grey[500],
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$authors',
                                        style: TextStyle(color: Colors.grey[500]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.category,
                                      color: Colors.grey[500],
                                    ),
                                    Expanded(
                                      child: Text(
                                        "$types",
                                        style: TextStyle(color: Colors.grey[500]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                )),
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ));
  }
}

