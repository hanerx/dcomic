
import 'package:dcomic/http/UniversalRequestModel.dart';
import 'package:dcomic/protobuf/novel_chapter.pb.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:dcomic/model/baseModel.dart';

class NovelModel extends BaseModel {
  String title;
  List<NovelChapterVolumeResponse> chapters;
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
      for (var chapter in item.chapters) {
        chapterList.add({
          'chapterID': chapter.chapterId,
          'volumeID': item.volumeId,
          'title': chapter.chapterName
        });
      }
    }
  }

  Future<void> getNovel(int novelID, int volumeID, int chapterID) async {
    try {
      var response = await UniversalRequestModel.dmzjJuriRequestHandler.getNovel(volumeID, chapterID);
      if ((response.statusCode == 200||response.statusCode == 304)) {
        data = response.data;
        notifyListeners();
      }
    } catch (e,s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'getNovelFailed: $novelID, volumeID: $volumeID, chapterID: $chapterID');
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
                  '${e.volumeName}',
                  style: TextStyle(
                      color: e.volumeId == volumeID
                          ? Theme.of(context).textSelectionColor
                          : null),
                ),
              ),
          body: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: e.chapters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    '${e.chapters[index].chapterName}',
                    style: TextStyle(
                        color: e.chapters[index].chapterId == chapterID
                            ? Theme.of(context).textSelectionColor
                            : null),
                  ),
                  onTap: () {
                    title = e.chapters[index].chapterName;
                    chapters = chapters;
                    novelID = novelID;
                    volumeID = e.volumeId;
                    chapterID = e.chapters[index].chapterId;
                    getNovel(novelID, volumeID, chapterID);
                    Navigator.pop(context);
                  },
                );
              }));
    }).toList();
  }
}
