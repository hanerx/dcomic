
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class BeautifulSoup {
  String htmlDoc;
  Document doc;
  BeautifulSoup(this.htmlDoc){
    doc = parse(htmlDoc);
  }

  Element find({String id}) {
    return doc.querySelector(id);
  }

  Element call(String selector) => doc.querySelector(selector);

  List<Element> findAll(String selector){
    return doc.querySelectorAll(selector);
  }

  String getText(){
    return doc.querySelector("html").text;
  }

  String print(){
    return doc.querySelector("html").outerHtml;
  }

  String attr(Element e,String attribute) => e.attributes[attribute];
}