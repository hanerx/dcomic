import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/baseModel.dart';

class NovelModel extends BaseModel {
  String title;
  List chapters;
  int novelID;
  int volumeID;
  int chapterID;
  String data = '加载中';

  bool error = false;

  List<bool> expand = [];

  NovelModel(
      this.title, this.chapters, this.novelID, this.volumeID, this.chapterID) {
    getNovel(novelID, volumeID, chapterID);
    expand = chapters.map<bool>((e) => false).toList();
    logger.i(
        'class: NovelModel, action: init, novelID: $novelID, volumeID: $volumeID, chapterID: $chapterID');
  }

  Future<void> getNovel(int novelID, int volumeID, int chapterID) async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getNovel(novelID, volumeID, chapterID);
      if (response.statusCode == 200) {
        data = response.data;
        notifyListeners();
      }
    } catch (e) {
      error = true;
      logger.e(
          'class: NovelModel, action: getNovel, novelID: $novelID, volumeID: $volumeID, chapterID: $chapterID');
    }
  }

  void setExpand(int panelIndex, bool isExpanded) {
    if (panelIndex < chapters.length) {
      expand[panelIndex] = !isExpanded;
      notifyListeners();
    }
  }

  List<ExpansionPanel> buildChapterWidget(context) {
    return chapters.map<ExpansionPanel>((e) {
      return ExpansionPanel(
          canTapOnHeader: true,
          isExpanded: expand[chapters.indexOf(e)],
          headerBuilder: (context, state) => ListTile(
                title: Text('${e['volume_name']}'),
              ),
          body: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: e['chapters'].length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${e['chapters'][index]['chapter_name']}'),
                  onTap: () {
                    title = e['chapters'][index]['chapter_name'];
                    chapters = chapters;
                    novelID = novelID;
                    volumeID = e['volume_id'];
                    chapterID = e['chapters'][index]['chapter_id'];
                    getNovel(novelID, volumeID, chapterID);
                  },
                );
              }));
    }).toList();
  }
}
