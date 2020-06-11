import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/CategoryCard.dart';
import 'package:flutterdmzj/http/http.dart';

class CategoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CategoryPage();
  }
}

class _CategoryPage extends State<CategoryPage> {
  List list = <Widget>[];
  static int row = 3;
  int page = 0;
  final int maxPage = 2;
  bool refreshState = false;
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategory();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !refreshState &&
          page < maxPage) {
        setState(() {
          refreshState = true;
          page++;
        });
        getCategory();
      }
    });
  }

  void getCategory() async {
    CustomHttp http = CustomHttp();
    var response = await http.getCategory(page);
    var cardList = <Widget>[];
    int position = 0;
    if (response.data.length == 0) {
      setState(() {
        refreshState = true;
        return;
      });
    }
    for (var item in response.data) {
      if (position >= row && mounted) {
        setState(() {
          list.add(Row(
            children: cardList,
          ));
        });
        cardList = <Widget>[];
        position = 0;
      }
      cardList.add(CategoryCard(item['cover'], item['title'], item['tag_id']));
      position++;
    }
    if (position > 0 && mounted) {
      setState(() {
        list.add(Row(
          children: cardList,
        ));
      });
    }
    if (mounted) {
      setState(() {
        refreshState = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scrollbar(
      child: SingleChildScrollView(
        controller: _controller,
        child: Column(
          children: list,
        ),
      ),
    );
  }
}

