import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dcomic/model/baseModel.dart';
import 'package:dcomic/model/comic_source/baseSourceModel.dart';
import 'package:flutter_archive/flutter_archive.dart' as FlutterArchive;
import 'package:path_provider/path_provider.dart';

typedef ProcessCallBack = void Function(double value, String message);

class BaseMangaModel extends BaseModel {
  Future<MangaObject> decodeFromPath(String path,
      {String outputPath, ProcessCallBack callBack}) {
    if (callBack == null) {
      callBack = (value, message) {};
    }
    return decodeFromFile(File(path),
        outputPath: outputPath, callBack: callBack);
  }

  Future<MangaObject> decodeFromFile(File file,
      {String outputPath, ProcessCallBack callBack}) async {
    if (callBack == null) {
      callBack = (value, message) {};
    }
    callBack(0.1, '检查文件是否存在');
    if (await file.exists()) {
      // return decodeFromBytes(file.readAsBytesSync(),
      //     outputPath: outputPath, callBack: callBack);
      // return decodeFromStream(InputStream(file.readAsBytesSync()),outputPath: outputPath,callBack: callBack);
      return decodeFromZip(file, outputPath: outputPath, callBack: callBack);
    } else {
      throw FileInvalidError();
    }
  }

  Future<MangaObject> decodeFromZip(File file,
      {String outputPath, ProcessCallBack callBack}) async {
    if (callBack == null) {
      callBack = (value, message) {};
    }
    if (outputPath == null) {
      callBack(0.15, '设置默认解压目录');
      outputPath = (await getTemporaryDirectory()).path + '/TempManga';
      if (await Directory(outputPath).exists()) {
        await Directory(outputPath).delete();
      }
    }
    callBack(0.2, '开始解压');
    await FlutterArchive.ZipFile.extractToDirectory(
        zipFile: file,
        destinationDir: Directory(outputPath),
        onExtracting: (zipEntry, progress) {
          callBack(0.2 + progress / 1000 * 4, '解压内容：${zipEntry.name}');
          return FlutterArchive.ExtractOperation.extract;
        });
    return decodeFromDirectory(outputPath, callBack: callBack);
  }

  Future<MangaObject> decodeFromBytes(List<int> bytes,
      {String outputPath, ProcessCallBack callBack}) async {
    if (callBack == null) {
      callBack = (value, message) {};
    }
    if (outputPath == null) {
      callBack(0.2, '设置默认解压目录');
      outputPath = (await getTemporaryDirectory()).path + '/TempManga';
      if (await Directory(outputPath).exists()) {
        await Directory(outputPath).delete();
      }
    }
    callBack(0.2, '开始解压');
    var zip = ZipDecoder().decodeBytes(bytes);
    int i = 0;
    for (final item in zip) {
      i++;
      callBack(0.2 + (i / zip.length) / 10 * 4, '解压内容：${item.name}');
      if (item.isFile) {
        final data = item.content as List<int>;
        File(outputPath + '/' + item.name)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(outputPath + '/' + item.name)..create(recursive: true);
      }
    }
    return decodeFromDirectory(outputPath, callBack: callBack);
  }

  Future<MangaObject> decodeFromDirectory(String outputPath,
      {ProcessCallBack callBack}) async {
    if (callBack == null) {
      callBack = (value, message) {};
    }
    if (await File(outputPath + '/meta.json').exists()) {
      callBack(0.6, '进行解压后验证');
      Map json = jsonDecode(File(outputPath + '/meta.json').readAsStringSync());
      return MangaObject.fromMap(json, outputPath, callBack: callBack);
    } else {
      throw FileInvalidError();
    }
  }
}

class MangaObject {
  static String version = '1.0.0-beta';
  static Map<String, Decoder> decoders = {
    'string': StringDecoder(),
    'default': DefaultDecoder(),
    'default_volume_decoder': DefaultVolumeDecoder(),
    'default_chapter_decoder': DefaultChapterDecoder(),
    'local_path_decoder': LocalPathDecoder()
  };

  String name;
  String title;

  String description;
  List<TagObject> authors;
  List<TagObject> tags;
  List<VolumeObject> data;
  String cover;
  PageType coverPageType;
  String status;

  int lastUpdateTimeStamp;

  String basePath;

  MangaObject.fromMap(Map map, String filepath, {ProcessCallBack callBack}) {
    if (callBack == null) {
      callBack = (value, message) {};
    }
    if (map.containsKey('name') && map.containsKey('title')) {
      callBack(0.7, '解析基础');
      name = autoDecode(map['name'], filepath);
      title = autoDecode(map['title'], filepath);

      callBack(0.8, '解析详情');
      description = autoDecode<String>(map['description'], filepath);
      authors = autoDecode<TagObject>(map['authors'], filepath,
          defaultDecoder: DefaultTagDecoder());
      tags = autoDecode<TagObject>(map['tags'], filepath,
          defaultDecoder: DefaultTagDecoder());

      callBack(0.9, '解析章节');
      data = autoDecode<VolumeObject>(map['data'], filepath,
          defaultDecoder: DefaultVolumeDecoder());
      cover = autoDecode(map['cover'], filepath,
          defaultDecoder: LocalPathDecoder());
      status = autoDecode(map['status'], filepath);
      lastUpdateTimeStamp = autoDecode(map['last_update_timestamp'], filepath);
      basePath = filepath;
      callBack(1.0, '解析完成');
    } else {
      throw MetaDecodeError(message: '必要解析内容不存在');
    }
  }

