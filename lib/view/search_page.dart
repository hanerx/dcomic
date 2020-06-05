import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/http/http.dart';

import 'comic_detail_page.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchPage();
  }
}

class _SearchPage extends State<SearchPage> {
  List list = <Widget>[];
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FocusNode _node = FocusNode();
  int page = 0;
  String keyword = '';
  bool refreshState = false;

  search() async {
    CustomHttp http = CustomHttp();
    var response = await http.search(keyword, page);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        if (response.data.length == 0) {
          refreshState = true;
          return;
        }
        for (var item in response.data) {
          list.add(SearchListTile(item['cover'], item['title'], item['types'],
              item['last_name'], item['id'].toString(), item['authors']));
        }
        refreshState = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !refreshState) {
        setState(() {
          refreshState = true;
          page++;
        });
        search();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          focusNode: _node,
          autofocus: true,
          controller: _controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '输入关键词',
            hintStyle: TextStyle(color: Colors.white),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            _node.unfocus();
            setState(() {
              page = 0;
              keyword = _controller.text;
            });
            search();
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              _node.unfocus();
              setState(() {
                page = 0;
                keyword = _controller.text;
              });
              search();
            },
          )
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: list.length,
        itemBuilder: (context, index) {
          return list[index];
        },
      ),
    );
  }
}

class SearchListTile extends StatelessWidget {
  final String cover;
  final String title;
  final String types;
  final String last;
  final String authors;
  final String comicId;

  SearchListTile(this.cover, this.title, this.types, this.last, this.comicId,
      this.authors);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
        child: FlatButton(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ComicDetailPage(comicId);
        }));
      },
      child: Card(
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: '$cover',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
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
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.history,
                              color: Colors.grey[500],
                            ),
                            Expanded(
                              child: Text(
                                '$last',
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
