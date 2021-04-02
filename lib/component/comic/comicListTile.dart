import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';

class ComicListTile extends StatelessWidget {
  final String cover;
  final Map<String, String> headers;
  final String title;
  final String authors;
  final String tag;
  final int date;
  final VoidCallback onPressed;

  const ComicListTile(
      {Key key,
      this.cover,
      this.headers,
      this.title,
      this.authors,
      this.tag,
      this.date,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Container(
          padding: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 100,
                    child: CachedNetworkImage(
                      imageUrl: cover,
                      httpHeaders: headers,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  )),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text.rich(
                      TextSpan(children: [
                        WidgetSpan(
                            child: Icon(
                          Icons.supervisor_account,
                          color: Colors.grey,
                          size: 23,
                        )),
                        TextSpan(
                          text: " ",
                        ),
                        TextSpan(
                            text: authors,
                            style: TextStyle(color: Colors.grey, fontSize: 16))
                      ]),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text.rich(
                      TextSpan(children: [
                        WidgetSpan(
                            child: Icon(
                          Icons.category,
                          color: Colors.grey,
                          size: 23,
                        )),
                        TextSpan(
                          text: " ",
                        ),
                        TextSpan(
                            text: tag,
                            style: TextStyle(color: Colors.grey, fontSize: 16))
                      ]),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text.rich(
                      TextSpan(children: [
                        WidgetSpan(
                            child: Icon(
                          Icons.history,
                          color: Colors.grey,
                          size: 23,
                        )),
                        TextSpan(
                          text: " ",
                        ),
                        TextSpan(
                            text: ToolMethods.formatTimestamp(date),
                            style: TextStyle(color: Colors.grey, fontSize: 16))
                      ]),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
