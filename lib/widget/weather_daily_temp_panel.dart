import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/model/weather_detail_data.dart';
import 'package:flutter_yd_weather/res/colours.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';

class WeatherDailyTempPanel extends StatelessWidget {
  const WeatherDailyTempPanel({
    super.key,
    this.width,
    this.height,
    required this.preData,
    required this.data,
    required this.nextData,
    required this.maxTemp,
    required this.minTemp,
  });

  final double? width;
  final double? height;
  final WeatherDetailData? preData;
  final WeatherDetailData? data;
  final WeatherDetailData? nextData;
  final int maxTemp;
  final int minTemp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: _WeatherDailyTempPanelDecoration(
        weatherDailyTempPanel: this,
      ),
    );
  }
}

class _WeatherDailyTempPanelDecoration extends Decoration {
  final WeatherDailyTempPanel weatherDailyTempPanel;

  const _WeatherDailyTempPanelDecoration({
    required this.weatherDailyTempPanel,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _WeatherDailyTempPanelPainter(weatherDailyTempPanel, onChanged);
  }
}

class _WeatherDailyTempPanelPainter extends BoxPainter {
  final WeatherDailyTempPanel _weatherDailyTempPanel;
  final _topAndBottomGaps = 32.w;
  final _path = Path();
  final _linePaint = Paint()
    ..color = Colours.white
    ..isAntiAlias = true
    ..strokeWidth = 1.w
    ..style = PaintingStyle.stroke;
  final _circlePaint = Paint()
    ..color = Colours.white
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  _WeatherDailyTempPanelPainter(
    this._weatherDailyTempPanel,
    VoidCallback? onChanged,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    _path.reset();
    _drawStartArea(canvas, rect);
    _drawStartArea(canvas, rect, isHigh: false);
    _drawCenterArea(canvas, rect);
    _drawCenterArea(canvas, rect, isHigh: false);
    _drawEndArea(canvas, rect);
    _drawEndArea(canvas, rect, isHigh: false);
  }

  void _drawStartArea(Canvas canvas, Rect rect, {bool isHigh = true}) {
    final preData = _weatherDailyTempPanel.preData;
    final data = _weatherDailyTempPanel.data;
    final nextData = _weatherDailyTempPanel.nextData;
    if (preData == null && data != null && nextData != null) {
      double tempYAxis =
          _calTempYAxis(rect, (isHigh ? data.high : data.low) ?? 0);
      final nextTempYAxis =
          _calTempYAxis(rect, (isHigh ? nextData.high : nextData.low) ?? 0);
      _path.moveTo(rect.center.dx, tempYAxis);
      _path.quadraticBezierTo(
        rect.center.dx + rect.width / 4,
        (nextTempYAxis - tempYAxis) / 4 + tempYAxis,
        rect.right,
        (nextTempYAxis - tempYAxis) / 2 + tempYAxis,
      );
      canvas.drawPath(
        _path,
        _linePaint..color = Colours.white.withValues(alpha: 0.3),
      );
      canvas.drawCircle(
        Offset(rect.center.dx, tempYAxis),
        2.5.w,
        _circlePaint..color = Colours.white.withValues(alpha: 0.3),
      );
      _drawTemp(
        canvas,
        rect,
        (isHigh ? data.high : data.low).getTemp(),
        Colours.white.withValues(alpha: 0.3),
        tempYAxis,
        isHigh: isHigh,
      );
    }
  }

