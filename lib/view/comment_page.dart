import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:dcomic/component/EmptyView.dart';
import 'package:dcomic/component/LoadingCube.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/component/comic/CommentListTile.dart';
import 'package:provider/provider.dart';
import 'package:dcomic/model/comicCommentModel.dart';

class CommentPage extends StatefulWidget {
  final ComicDetail detail;

  CommentPage({this.detail});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CommentPage();
  }
}

class _CommentPage extends State<CommentPage> {
  _CommentPage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (_) => ComicCommentModel(widget.detail),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text('评论'),
        ),
        body: EasyRefresh(
          onRefresh: () async {
            await Provider.of<ComicCommentModel>(context, listen: false)
                .refresh();
            return;
          },
          firstRefresh: true,
          firstRefreshWidget: LoadingCube(),
          onLoad: () async {
            await Provider.of<ComicCommentModel>(context, listen: false).next();
          },
          emptyWidget: Provider.of<ComicCommentModel>(context).length == 0||Provider.of<ComicCommentModel>(context).error!=null
              ? EmptyView(message: Provider.of<ComicCommentModel>(context).error,)
              : null,
          child: ListView.builder(
              itemCount: Provider.of<ComicCommentModel>(context).length,
              itemBuilder: (context, index) {
                var comment =
                    Provider.of<ComicCommentModel>(context).data[index];
                return CommentListTile(
                  avatar: comment.avatar,
                  content: comment.content,
                  nickname: comment.nickname,
                  reply: comment.reply,
                  timestamp: comment.timestamp,
                  like: comment.like,
                );
              }),
        ),
      ),
    );
  }
}
