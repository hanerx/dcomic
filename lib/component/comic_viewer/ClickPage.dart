import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/comic_viewer/VerticalPageView.dart';

class ClickPage extends StatelessWidget{
  final bool left;

  const ClickPage({Key key, this.left:false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 100,
      child: FlatButton(
        child: Text('长按加载${left?'上一话':'下一话'}'),
        onPressed: (){},
        onLongPress: ()async{
          if(left){
            await verticalKey.currentState.widget.onTop();
            verticalKey.currentState.moveToTop();
          }else{
            await verticalKey.currentState.widget.onEnd();
            verticalKey.currentState.moveToTop();
          }
        },
      ),
    );
  }

}