/* *
* @Author: tangpeng
* Create on: 2019-11-25 09:30:52
* Description:  MoTouch
*/
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class WBTextDashLineWidget extends StatefulWidget {
  final Size paintSize;
  WBTextDashLineWidget({this.paintSize = Size.zero});
  @override
  _WBTextDashLineWidget createState() => _WBTextDashLineWidget();
}

class _WBTextDashLineWidget extends State<WBTextDashLineWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.paintSize.width,
        height: widget.paintSize.height,
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
          Positioned(child: CustomPaint(
            painter: DashPainter(),
            size: widget.paintSize,
          ),),
          leftTopPoint(),
          rightTopPoint(),
          leftBottomPoint(),
          rightBottomPoint()
        ],
      )
      );
  }

  leftTopPoint(){
    return Positioned(
      left: -2,
      top: -2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          width: 4,
          height: 4,
          color: Colors.white,
        ),
      ),
    );
  }

  rightTopPoint(){
    return Positioned(
      right: -2,
      top: -2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          width: 4,
          height: 4,
          color: Colors.white,
        ),
      ),
    );
  }
  leftBottomPoint(){
    return Positioned(
      left: -2,
      bottom: -2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          width: 4,
          height: 4,
          color: Colors.white,
        ),
      ),
    );
  }
  rightBottomPoint(){
    return Positioned(
      right: -2,
      bottom: -2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          width: 4,
          height: 4,
          color: Colors.white,
        ),
      ),
    );
  }
}

class DashPainter extends CustomPainter {
  @override
  bool shouldRepaint(DashPainter oldDelegate) {
    return false;
  }
  @override
  void paint(Canvas canvas, Size size) {

    var paint = Paint();

    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;

    var startPoint = Offset(0, 0);
    var endPoint = Offset(size.width, size.height);

    var path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    path.addRect(Rect.fromPoints(startPoint,endPoint));

    canvas.drawPath(dashPath(
      path,
      dashArray: CircularIntervalList<double>(<double>[2, 4]),
    ), paint);
  }
}
