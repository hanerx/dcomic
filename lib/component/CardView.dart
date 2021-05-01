import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Card.dart';

// class CardView extends StatelessWidget {
//   String title = '';
//   List list;
//   int row = 2;
//   List mainList = <Widget>[];
//   Widget action=Container();
//
//
//   CardView.action(this.title, this.list, this.row, categoryId, this.action){
//     this.title = title;
//     this.list = list;
//     this.row = row;
//     mainList = <Widget>[
//       Padding(
//         padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//         child: Row(
//           children: <Widget>[
//             Expanded(
//               child: Text(
//                 '$title',
//                 style: TextStyle(fontSize: 20),
//               ),
//             ),
//             action
//           ],
//         ),
//       ),
//     ];
//     var cardList = <Widget>[];
//     int position = 0;
//     for (var item in list) {
//       if (position >= row) {
//         mainList.add(Row(
//           children: cardList,
//         ));
//         cardList = <Widget>[];
//         position = 0;
//       }
//       switch (categoryId) {
//         case 49:
//           cardList.add(CustomCard(item['cover'], item['title'], item['authors'],
//               1, item['id'].toString()));
//           break;
//         case 56:
//           cardList.add(CustomCard(item['cover'], item['title'], item['authors'],
//               1, item['id'].toString()));
//           break;
//         default:
//           cardList.add(CustomCard(item['cover'], item['title'],
//               item['sub_title'], item['type'], item['obj_id'].toString()));
//       }
//       position++;
//     }
//     if (position > 0) {
//       mainList.add(Row(
//         children: cardList,
//       ));
//     }
//   }
//
//   CardView(title, list, row, categoryId) {
//     this.title = title;
//     this.list = list;
//     this.row = row;
//     mainList = <Widget>[
//       Padding(
//         padding: EdgeInsets.fromLTRB(5, 4, 0, 4),
//         child: Row(
//           children: <Widget>[
//             Expanded(
//               child: Text(
//                 '$title',
//                 style: TextStyle(fontSize: 20),
//               ),
//             ),
//             action
//           ],
//         ),
//       ),
//     ];
//     var cardList = <Widget>[];
//     int position = 0;
//     for (var item in list) {
//       if (position >= row) {
//         mainList.add(Row(
//           children: cardList,
//         ));
//         cardList = <Widget>[];
//         position = 0;
//       }
//       switch (categoryId) {
//         case 49:
//           cardList.add(CustomCard(item['cover'], item['title'], item['authors'],
//               1, item['id'].toString()));
//           break;
//         case 56:
//           cardList.add(CustomCard(item['cover'], item['title'], item['authors'],
//               1, item['id'].toString()));
//           break;
//         default:
//           cardList.add(CustomCard(item['cover'], item['title'],
//               item['sub_title'], item['type'], item['obj_id'].toString()));
//       }
//       position++;
//     }
//     if (position > 0) {
//       mainList.add(Row(
//         children: cardList,
//       ));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//
//     return Card(
//       elevation: 0,
//       margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
//       shape: BeveledRectangleBorder(),
//       child: Column(
//         children: mainList,
//       ),
//     );
//   }
// }

class CardView extends StatelessWidget {
  final String title;
  final List<HomePageCardDetailModel> list;
  final int row;
  final double ratio;
  final Widget action;

  const CardView(
      {Key key,
      this.title,
      this.list,
      this.row: 3,
      this.action,
      this.ratio: 0.6})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      borderOnForeground: true,
      elevation: 0,
      child: Wrap(
        children: [
          ListTile(
            dense: true,
            title: Text(
              '$title',
              style: TextStyle(fontSize: 20),
            ),
            trailing: action,
          ),
          GridView.count(
            crossAxisCount: row,
            childAspectRatio: ratio,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: getCardContent(context),
          )
        ],
      ),
    );
  }

  List<Widget> getCardContent(context) {
    return list.map<Widget>((e) => buildCard(context, e)).toList();
  }

  Widget buildCard(context, HomePageCardDetailModel item) {
    return HomePageCard(
      imageUrl: item.cover,
      title: item.title,
      subtitle: item.subtitle,
      onPressed: item.onPressed,
    );
  }
}
