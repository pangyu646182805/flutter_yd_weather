import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/widget/load_asset_image.dart';

import '../res/colours.dart';

class WeatherObserveWdChart extends StatelessWidget {
  const WeatherObserveWdChart({
    super.key,
    this.width,
    this.height,
    required this.wd,
  });

  final double? width;
  final double? height;
  final String wd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: _WeatherObserveWdDecoration(
        weatherObserveWdChart: this,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.w),
                color: Colours.color0DA8FF,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: LoadAssetImage(
              "ic_wd_icon",
              width: 12.w,
              height: 12.w,
              color: Colours.white,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 10.w),
              child: Text(
                "北",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colours.white,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.w),
              child: Text(
                "南",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colours.white,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Text(
                "西",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colours.white,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Text(
                "东",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colours.white,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherObserveWdDecoration extends Decoration {
  final WeatherObserveWdChart weatherObserveWdChart;

  const _WeatherObserveWdDecoration({
    required this.weatherObserveWdChart,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _WeatherObserveWdPainter(weatherObserveWdChart, onChanged);
  }
}

class _WeatherObserveWdPainter extends BoxPainter {
  final WeatherObserveWdChart _weatherObserveWdChart;
  final _path = Path();
  final _paint = Paint()
    ..color = Colours.white
    ..isAntiAlias = true
    ..strokeWidth = 1.w
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.fill;

  _WeatherObserveWdPainter(
    this._weatherObserveWdChart,
    VoidCallback? onChanged,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    final length = 6.w;
    for (int i = 0; i < 72; i++) {
      canvas.drawLine(
          Offset(rect.width * 0.5 - length, 0),
          Offset(rect.width * 0.5, 0),
          _paint
            ..color = Colours.white.withValues(alpha: 
                (i == 0 || i == 18 || i == 36 || i == 54) ? 1 : 0.4));
      canvas.rotate(2 * pi / 72);
    }
    canvas.restore();
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    _path.reset();
    final wd = _weatherObserveWdChart.wd;
    if (wd == "南风") {
      canvas.rotate(pi * 0.5);
    } else if (wd == "西风") {
      canvas.rotate(pi);
    } else if (wd == "北风") {
      canvas.rotate(pi * 1.5);
    } else if (wd == "东南风") {
      canvas.rotate(pi * 0.25);
    } else if (wd == "西南风") {
      canvas.rotate(pi * 0.75);
    } else if (wd == "西北风") {
      canvas.rotate(pi * 1.25);
    } else if (wd == "东北风") {
      canvas.rotate(pi * 1.75);
    }
    _path.moveTo(rect.width * 0.5 - length, -0.8.w);
    _path.lineTo(-rect.width * 0.5 + length + 3.w, -0.8.w);
    _path.lineTo(-rect.width * 0.5 + length + 3.w + 3.w, -0.8.w - 3.w);
    _path.lineTo(-rect.width * 0.5, 0);
    _path.lineTo(-rect.width * 0.5 + length + 3.w + 3.w, 0.8.w + 3.w);
    _path.lineTo(-rect.width * 0.5 + length + 3.w, 0.8.w);
    _path.lineTo(rect.width * 0.5 - length, 0.8.w);
    _path.close();
    canvas.drawPath(_path, _paint..color = Colours.color0DA8FF);
    canvas.drawCircle(Offset(rect.width * 0.5 - length, 0), 4.w, _paint..color = Colours.color0DA8FF);
    canvas.drawCircle(Offset(rect.width * 0.5 - length, 0), 2.w, _paint..color = Colours.white);
    canvas.restore();
  }
}
