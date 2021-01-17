import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/AuthorCard.dart';
import 'package:flutterdmzj/component/Card.dart';
import 'package:flutterdmzj/component/LoadingRow.dart';
import 'package:flutterdmzj/component/LoadingTile.dart';
import 'package:flutterdmzj/http/http.dart';

class AuthorPage extends StatefulWidget {
  final int authorId;
  final String author;

  AuthorPage(this.authorId, this.author);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthorPage(authorId, author);
  }
}

class _AuthorPage extends State<AuthorPage> {
  final int authorId;
  final String author;

  List list = <Widget>[LoadingRow()];

  _AuthorPage(this.authorId, this.author);

  getAuthor() async {
    CustomHttp http = CustomHttp();
    var response = await http.getAuthor(authorId);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        list.clear();
        for(var item in response.data['data']){
          list.add(AuthorCard(item['cover'],item['name'],item['status'],item['id']));
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAuthor();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('作者-$author'),
      ),
      body:Scrollbar(
        child: SingleChildScrollView(
          child:  GridView.count(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 0.6,
            children: list
          ),
        ),
      ),
    );
  }
}
