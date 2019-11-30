import 'dart:typed_data';
import 'dart:ui';

import 'package:fage_render/MTSvgPainter.dart';
import 'package:fage_render/Reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart' as xml;

import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

double count = 1;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Size size = Size(Screen.width, Screen.height);

  List points = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: Container(
            width: this.size.width,
            child: Listener(
              child: CustomPaint(
                painter: TestPainter(points: this.points),
                size: this.size,
              ),
              onPointerUp: (PointerUpEvent event) {
                this.points.add(null);
              },
              onPointerMove: (PointerMoveEvent event) {
                Offset offset = event.localPosition;
                List newList = this.points;
                newList.add(offset);
                this.points = newList;
                setState(() {});
                // print(offset);
              },
            )));
  }
}

class TestPainter extends CustomPainter {
  final List points;
  TestPainter({this.points});
  @override
  bool shouldRepaint(TestPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();

    Color strokeColor = Colors.red;
    double width = 10;

    paint.color = strokeColor;
    // paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width;
    // paint.strokeCap = StrokeCap.round;

    List points = this.points;
    List leftPoints = [];

    List rightPoints = [];
    for (var i = 0; i < points.length - 1; i++) {
      Offset subPoint = points[i];
      Offset nextPoint = points[i + 1];
      if (subPoint != null && nextPoint != null) {
        double x1 = subPoint.dx;
        double y1 = subPoint.dy;

        double x2 = nextPoint.dx;
        double y2 = nextPoint.dy;

        double distance = width / 2;

        if (!isSamePoint(subPoint, nextPoint)) {
          double minX = (x1 - x2).abs();
          double minY = (y1 - y2).abs();

          double tanP;

          if (minX != 0) {
            tanP = minY / minX;
            double y = sqrt(pow(distance, 2) / (pow(tanP, 2).toDouble() + 1));
            double x = y * tanP;

            Offset bottomRightPoint = Offset(x + x1, y + y1);
            rightPoints.add(bottomRightPoint);

            Offset bottomLeftPoint = Offset(x1 - x, y1 - y);
            leftPoints.add(bottomLeftPoint);

            print('tan : $tanP');
          } else if (minX == 0) {
            Offset bottomRightPoint = Offset(x1 + distance, y1);
            rightPoints.add(bottomRightPoint);

            Offset bottomLeftPoint = Offset(x1 - distance, y1);
            leftPoints.add(bottomLeftPoint);
          } else if (minY == 0) {
            Offset bottomRightPoint = Offset(x1, y1 + distance);
            rightPoints.add(bottomRightPoint);

            Offset bottomLeftPoint = Offset(x1, y1 - distance);
            leftPoints.add(bottomLeftPoint);
          }

          

          
          // print('oriPoint:$subPoint, bottomRightPoint : $bottomRightPoint , bottomLeftPoint :$bottomLeftPoint');
        }

        // MTSvgManager.drawSvgPoints(canvas, paint, allPoints);
      }
    }

    List allPoints = [];

    allPoints.addAll(leftPoints);
    allPoints.addAll(rightPoints.reversed.toList());

    if (allPoints.length == 0) return;

    Offset first = allPoints.first;
    Path path = Path();
    path.moveTo(first.dx, first.dy);

    for (var i = 0; i < allPoints.length - 1; i++) {
      Offset point = allPoints[i];
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);
  }

  showBorderPath() {}

  bool isSamePoint(Offset point1, Offset point2) {
    return point1.dx.toInt() == point2.dx.toInt() &&
        point1.dy.toInt() == point2.dy.toInt();
  }

  // List list = element.attributes;
  //   for (var i = 0; i < list.length; i++) {
  //     xml.XmlAttribute attribute = list[i];
  //     String name = attribute.name.toString();
  //     String value = attribute.value;
  //     if (name == 'stroke'){
  //       value = '0xFF' + value.substring(1);
  //       strokeColor = Color(int.parse(value));
  //     } else if (name == 'stroke-width'){
  //       width = double.parse(value);
  //     } else if (name == 'fill') {
  //       if (value == '#000000'){
  //         style = PaintingStyle.stroke;
  //       } else {
  //         style = PaintingStyle.fill;
  //       }
  //     }
  //   }
}
