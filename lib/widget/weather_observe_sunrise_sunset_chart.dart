import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';

import '../res/colours.dart';

class WeatherObserveSunriseSunsetChart extends StatelessWidget {
  const WeatherObserveSunriseSunsetChart({
    super.key,
    this.width,
    this.height,
    required this.date,
    required this.sunrise,
    required this.sunset,
  });

  final double? width;
  final double? height;
  final String date;
  final String sunrise;
  final String sunset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: _WeatherObserveSunriseSunsetDecoration(
        weatherObserveSunriseSunsetChart: this,
      ),
    );
  }
}

class _WeatherObserveSunriseSunsetDecoration extends Decoration {
  final WeatherObserveSunriseSunsetChart weatherObserveSunriseSunsetChart;

  const _WeatherObserveSunriseSunsetDecoration({
    required this.weatherObserveSunriseSunsetChart,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _WeatherObserveSunriseSunsetPainter(
        weatherObserveSunriseSunsetChart, onChanged);
  }
}

class _WeatherObserveSunriseSunsetPainter extends BoxPainter {
  final WeatherObserveSunriseSunsetChart _weatherObserveSunriseSunsetChart;
  final _path = Path();
  final _paint = Paint()
    ..color = Colours.white
    ..isAntiAlias = true
    ..strokeWidth = 4.w
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final _linePaint = Paint()
    ..color = Colours.white.withValues(alpha: 0.4)
    ..isAntiAlias = true
    ..strokeWidth = 0.5.w
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final _circlePaint = Paint();

  _WeatherObserveSunriseSunsetPainter(
    this._weatherObserveSunriseSunsetChart,
    VoidCallback? onChanged,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    canvas.saveLayer(rect, _circlePaint);
    final newRect = Rect.fromLTRB(
        rect.left + 4.w, rect.top + 4.w, rect.right - 4.w, rect.bottom - 4.w);
    _path.reset();
    _path.moveTo(newRect.left, newRect.bottom);
    Point<double> p1 = Point(
        newRect.left + newRect.width / 4 + newRect.width / 4 / 2,
        newRect.bottom);
    Point<double> p2 = Point(
        newRect.left + newRect.width / 4 - newRect.width / 4 / 2, newRect.top);
    _path.cubicTo(p1.x, p1.y, p2.x, p2.y, newRect.center.dx, newRect.top);
    p1 = Point(
        newRect.right - newRect.width / 4 + newRect.width / 4 / 2, newRect.top);
    p2 = Point(newRect.right - newRect.width / 4 - newRect.width / 4 / 2,
        newRect.bottom);
    _path.cubicTo(p1.x, p1.y, p2.x, p2.y, newRect.right, newRect.bottom);
    final pm = _path.computeMetrics().first;
    final extractPath1 = pm.extractPath(0, pm.length * 0.2);
    final extractPath2 = pm.extractPath(pm.length * 0.2, pm.length * 0.5);
    final extractPath3 = pm.extractPath(pm.length * 0.5, pm.length * 0.8);
    final extractPath4 = pm.extractPath(pm.length * 0.8, pm.length);
    Offset? position = pm.getTangentForOffset(pm.length * 0.2)?.position;
    if (position != null) {
      canvas.drawLine(Offset(newRect.left, position.dy),
          Offset(newRect.right, position.dy), _linePaint);
    }
    canvas.drawPath(
        extractPath1, _paint..color = Colours.white.withValues(alpha: 0.4));
    canvas.drawPath(extractPath2, _paint..color = Colours.white);
    canvas.drawPath(extractPath3, _paint..color = Colours.white);
    canvas.drawPath(
        extractPath4, _paint..color = Colours.white.withValues(alpha: 0.4));
    final currentMill = DateTime.now().millisecondsSinceEpoch;
    final sunriseDateTime = "${_weatherObserveSunriseSunsetChart.date}${_weatherObserveSunriseSunsetChart.sunrise}".replaceAll(":", "").getDartDateTimeFormattedString();
    final sunsetDateTime = "${_weatherObserveSunriseSunsetChart.date}${_weatherObserveSunriseSunsetChart.sunset}".replaceAll(":", "").getDartDateTimeFormattedString();
    final sunriseMill = DateTime.tryParse(sunriseDateTime)?.millisecondsSinceEpoch ?? 0;
    final sunsetMill = DateTime.tryParse(sunsetDateTime)?.millisecondsSinceEpoch ?? 0;
    double percent;
    if (currentMill < sunriseMill) {
      final dateTime1 = "${_weatherObserveSunriseSunsetChart.date}0000".getDartDateTimeFormattedString();
      final mill1 = DateTime.tryParse(dateTime1)?.millisecondsSinceEpoch ?? 0;
      percent = (currentMill - mill1) / (sunriseMill - mill1) * 0.2;
    } else if (currentMill < sunsetMill) {
      percent = 0.2 + (currentMill - sunriseMill) / (sunsetMill - sunriseMill) * 0.6;
    } else {
      final dateTime2 = "${_weatherObserveSunriseSunsetChart.date}2400".getDartDateTimeFormattedString();
      final mill2 = DateTime.tryParse(dateTime2)?.millisecondsSinceEpoch ?? 0;
      percent = 0.2 + 0.6 + (currentMill - sunsetMill) / (mill2 - sunsetMill) * 0.2;
    }
    percent = percent.fixPercent();
    position = pm.getTangentForOffset(pm.length * percent)?.position;
    if (position != null) {
      canvas.drawCircle(
        position,
        7.w,
        _circlePaint
          ..color = Colours.white.withValues(alpha: 0)
          ..blendMode = BlendMode.clear,
      );
      canvas.drawCircle(
        position,
        4.w,
        _circlePaint
          ..color = Colours.white.withValues(alpha: percent < 0.2 || percent > 0.8 ? 0.4 : 1)
          ..blendMode = BlendMode.srcOver,
      );
    }
    canvas.restore();
  }
}
