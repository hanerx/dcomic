import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/view/mag_maker/mag_guide_page.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class NewMagPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NewMagPage();
  }
}

class _NewMagPage extends State<NewMagPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('新建漫画'),
      ),
      body: ListView(
        children: [
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                leading: Icon(FontAwesome5.code),
                trailing: Icon(Icons.chevron_right),
                title: Text('内置编辑器'),
                subtitle: Text(
                    '使用内置编辑器直接对code进行编程，功能齐全且不受encoder或decoder限制，但需要有一定的json编辑能力'),
              ),
            ),
            onPressed: () {},
          ),
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                leading: Icon(FontAwesome5.tasks),
                trailing: Icon(Icons.chevron_right),
                title: Text('构建向导'),
                subtitle: Text(
                    '使用构建向导进行构建，使用简单，但功能需要等待软件更新，且不能支持软件不支持的encoder或decoder'),
              ),
            ),
            onPressed: () {},
          ),
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                leading: Icon(FontAwesome5.folder_open),
                trailing: Icon(Icons.chevron_right),
                title: Text('从文件中打开'),
                subtitle: Text('打开一个已存在的.manga文件并使用该文件进行编辑'),
              ),
            ),
            onPressed: () {},
          ),
          FlatButton(
            padding: EdgeInsets.all(5),
            child: Card(
              child: ListTile(
                leading: Icon(FontAwesome5.flag),
                trailing: Icon(Icons.chevron_right),
                title: Text('新手教程'),
                subtitle: Text('打开一次新手教程，用最不清晰的流程带你看一遍怎么新建一个.manga文件'),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MagGuidePage(
                        guide: [
                          {"type": 0, "data": "嘿嘿，这里是作者，我们今天来写点东西，看到上面的编辑器了吗，来让我们来写上一个json",'replace':true},
                          {"type": 1, "data": '''{"data":"hello world!"}''','replace':true},
                          {"type":0,"data":"嘿嘿，是不是很神奇，这里是我们的.manga文件的教程展示处，下面这个是作者的话，上面的是代码实例。对了，你可以点击edit来尝试编辑，但是最好不要在动画在动的时候操作，毕竟我不知道会不会出bug",'replace':true},
                          {'type':0,'data':'你可以用侧边栏查看你写好的json文件的结构，比如像这样。','replace':true},
                          {'type':2,'tab':0},
                          {'type':3},
                          {'type':0,'data':'你也可以点击右上角弹出侧边栏或者干脆直接侧滑，都可以打开这个东西。','replace':false},
                          {'type':0,'data':'如果感觉现在这个速度很难看清字幕，或者你脑子跟不上了，你可以点击暂停或者上一步和下一步，这些都会自动停止播放让你有休息时间','replace':true},
                          {'type':0,'data':'那我们开始吧，先写个最简单meta文件','replace':true},
                          {'type':1,'data':'''{\n\t"name":"test_manga",\n\t"title":"简单学会如何制作.manga文件"\n}''','replace':true},
                          {'type':0,'data':'我们先来说明一下.manga文件的原理和目录结构：\n    manga文件其实是一个zip封装文件，而里面主要分为两个部分，一个是meta.json一个是data文件夹。meta.json是文件的入口文件，而data文件夹则存储数据使用。TIPS：data文件夹并不是必须的，你要存储的文件也不是必须存在data文件夹下，唯一必须的是你的meta.json','replace':true},
                          {'type':0,'data':'那我们回到meta.json这个入口文件。最简单的meta.json只需要两个参数————对，就是上面两个。第一个说是name其实是manga文件的唯一识别符，所有的manga文件不管你里面塞得是啥，判断两个文件是不是同一本漫画就依靠的是这个属性。\n    个人比较推荐你们使用罗马音的标题并不带有章节号等其他内容，空格使用下划线_替代。至于原因，为了通用性，毕竟不是所有软件都是支持utf-8的，全英文字母的罗马音既保证不会出现翻译歧义也可以保证兼容性。','replace':true},
                          {'type':0,'data':'至于title属性，大家快乐就好。你写个霸道总裁爱上我然后name写上素晴的罗马音也行，程序会认为这本和素晴是同一种东西。。。','replace':true},
                          {'type':0,'data':'好，这个基础版的meta文件是不是已经熟悉了？那我们来点高级的，让我们加点“细节”','replace':true},
                          {'type':1,'data':'''{\n\t"name":"test_manga",\n\t"title":"简单学会如何制作.manga文件",\n\t"alias":[\n\t\t".manga从入门到精通",\n\t\t".manga Program design"\n\t],\n\t"authors":["hanerx"]\n}''','replace':true},
                          {'type':0,'data':'好der，我们现在加了两行','replace':true}
                        ],
                      )));
            },
          ),
        ],
      ),
    );
  }
}
