import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EndPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EndPage();
  }
}

class _EndPage extends State<EndPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child:  Center(
        child: Container(
          height: 300,
          width: 400,
          child: Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                              child: Text(
                                '没得了，你已经翻到头了',
                                style: TextStyle(fontSize: 18),
                              )),
                        )
                      ],
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: Text('这里以后或许有点功能，现在就先放着好了'),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlineButton.icon(
                            icon: Icon(Icons.arrow_back_ios),
                            label: Text('返回漫画详情'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
