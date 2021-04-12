import 'package:flutter/material.dart';
import 'package:dcomic/database/configDatabaseProvider.dart';
import 'package:dcomic/database/database.dart';
import 'package:dcomic/model/systemSettingModel.dart';
import 'package:dcomic/view/search_page.dart';
import 'package:provider/provider.dart';

class SearchButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchButton();
  }
}

class _SearchButton extends State<SearchButton> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
      child: Icon(
        Icons.search,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SearchPage();
        }));
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text('小彩蛋~'),
                children: <Widget>[
                  SimpleDialogOption(
                    child: Text('我们耕耘黑暗，却守护光明'),
                    onPressed: () {
                      if (_count > 10) {
                        Navigator.of(context).pop();
                        Provider.of<SystemSettingModel>(context,listen: false).labState=true;
                      } else {
                        setState(() {
                          _count++;
                        });
                      }
                    },
                  )
                ],
              );
            });
      },
    );
  }
}