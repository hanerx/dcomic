
import 'package:flutter/material.dart';
import 'package:dcomic/http/http.dart';
import 'package:dcomic/model/baseModel.dart';

class NovelModel extends BaseModel {
  String title;
  List chapters;
  int novelID;
  int volumeID;
  int chapterID;
  String data = '加载中';

  bool error = false;

  List<bool> expand = [];

  List chapterList = [];

  NovelModel(
      this.title, this.chapters, this.novelID, this.volumeID, this.chapterID) {
    initChapterList();
    getNovel(novelID, volumeID, chapterID);
    expand = chapters.map<bool>((e) => false).toList();
    logger.i(
        'class: NovelModel, action: init, novelID: $novelID, volumeID: $volumeID, chapterID: $chapterID');
  }

  void initChapterList() {
    for (var item in chapters) {
      for (var chapter in item['chapters']) {
        chapterList.add({
          'chapterID': chapter['chapter_id'],
          'volumeID': item['volume_id'],
          'title': chapter['chapter_name']
        });
      }
    }
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

  Future<void> next() async {
    for (var i = 0; i < chapterList.length; i++) {
      if (chapterList[i]['chapterID'] == chapterID &&
          chapterList[i]['volumeID'] == volumeID) {
        if (i < chapterList.length - 1) {
          volumeID = chapterList[i + 1]['volumeID'];
          chapterID = chapterList[i + 1]['chapterID'];
          title = chapterList[i + 1]['title'];
          await getNovel(novelID, volumeID, chapterID);
          break;
        }
      }
    }
  }

  Future<void> previous() async {
    for (var i = 0; i < chapterList.length; i++) {
      if (chapterList[i]['chapterID'] == chapterID &&
          chapterList[i]['volumeID'] == volumeID) {
        if (i > 0) {
          volumeID = chapterList[i - 1]['volumeID'];
          chapterID = chapterList[i - 1]['chapterID'];
          title = chapterList[i - 1]['title'];
          await getNovel(novelID, volumeID, chapterID);
          break;
        }
      }
    }
  }

  List<ExpansionPanel> buildChapterWidget(context) {
    return chapters.map<ExpansionPanel>((e) {
      return ExpansionPanel(
          canTapOnHeader: true,
          isExpanded: expand[chapters.indexOf(e)],
          headerBuilder: (context, state) => ListTile(
                title: Text(
                  '${e['volume_name']}',
                  style: TextStyle(
                      color: e['volume_id'] == volumeID
                          ? Theme.of(context).textSelectionColor
                          : null),
                ),
              ),
          body: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: e['chapters'].length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    '${e['chapters'][index]['chapter_name']}',
                    style: TextStyle(
                        color: e['chapters'][index]['chapter_id'] == chapterID
                            ? Theme.of(context).textSelectionColor
                            : null),
                  ),
                  onTap: () {
                    title = e['chapters'][index]['chapter_name'];
                    chapters = chapters;
                    novelID = novelID;
                    volumeID = e['volume_id'];
                    chapterID = e['chapters'][index]['chapter_id'];
                    getNovel(novelID, volumeID, chapterID);
                    Navigator.pop(context);
                  },
                );
              }));
    }).toList();
  }
}
