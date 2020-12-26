import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Card.dart';

class CardView extends StatelessWidget {
  String title = '';
  List list;
  int row = 2;
  List mainList = <Widget>[];
  Widget action=Container();


  CardView.action(this.title, this.list, this.row, categoryId, this.action){
    this.title = title;
    this.list = list;
    this.row = row;
    mainList = <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '$title',
                style: TextStyle(fontSize: 20),
              ),
            ),
            action
          ],
        ),
      ),
    ];
    var cardList = <Widget>[];
    int position = 0;
    for (var item in list) {
      if (position >= row) {
        mainList.add(Row(
          children: cardList,
        ));
        cardList = <Widget>[];
        position = 0;
      }
      switch (categoryId) {
        case 49:
          cardList.add(CustomCard(item['cover'], item['title'], item['authors'],
              1, item['id'].toString()));
          break;
        case 56:
          cardList.add(CustomCard(item['cover'], item['title'], item['authors'],
              1, item['id'].toString()));
          break;
        default:
          cardList.add(CustomCard(item['cover'], item['title'],
              item['sub_title'], item['type'], item['obj_id'].toString()));
      }
      position++;
    }
    if (position > 0) {
      mainList.add(Row(
        children: cardList,
      ));
    }
  }

  CardView(title, list, row, categoryId) {
    this.title = title;
    this.list = list;
    this.row = row;
    mainList = <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '$title',
                style: TextStyle(fontSize: 20),
              ),
            ),
            action
          ],
        ),
      ),
    ];
    var cardList = <Widget>[];
    int position = 0;
    for (var item in list) {
      if (position >= row) {
        mainList.add(Row(
          children: cardList,
        ));
        cardList = <Widget>[];
        position = 0;
      }
      switch (categoryId) {
        case 49:
          cardList.add(CustomCard(item['cover'], item['title'], item['authors'],
              1, item['id'].toString()));
          break;
        case 56:
          cardList.add(CustomCard(item['cover'], item['title'], item['authors'],
              1, item['id'].toString()));
          break;
        default:
          cardList.add(CustomCard(item['cover'], item['title'],
              item['sub_title'], item['type'], item['obj_id'].toString()));
      }
      position++;
    }
    if (position > 0) {
      mainList.add(Row(
        children: cardList,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Card(
      elevation: 0,
      margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
      shape: BeveledRectangleBorder(),
      child: Column(
        children: mainList,
      ),
    );
  }
}

