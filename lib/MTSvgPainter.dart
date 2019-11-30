import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:typed_data';

class MTSvgManager {

  static drawSvgString(canvas,paint,rawSvg,{List matrix}){

    xml.XmlDocument document = xml.parse(rawSvg);
    List listPath = document.findAllElements('path').toList();

    for (xml.XmlElement element in listPath) {
      xml.XmlAttribute attribute = element.attributes.last;
      // print('svg : '+attribute.value);
      Path newPath = parseSvgPathData(attribute.value);
      if (matrix != null) {
        Float64List matrix4 = Float64List.fromList(matrix);
        newPath.transform(matrix4);
      }
      canvas.drawPath(newPath, paint);

    }
  }

  static drawSvgPoints(canvas,paint,points,{List matrix}){

    String rawSvg = _svgString(points);

    drawSvgString(canvas, paint, rawSvg,matrix:matrix);
  }

  static drawSvgRect(canvas,paint,Offset start,Offset end,{List matrix}){

    var startPoint = start;
    var endPoint = end;
    double pWidth = endPoint.dx - startPoint.dx;
    double pHeight = endPoint.dy - startPoint.dy;

    Offset secondPoint = Offset(startPoint.dx + pWidth,startPoint.dy);
    Offset thirdPoint = Offset(startPoint.dx,startPoint.dy+pHeight);

    String rawSvg = _svgString([startPoint, secondPoint, endPoint, thirdPoint, startPoint]);

    drawSvgString(canvas, paint, rawSvg,matrix:matrix);
  }

  static _svgSubPaths(List points){
    List paths = [];
    String tag = '';
    for (var i = 0; i < points.length; i++) {
      Offset point = points[i];
      
      if (i == 0) {
        tag = 'M';
      } else {
        tag = 'L';
      }
      
      String subPath = _svgSubPath(point, tag);
      paths.add(subPath);
    }
    return paths;
  }

  static _svgString(List points){
    List paths = _svgSubPaths(points);
    String string = '';
    for (var i = 0; i < paths.length; i++) {
      String path = paths[i];
      if (i == paths.length - 1) {
        string += '$path';
        break;
      }
      string += '$path ';
    }

    return '<svg><path d="$string"/></svg>';
  }

  static _svgSubPath(Offset point,String tag){
    String svg = tag;
    svg = svg + '${point.dx},${point.dy}';
    return svg;
  }
}

enum WBPathSementDataType {
  M,
  L,
  C
}

class WBPathSementData{
  WBPathSementDataType dataType;
  Offset point;
  WBPathSementData(this.dataType,this.point);
}