  void _drawCenterArea(Canvas canvas, Rect rect, {bool isHigh = true}) {
    final preData = _weatherDailyTempPanel.preData;
    final data = _weatherDailyTempPanel.data;
    final nextData = _weatherDailyTempPanel.nextData;
    if (preData != null && data != null && nextData != null) {
      bool isToday = data.date.isToday();
      bool isBefore = data.date.isBefore();
      double tempYAxis =
          _calTempYAxis(rect, (isHigh ? data.high : data.low) ?? 0);
      final preTempYAxis =
          _calTempYAxis(rect, (isHigh ? preData.high : preData.low) ?? 0);
      final nextTempYAxis =
          _calTempYAxis(rect, (isHigh ? nextData.high : nextData.low) ?? 0);
      final moveToY = (preTempYAxis - tempYAxis) / 2 + tempYAxis;
      _path.moveTo(rect.left, moveToY);
      final p1 = Point(
          rect.left + rect.width / 4, (moveToY - tempYAxis) / 2 + tempYAxis);
      final p2 = Point(rect.right - rect.width / 4,
          (nextTempYAxis - tempYAxis) / 4 + tempYAxis);
      _path.cubicTo(
        p1.x,
        p1.y,
        p2.x,
        p2.y,
        rect.right,
        (nextTempYAxis - tempYAxis) / 2 + tempYAxis,
      );
      final cm = _path.computeMetrics();
      for (var pm in cm) {
        final extractPath1 = pm.extractPath(0, pm.length / 2);
        final extractPath2 = pm.extractPath(pm.length / 2, pm.length);
        canvas.drawPath(
            extractPath1,
            _linePaint
              ..color = isToday || isBefore
                  ? Colours.white.withValues(alpha: 0.3)
                  : Colours.white);
        canvas.drawPath(
            extractPath2,
            _linePaint
              ..color =
                  isBefore ? Colours.white.withValues(alpha: 0.3) : Colours.white);
      }
      canvas.drawCircle(
          Offset(rect.center.dx, (p2.y - p1.y) / 2 + p1.y),
          2.5.w,
          _circlePaint
            ..color =
                isBefore ? Colours.white.withValues(alpha: 0.3) : Colours.white);
      _drawTemp(
        canvas,
        rect,
        (isHigh ? data.high : data.low).getTemp(),
        isBefore ? Colours.white.withValues(alpha: 0.3) : Colours.white,
        (p2.y - p1.y) / 2 + p1.y,
        isHigh: isHigh,
      );
    }
  }

  void _drawEndArea(Canvas canvas, Rect rect, {bool isHigh = true}) {
    final preData = _weatherDailyTempPanel.preData;
    final data = _weatherDailyTempPanel.data;
    final nextData = _weatherDailyTempPanel.nextData;
    if (preData != null && data != null && nextData == null) {
      double tempYAxis =
          _calTempYAxis(rect, (isHigh ? data.high : data.low) ?? 0);
      final preTempYAxis =
          _calTempYAxis(rect, (isHigh ? preData.high : preData.low) ?? 0);
      _path.moveTo(rect.center.dx, tempYAxis);
      _path.quadraticBezierTo(
        rect.center.dx - rect.width / 4,
        (preTempYAxis - tempYAxis) / 4 + tempYAxis,
        rect.left,
        (preTempYAxis - tempYAxis) / 2 + tempYAxis,
      );
      canvas.drawPath(_path, _linePaint..color = Colours.white);
      canvas.drawCircle(Offset(rect.center.dx, tempYAxis), 2.5.w,
          _circlePaint..color = Colours.white);
      _drawTemp(
        canvas,
        rect,
        (isHigh ? data.high : data.low).getTemp(),
        Colours.white,
        tempYAxis,
        isHigh: isHigh,
      );
    }
  }

  void _drawTemp(
      Canvas canvas, Rect rect, String text, Color textColor, double tempYAxis,
      {bool isHigh = true}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 13.sp,
          color: textColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2,
          isHigh ? tempYAxis - textPainter.height - 4.w : tempYAxis + 4.w),
    );
  }

  double _calTempYAxis(Rect rect, int temp) {
    final diff = _weatherDailyTempPanel.maxTemp - temp;
    final diffTemp =
        _weatherDailyTempPanel.maxTemp - _weatherDailyTempPanel.minTemp;
    final percent = diff / diffTemp;
    return rect.top +
        (rect.height - 2 * _topAndBottomGaps) * percent +
        _topAndBottomGaps;
  }
}
