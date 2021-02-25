import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/search/DeepSearchTab.dart';
import 'package:flutterdmzj/component/search/NovelSearchTab.dart';
import 'package:flutterdmzj/component/search/SearchTab.dart';
import 'package:flutterdmzj/generated/l10n.dart';
import 'package:flutterdmzj/model/systemSettingModel.dart';
import 'package:flutterdmzj/view/comic_detail_page.dart';
import 'package:provider/provider.dart';


class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchPage();
  }
}

class _SearchPage extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  FocusNode _node = FocusNode();
  String keyword = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _onSubmit(){
    _node.unfocus();
    setState(() {
      keyword = _controller.text;
    });
    if (keyword == '宝塔镇河妖') {
      Provider.of<SystemSettingModel>(context, listen: false)
          .backupApi = true;
    } else if (keyword == '天王盖地虎') {
      Provider.of<SystemSettingModel>(context, listen: false)
          .backupApi = false;
    }
    var comicId=int.tryParse(keyword);
    if(comicId!=null){
      showDialog(context: context,builder: (context)=>AlertDialog(
        title: Text('看起来你输入了一个漫画ID'),
        content: Text('是否直接跳转至漫画'),
        actions: [
          FlatButton(
            child: Text(S.of(context).Cancel),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(S.of(context).Confirm),
            onPressed: (){
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ComicDetailPage(id: comicId.toString(),title: '',)));
            },
          )
        ],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    List tabs = <Tab>[
      Tab(
        text: '普通搜索',
      ),
    ];
    List views = <Widget>[
      SearchTab(key: UniqueKey(), keyword: keyword),
    ];
    if (Provider.of<SystemSettingModel>(context,listen: false).novel) {
      tabs.add(Tab(
        text: '轻小说搜索',
      ));
      views.add(NovelSearchTab(
        keyword: keyword,
        key: UniqueKey(),
      ));
    }
    if (Provider.of<SystemSettingModel>(context,listen: false).deepSearch) {
      tabs.add(Tab(
        text: '隐藏搜索',
      ));
      views.add(DeepSearchTab(
        key: UniqueKey(),
        keyword: keyword,
      ));
    }

    // TODO: implement build
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            enableInteractiveSelection: true,
            focusNode: _node,
            autofocus: true,
            controller: _controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '输入关键词',
              hintStyle: TextStyle(color: Colors.white),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (val) {
              _onSubmit();
            },
          ),
          bottom: TabBar(
            tabs: tabs,
          ),
          actions: <Widget>[
            FlatButton(
              child: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                _onSubmit();
              },
            )
          ],
        ),
        body: TabBarView(
          children: views,
        ),
      ),
    );
  }
}
