import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutterdmzj/component/EmptyView.dart';
import 'package:flutterdmzj/component/LoadingCube.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:markdown_widget/markdown_helper.dart';

import 'SearchListTile.dart';

class SearchTab extends StatefulWidget{
  String keyword;
  Key key;

  SearchTab({this.key,@required this.keyword});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchTab();
  }

}

class _SearchTab extends State<SearchTab>{
  List list = <Widget>[];
  int page = 0;
  bool refreshState = false;


  _SearchTab();

  search() async {
    if(widget.keyword!=null &&widget.keyword!=''){
      CustomHttp http = CustomHttp();
      var response = await http.search(widget.keyword, page);
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return EasyRefresh(
      scrollController: ScrollController(),
      firstRefreshWidget: LoadingCube(),
      firstRefresh: true,
      onRefresh: ()async{
        setState(() {
          refreshState = true;
          page=0;
        });
        search();
      },
      onLoad: ()async{
        setState(() {
          refreshState = true;
          page++;
        });
        search();
      },
      emptyWidget: list.length==0?EmptyView():null,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return list[index];
        },
      ),
    );
  }

}
