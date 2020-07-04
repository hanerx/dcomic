import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';

class AuthorCard extends StatelessWidget{
  final String imageUrl;
  final String title;
  final String subtitle;
  final int id;


  AuthorCard(this.imageUrl, this.title, this.subtitle, this.id);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
      padding: EdgeInsets.all(1),
      child: Card(
        child: Container(
          width: MediaQuery.of(context).size.width/3.3,
          child: Column(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: '$imageUrl',
                httpHeaders: {'referer': 'http://images.dmzj.com'},
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Text(
                '$title',
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$subtitle',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ),
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return ComicDetailPage(id.toString());
        }));
      },
    );
  }

}