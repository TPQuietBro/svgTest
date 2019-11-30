import 'package:fage_render/Reader.dart';
import 'package:flutter/material.dart';

const String _blank = ' ';

class ReaderPage {
  static List offsets = [];
  static Future<List> getPages(Size size, content) async {
    String tempStr = content;
    List contents = [];
    TextPainter textPainter = _textPainter(tempStr);
    textPainter.layout(maxWidth: size.width);
    var offset = 0; 
    while (true) {
      var end = textPainter
          .getPositionForOffset(Offset(size.width, size.height))
          .offset;
      offset += end;
      offsets.add(offset);
      if (end == 0) break;

      String pageString = '';
      if (end > tempStr.length) {
        pageString =
          tempStr.substring(0, tempStr.length);
      } else {
        pageString =
          tempStr.substring(0, end);
      }

      if (end >= tempStr.length) {
        contents.add(filterStartReturn(pageString));
        break;
      }

      contents.add(pageString);

      tempStr = tempStr.substring(end, tempStr.length);
      tempStr = filterStartReturn(tempStr);

      if (tempStr.startsWith(_blank)) {
        tempStr = tempStr.substring(1);
      } else if (endWithReturn(pageString)) {
        contents.remove(pageString);
        pageString = filterEndReturn(pageString);
        tempStr = pageString + tempStr;
        offsets.remove(end);
      } else if (startWithReturn(pageString)) {
        contents.remove(pageString);
        pageString = filterStartReturn(pageString);
        tempStr = pageString + tempStr;
        offsets.remove(end);
      } else if (pageString.endsWith('\n ')) {
        contents.remove(pageString);
        pageString = pageString.substring(0,pageString.length - 2);
        tempStr = pageString + tempStr;
        offsets.remove(end);
      } else if (pageString.endsWith(' ')) {
        contents.remove(pageString);
        pageString = pageString.substring(0,pageString.length - 1);
        tempStr = pageString + tempStr;
        offsets.remove(end);
      }

      textPainter = _textPainter(tempStr);
      textPainter.layout(maxWidth: size.width);
    }
    return contents;
  }


  static TextPainter _textPainter(String content, {bool isFirstPage = false}) {
    return TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: content, 
        style: ReaderUtil.textStyle())
    );
  }

  static String filterStartReturn(String content) {
    while (startWithReturn(content)) {
      content = content.substring(1);
    }
    return content;
  }

  static String filterEndReturn(String content) {
    while (endWithReturn(content)) {
      content = content.substring(0,content.length - 1);
    }
    return content;
  }

  static bool endWithReturn(String content){
    return content.endsWith('\n');
  }
  static bool startWithReturn(String content){
    return content.startsWith('\n');
  }
}