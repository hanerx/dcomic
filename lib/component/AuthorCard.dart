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
        elevation: 0,
        child: Container(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: <Widget>[
              ClipRRect(
                child: AspectRatio(
                  aspectRatio: 0.75,
                  child:CachedNetworkImage(
                    imageUrl: '$imageUrl',
                    httpHeaders: {'referer': 'http://images.dmzj.com'},
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),),
                borderRadius: BorderRadius.circular(5),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
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
          return ComicDetailPage(id:id.toString(),title: title,);
        }));
      },
    );
  }

}