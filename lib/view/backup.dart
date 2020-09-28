// child: Swiper(
//   indicatorLayout: PageIndicatorLayout.SLIDE,
//   viewportFraction: direction ? viewFraction : 1.0,
//   controller: _controller,
//   control: click
//       ? CustomSwiperControl(size: controlSize, debug: debug)
//       : null,
//   scrollDirection: direction ? Axis.vertical : Axis.horizontal,
//   index: index,
//   loop: false,
//   itemCount: list.length + 2,
//   itemBuilder: (context, index) {
//     if (index > 0 && index < list.length + 1) {
//       return list[index - 1];
//     } else if (index == list.length + 1 &&
//         (next == null || next == '')) {
//       return EndPage();
//     } else if (index == 0 && (previous == null || previous == '')) {
//       return EndPage();
//     } else {
//       return LoadingRow();
//     }
//   },
//   onIndexChanged: (index) {
//     if (refreshState == false && index == 0) {
//       if (previous == null || previous == '') {
//         return;
//       }
//       setState(() {
//         refreshState = true;
//       });
//       getComic(comicId, previous, true);
//       return;
//     }
//     if (refreshState == false && index == list.length + 1) {
//       if (next == null || next == '') {
//         return;
//       }
//       setState(() {
//         refreshState = true;
//       });
//       getComic(comicId, next, false);
//       return;
//     }
//     if (index > 0 && index < list.length + 1) {
//       setState(() {
//         pageAt = list[index - 1].chapterId;
//         title = list[index - 1].title;
//         this.index = index;
//       });
//     } else {
//       setState(() {
//         this.index = index;
//       });
//     }
//     setState(() {
//       hiddenAppbar = true;
//     });
//     SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
//   },
//   onTap: (index) {
//     setState(() {
//       hiddenAppbar = !hiddenAppbar;
//     });
//     if (!hiddenAppbar) {
//       SystemChrome.setEnabledSystemUIOverlays(
//           [SystemUiOverlay.top, SystemUiOverlay.bottom]);
//     } else {
//       SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
//     }
//   },
//
// ),


// @Deprecated("用更好的AppBar替代了")
// List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
//   return <Widget>[
//     SliverAppBar(
//       title: Text('$title'),
//       snap: true,
//       floating: true,
//       actions: <Widget>[
//         FlatButton(
//           child: Icon(
//             Icons.chat,
//             color: Colors.white,
//           ),
//           onPressed: () async {
//             await getViewPoint();
//             showModalBottomSheet(
//                 context: context,
//                 builder: (context) {
//                   return Container(
//                     height: 400,
//                     padding: EdgeInsets.all(0),
//                     child: SingleChildScrollView(
//                         child: Column(
//                           children: <Widget>[
//                             Padding(
//                               padding: EdgeInsets.all(5),
//                               child: Text('吐槽'),
//                             ),
//                             Divider(),
//                             Wrap(
//                               children: viewPointList,
//                             ),
//                           ],
//                         )),
//                   );
//                 });
//           },
//         )
//       ],
//     )
//   ];
// }