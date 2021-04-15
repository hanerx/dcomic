import 'dart:async';

import 'package:battery/battery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dcomic/component/Battery.dart';

class Tips extends StatefulWidget{
  final String title;
  final int index;
  final int length;

  const Tips({Key key, this.title, this.index, this.length}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Tip();
  }
  
}

class _Tip extends State<Tips>{

  StreamSubscription _subscription;
  String _network='未知网络';
  double _batteryState=0.8;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initNetwork();
    initBattery();
  }

  initNetwork()async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(mounted){
      setState(() {
        if (connectivityResult == ConnectivityResult.mobile) {
          _network='移动网络';
        } else if (connectivityResult == ConnectivityResult.wifi) {
          _network='WIFI';
        }
      });
    }
    _subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(mounted){
        setState(() {
          if (result == ConnectivityResult.mobile) {
            _network='移动网络';
          } else if (result == ConnectivityResult.wifi) {
            _network='WIFI';
          }
        });
      }
    });
  }

  initBattery()async{
    try{
      var battery = Battery();
      int state=await battery.batteryLevel;
      if(mounted){
        setState((){
          _batteryState=(state)/100;
        });
        Future.delayed(Duration(seconds: 20)).then((value) => initBattery());
      }
    }catch(e){
      print(e);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(4.0)),
          //设置四周边框
          border: new Border.all(width: 1, color: Colors.black54),
          color: Colors.black54
      ),
      padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: Row(
        children: [
          Text('${widget.title} ${widget.index}/${widget.length} $_network ',style: TextStyle(color: Colors.white),),
          BatteryView(electricQuantity:_batteryState,)
        ],
      ),
    );
  }
  
}