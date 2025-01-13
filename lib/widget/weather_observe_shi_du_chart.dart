import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/widget/load_asset_image.dart';

import '../res/colours.dart';

class WeatherObserveShiDuChart extends StatelessWidget {
  const WeatherObserveShiDuChart({
    super.key,
    this.width,
    this.height,
    required this.shiDu,
  });

  final double? width;
  final double? height;
  final String shiDu;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: _WeatherObserveShiDuDecoration(
        weatherObserveShiDuChart: this,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: LoadAssetImage(
              "ic_water_icon",
              width: 16.w,
              height: 16.w,
              color: Colours.white,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 5.w),
              child: Text(
                shiDu.getShiDuValue().getShiDuDesc(),
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

class _WeatherObserveShiDuDecoration extends Decoration {
  final WeatherObserveShiDuChart weatherObserveShiDuChart;

  const _WeatherObserveShiDuDecoration({
    required this.weatherObserveShiDuChart,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _WeatherObserveShiDuPainter(weatherObserveShiDuChart, onChanged);
  }
}

class _WeatherObserveShiDuPainter extends BoxPainter {
  final WeatherObserveShiDuChart _weatherObserveShiDuChart;
  final _path = Path();
  final _paint = Paint()
    ..color = Colours.white
    ..isAntiAlias = true
    ..strokeWidth = 4.w
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  _WeatherObserveShiDuPainter(
    this._weatherObserveShiDuChart,
    VoidCallback? onChanged,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    _path.reset();
    final newRect = Rect.fromLTRB(
        rect.left + 2.w, rect.top + 2.w, rect.right - 2.w, rect.bottom - 2.w);
    _path.arcTo(
      newRect,
      -pi * 1.25,
      pi * 1.5,
      false,
    );
    canvas.drawPath(_path, _paint..color = Colours.white.withValues(alpha: 0.4));
    _path.reset();
    final shiDuValue = _weatherObserveShiDuChart.shiDu.getShiDuValue();
    final shiDuPercent = (shiDuValue / 100).fixPercent();
    _path.arcTo(
      newRect,
      -pi * 1.25,
      pi * 1.5 * shiDuPercent,
      false,
    );
    canvas.drawPath(_path, _paint..color = Colours.white);
  }
}
