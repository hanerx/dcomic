import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/model/baseModel.dart';
import 'package:flutterdmzj/utils/tool_methods.dart';
import 'package:flutterdmzj/view/novel_pages/novel_viewer_page.dart';

class NovelDetailModel extends BaseModel {
  final int novelID;

  bool error = false;

  String title = '加载中';
  String cover = 'http://manhua.dmzj.com/css/img/mh_logo_dmzj.png?t=20131122';
  String author = '';
  String types = '';
  int hotNum = 0;
  int subscribeNum = 0;
  String description = '加载中...';
  String updateDate = '';
  String status = '加载中';

  List chapters = [];
  List<bool> expand = [];

  NovelDetailModel(this.novelID) {
    getNovel(novelID).then((value) {
      getChapter(novelID);
    });
    logger.i('class: NovelDetailModel, action: initNovel, novelID: $novelID');
  }

  Future<void> getNovel(novelID) async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getNovelDetail(novelID);
      if (response.statusCode == 200) {
        title = response.data['name'];
        cover = response.data['cover'];
        author = response.data['authors'];
        types = response.data['types'][0];
        hotNum = response.data['hot_hits'];
        subscribeNum = response.data['subscribe_num'];
        description = response.data['introduction'];
        updateDate =
            ToolMethods.formatTimestamp(response.data['last_update_time']);
        status = response.data['status'];
        logger.i(
            'class: NovelDetailModel, action: getNovel, novelID: $novelID, title: $title, cover: $cover');
        notifyListeners();
      }
    } catch (e) {
      error = true;
      logger.e(
          'class: NovelDetailModel, action: getNovelFailed, novelID: $novelID, exception: $e');
    }
  }

  Future<void> getChapter(novelID) async {
    try {
      CustomHttp http = CustomHttp();
      var response = await http.getNovelChapter(novelID);
      if (response.statusCode == 200) {
        chapters = response.data;
        expand = chapters.map<bool>((e) => false).toList();
        notifyListeners();
      }
    } catch (e) {
      logger.e(
          'class: NovelDetailModel, action: getNovelChapterFailed, novelID: $novelID, exception: $e');
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
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return NovelViewerPage(
                        title: e['chapters'][index]['chapter_name'],
                        chapters: chapters,
                        novelID: novelID,
                        volumeID: e['volume_id'],
                        chapterID: e['chapters'][index]['chapter_id'],
                      );
                    }));
                  },
                );
              }));
    }).toList();
  }
}
