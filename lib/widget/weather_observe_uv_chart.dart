import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import '../res/colours.dart';

class WeatherObserveUvChart extends StatelessWidget {
  const WeatherObserveUvChart({
    super.key,
    this.width,
    this.height,
    required this.uvIndex,
    required this.uvIndexMax,
  });

  final double? width;
  final double? height;
  final int uvIndex;
  final int uvIndexMax;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: _WeatherObserveUvDecoration(
        weatherObserveUvChart: this,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              "$uvIndex",
              style: TextStyle(
                fontSize: 18.sp,
                color: Colours.white,
                height: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 5.w),
              child: Text(
                "uv",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colours.white,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherObserveUvDecoration extends Decoration {
  final WeatherObserveUvChart weatherObserveUvChart;

  const _WeatherObserveUvDecoration({
    required this.weatherObserveUvChart,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _WeatherObserveUvPainter(weatherObserveUvChart, onChanged);
  }
}

class _WeatherObserveUvPainter extends BoxPainter {
  final WeatherObserveUvChart _weatherObserveUvChart;
  final _path = Path();
  final _paint = Paint()
    ..color = Colours.white
    ..isAntiAlias = true
    ..strokeWidth = 4.w
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final _circlePaint = Paint();

  _WeatherObserveUvPainter(
    this._weatherObserveUvChart,
    VoidCallback? onChanged,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    canvas.saveLayer(rect, _circlePaint);
    _path.reset();
    final newRect = Rect.fromLTRB(
        rect.left + 4.w, rect.top + 4.w, rect.right - 4.w, rect.bottom - 4.w);
    _path.arcTo(
      newRect,
      -pi * 1.25,
      pi * 1.5,
      false,
    );
    canvas.drawPath(
      _path,
      _paint
        ..shader = ui.Gradient.sweep(
          newRect.center,
          [
            Colours.colorBB10DE,
            Colours.colorBB10DE,
            Colours.color37CA00,
            Colours.color37CA00,
            Colours.colorFFDE00,
            Colours.colorFE5B21,
            Colours.colorFC0B23,
            Colours.colorBB10DE,
          ],
          [
            0.125,
            0.25,
            0.375,
            0.45,
            0.625,
            0.75,
            0.925,
            1,
          ],
        ),
    );
    double percent =
        (_weatherObserveUvChart.uvIndex / _weatherObserveUvChart.uvIndexMax)
            .fixPercent();
    percent = 0.2;
    final pm = _path.computeMetrics().first;
    final position = pm.getTangentForOffset(pm.length * percent)?.position;
    if (position != null) {
      Color color = Colours.color37CA00;
      if (percent > 0.8) {
        color = Colours.colorBB10DE;
      } else if (percent > 0.6) {
        color = Colours.colorFC0B23;
      } else if (percent > 0.4) {
        color = Colours.colorFE5B21;
      } else if (percent > 0.2) {
        color = Colours.colorFFDE00;
      }
      canvas.drawCircle(
        position,
        7.w,
        _circlePaint
          ..color = color.withValues(alpha: 0)
          ..blendMode = BlendMode.clear,
      );
      canvas.drawCircle(
        position,
        4.w,
        _circlePaint
          ..color = color
          ..blendMode = BlendMode.srcOver,
      );
      canvas.restore();
    }
  }
}