  static dynamic autoDecode<T>(dynamic data, String outputPath,
      {Decoder defaultDecoder}) {
    if (data == null) {
      return data;
    }
    if (data is String) {
      if (defaultDecoder != null) {
        return defaultDecoder.decode(data, outputPath);
      }
      return StringDecoder().decode(data, outputPath);
    } else if (data is Map) {
      if (data.containsKey('decoder')) {
        if (decoders.containsKey(data['decoder'])) {
          return decoders[data['decoder']].decode(data['data'], outputPath);
        } else {
          throw NoDecoderError(data['decoder']);
        }
      } else {
        if (defaultDecoder != null) {
          return defaultDecoder.decode(data, outputPath);
        }
        return data;
      }
    } else if (data is List) {
      return data
          .map<T>(
              (e) => autoDecode(e, outputPath, defaultDecoder: defaultDecoder))
          .toList();
    } else {
      if (defaultDecoder != null) {
        return defaultDecoder.decode(data, outputPath);
      }
      return DefaultDecoder().decode(data, outputPath);
    }
  }

  String get lastChapter =>
      data != null && data.length > 0 ? data.first.lastChapter : '无';
}

class VolumeObject {
  final String name;
  final String title;
  final List<ChapterObject> chapters;

  VolumeObject(this.name, this.title, this.chapters) {
    this.chapters.sort((left, right) => right.compareTo(left));
  }

  ChapterObject indexOf(String name) {
    for (var item in chapters) {
      if (item.name == name) {
        return item;
      }
    }
    return null;
  }

  String get lastChapter =>
      chapters != null && chapters.length > 0 ? chapters.first.title : '无';
}

class ChapterObject implements Comparable {
  final String name;
  final int timestamp;
  final int order;
  final String title;
  final List<String> pages;
  final PageType type;
  final Map<String, String> headers;

  ChapterObject(this.name, this.timestamp, this.order, this.title, this.pages,
      this.type, this.headers);

  @override
  int compareTo(other) {
    // TODO: implement compareTo
    if (other is ChapterObject) {
      if (order == null && other.order == null) {
        return 0;
      } else if (other.order == null) {
        return 1;
      } else if (order == null) {
        return -1;
      }
      return this.order.compareTo(other.order);
    }
    return 0;
  }
}

class TagObject {
  final String name;
  final String id;

  TagObject(this.name, this.id);

  toMap() {
    return {'tag_name': name, 'tag_id': id};
  }

  @override
  String toString() {
    // TODO: implement toString
    return '$name';
  }
}

class ImageObject {
  final String url;
  final PageType pageType;

  ImageObject(this.url, this.pageType);
}

class FileInvalidError implements Exception {}

class MetaDecodeError implements Exception {
  final Exception e;
  final String message;

  MetaDecodeError({this.e, this.message});
}

class NoDecoderError implements Exception {
  final String decoder;

  NoDecoderError(this.decoder);
}

abstract class Decoder {
  dynamic decode(dynamic data, String outputPath);
}

class StringDecoder extends Decoder {
  @override
  String decode(data, String outputPath) {
    // TODO: implement decode
    if (data == null) {
      return null;
    }
    switch (data.runtimeType) {
      case String:
        return data;
      default:
        return data.toString();
    }
  }
}

class DefaultDecoder extends Decoder {
  @override
  decode(data, String outputPath) {
    // TODO: implement decode
    return data;
  }
}

class DefaultTagDecoder extends Decoder {
  @override
  TagObject decode(data, String outputPath) {
    // TODO: implement decode
    if (data is String) {
      return TagObject(data, null);
    } else if (data is Map) {
      return TagObject(data['tag_name'], data['tag_id']);
    }
    return TagObject(data.toString(), null);
  }
}

class DefaultVolumeDecoder extends Decoder {
  @override
  VolumeObject decode(data, String outputPath) {
    // TODO: implement decode
    return VolumeObject(
        data['name'],
        data['title'],
        MangaObject.autoDecode<ChapterObject>(data['data'], outputPath,
            defaultDecoder: DefaultChapterDecoder()));
  }
}

class DefaultChapterDecoder extends Decoder {
  @override
  ChapterObject decode(data, String outputPath) {
    // TODO: implement decode
    return ChapterObject(
        data['name'],
        data['timestamp'],
        data['order'],
        data['title'],
        MangaObject.autoDecode<String>(data['data'], outputPath,
            defaultDecoder: LocalPathDecoder()),
        PageType.local,
        {});
  }
}

class LocalPathDecoder extends Decoder {
  @override
  String decode(data, String outputPath) {
    // TODO: implement decode
    var directory = Directory(outputPath);
    if (data.toString().startsWith('..')) {
      return directory.parent.path + data.toString().substring(2);
    } else if (data.toString().startsWith('.')) {
      return directory.path + data.toString().substring(1);
    }
    return data.toString();
  }
}
