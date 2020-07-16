import 'package:flutter/cupertino.dart';

typedef void PageOnTap(int index);
typedef void PageOnLongTap(int index);

class Page extends StatefulWidget{

  final PageOnTap onTap;
  final PageOnLongTap onLongTap;


  Page({this.onTap, this.onLongTap});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return null;
  }


}