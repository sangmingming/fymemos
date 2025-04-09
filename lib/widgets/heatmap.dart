import 'package:flutter/material.dart';
import 'package:fymemos/utils/datetime.dart';
import 'package:intl/intl.dart' as intl;

class HeatMap extends StatelessWidget {
  final double aspectRation;
  final Map<DateTime, int> data;

  List<Color>? colors;
  final TextStyle? textStyle;
  final Color? strokeColor;
  final double itemSize;
  final double itemPadding;

  HeatMap({
    super.key,
    required this.data,
    this.aspectRation = 2.3,
    this.colors,
    this.textStyle,
    this.strokeColor,
    this.itemSize = 10,
    this.itemPadding = 4,
  });
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRation,
      child: CustomPaint(
        painter: HeatMapPainter(
          data: data,
          colors:
              colors ??
              [
                Colors.grey[300]!,
                Colors.green[300]!,
                Colors.green[500]!,
                Colors.green[700]!,
                Colors.green[900]!,
              ],
          textStyle:
              textStyle ??
              TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 12,
              ),
          strokeColor:
              strokeColor ?? Theme.of(context).colorScheme.onSecondaryContainer,
          itemSize: itemSize,
          itemPadding: itemPadding,
        ),
      ),
    );
  }
}

class HeatMapPainter extends CustomPainter {
  final Map<DateTime, int> data;
  final List<Color> colors;
  final TextStyle textStyle;
  final Color strokeColor;
  final double itemSize;
  final double itemPadding;

  static const int rows = 7;
  List<bool> hasDrawnMonth = [];

  HeatMapPainter({
    required this.data,
    required this.colors,
    required this.textStyle,
    required this.strokeColor,
    required this.itemSize,
    required this.itemPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    int cols = _calculateColumns(size.width);
    hasDrawnMonth = List.filled(cols, false);

    int totalCount = cols * rows;
    double heatMapWidth = _calculateHeatMapWidth(cols);
    double startX = _calculateStartX(size.width, heatMapWidth);
    Paint strokePaint = createStrokePaint();

    for (int i = 0; i < totalCount; i++) {
      DateTime dateAtIndex = _calculateDateForIndex(cols, i);
      if (dateAtIndex.isAfter(DateTime.now().midnight)) {
        break;
      }
      int value = data[dateAtIndex] ?? 0;
      paint.color = _getColorForValue(value);
      _drawCell(canvas, paint, i, startX, strokePaint, dateAtIndex);
    }
  }

  void _drawCell(
    Canvas canvas,
    Paint paint,
    int index,
    double startX,
    Paint strokePaint,
    DateTime dateAtIndex,
  ) {
    var col = index ~/ rows;
    var row = index % rows;
    final rect = _calculateCellRect(startX, col, row);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      paint,
    );

    if (dateAtIndex.isToday) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        strokePaint,
      );
    }

    if (dateAtIndex.day == 1 && !hasDrawnMonth[col]) {
      _drawMonthText(canvas, dateAtIndex, col, startX);
      hasDrawnMonth[col] = true;
    }
  }

  int _calculateColumns(double width) {
    return (width + itemPadding) ~/ (itemSize + itemPadding);
  }

  double _calculateHeatMapWidth(int cols) {
    return cols * (itemSize + itemPadding) - itemPadding;
  }

  double _calculateStartX(double totalWidth, double heatMapWidth) {
    return (totalWidth - heatMapWidth) / 2;
  }

  Rect _calculateCellRect(double startX, int col, int row) {
    return Rect.fromLTWH(
      startX + col * (itemSize + itemPadding),
      row * (itemSize + itemPadding),
      itemSize,
      itemSize,
    );
  }

  Paint createStrokePaint() {
    return Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
  }

  void _drawMonthText(Canvas canvas, DateTime date, int col, double startX) {
    String monthText = intl.DateFormat('MMM').format(date);

    TextPainter monthTextPainter = TextPainter(
      text: TextSpan(text: monthText, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    monthTextPainter.layout();

    double xPosition = _calculateTextXPosition(
      col,
      startX,
      monthTextPainter.width,
    );
    Offset textPosition = Offset(
      xPosition,
      (rows * (itemSize + itemPadding)) + itemPadding,
    );
    monthTextPainter.paint(canvas, textPosition);
  }

  double _calculateTextXPosition(int col, double startX, double textWidth) {
    double colRightBoundary =
        startX + col * (itemSize + itemPadding) + itemSize;
    return colRightBoundary - textWidth - itemPadding;
  }

  DateTime _calculateDateForIndex(int cols, int index) {
    DateTime startOfCurrentWeek = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    DateTime startDate = startOfCurrentWeek.subtract(
      Duration(days: 7 * (cols - 1)),
    );
    int weeksPassed = index ~/ 7;
    int dayOfWeek = index % 7;
    return startDate.add(Duration(days: 7 * weeksPassed + dayOfWeek)).midnight;
  }

  Color _getColorForValue(int value) {
    if (value >= colors.length) {
      return colors.last;
    } else {
      return colors[value % colors.length];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
