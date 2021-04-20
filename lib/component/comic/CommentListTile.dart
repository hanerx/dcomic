import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcomic/component/comic/BaseListTile.dart';
import 'package:dcomic/utils/tool_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentListTile extends StatelessWidget {
  final String avatar;
  final String content;
  final List reply;
  final int timestamp;
  final String nickname;
  final String uploadImage;
  final int like;

  const CommentListTile(
      {Key key,
      this.avatar,
      this.content,
      this.reply,
      this.timestamp,
      this.nickname,
      this.uploadImage,
      this.like})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      elevation: 0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 5),
        title: Text('$nickname'),
        leading: ClipRRect(
          child: CachedNetworkImage(
            imageUrl: '$avatar',
            httpHeaders: {'referer': 'http://images.dmzj.com'},
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => CachedNetworkImage(
              imageUrl: 'https://avatar.dmzj.com/default.png',
              httpHeaders: {'referer': 'http://images.dmzj.com'},
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Center(
                child: Icon(Icons.warning),
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        subtitle: Wrap(
          children: [
            Container(
              width: double.infinity,
              child: Text('${ToolMethods.formatTimestamp(timestamp)}'),
            ),
            Container(
              width: double.infinity,
              child: Text('$content'),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.message,
                    size: 20,
                  ),
                  label: Text('${reply.length}',style: TextStyle(fontSize: 15),),
                ),
                Expanded(child: Container()),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.favorite,
                    size: 20,
                  ),
                  label: Text('$like',style: TextStyle(fontSize: 15),),
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero)),
                )
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: reply.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  margin: EdgeInsets.only(bottom: 5),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    tileColor: Theme.of(context).accentColor.withOpacity(0.2),
                    dense: true,
                    leading: ClipRRect(
                      child: CachedNetworkImage(
                        imageUrl: '${reply[index]['avatar']}',
                        httpHeaders: {'referer': 'http://images.dmzj.com'},
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            CachedNetworkImage(
                          imageUrl: 'https://avatar.dmzj.com/default.png',
                          httpHeaders: {'referer': 'http://images.dmzj.com'},
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(Icons.warning),
                          ),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    title: Text('${reply[index]['nickname']}'),
                    subtitle: Text('${reply[index]['content']}'),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
