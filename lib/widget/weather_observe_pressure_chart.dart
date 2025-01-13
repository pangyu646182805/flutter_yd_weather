import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/widget/load_asset_image.dart';

import '../res/colours.dart';

class WeatherObservePressureChart extends StatelessWidget {
  const WeatherObservePressureChart({
    super.key,
    this.width,
    this.height,
    required this.pressure,
  });

  final double? width;
  final double? height;
  final String pressure;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: _WeatherObservePressureDecoration(
        weatherObservePressureChart: this,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: LoadAssetImage(
              "ic_arrow_down",
              width: 20.w,
              height: 20.w,
              color: Colours.white,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 5.w),
              child: Text(
                "hPa",
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

class _WeatherObservePressureDecoration extends Decoration {
  final WeatherObservePressureChart weatherObservePressureChart;

  const _WeatherObservePressureDecoration({
    required this.weatherObservePressureChart,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _WeatherObservePressurePainter(
        weatherObservePressureChart, onChanged);
  }
}

class _WeatherObservePressurePainter extends BoxPainter {
  final WeatherObservePressureChart _weatherObservePressureChart;
  final _path = Path();
  final _paint = Paint()
    ..color = Colours.white
    ..isAntiAlias = true
    ..strokeWidth = 4.w
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final _pressurePaint = Paint();

  _WeatherObservePressurePainter(
    this._weatherObservePressureChart,
    VoidCallback? onChanged,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    canvas.saveLayer(rect, _pressurePaint);
    final newRect = Rect.fromLTRB(
        rect.left + 2.w, rect.top + 2.w, rect.right - 2.w, rect.bottom - 2.w);
    _path.reset();
    _path.arcTo(
      newRect,
      -pi * 1.25,
      pi * 1.5,
      false,
    );
    canvas.drawPath(_path, _paint..color = Colours.white);
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    final pressure = int.tryParse(
            _weatherObservePressureChart.pressure.replaceAll("hPa", "")) ??
        0;
    int max, min;
    if (pressure < 100) {
      min = 0;
      max = 200;
    } else if (pressure < 1000) {
      min = pressure - pressure % 100;
      max = min + 300;
    } else {
      min = pressure - pressure % 1000;
      max = min + 300;
    }
    final percent = (pressure - min) / (max - min);
    canvas.rotate(pi * 0.75 + pi * 1.5 * percent);
    canvas.drawLine(
      Offset(rect.width * 0.5 - 2.w, 0),
      Offset(rect.width * 0.5 - 2.w, 0),
      _pressurePaint
        ..color = Colours.white.withValues(alpha: 0)
        ..strokeWidth = 6.w
        ..strokeCap = StrokeCap.square
        ..blendMode = BlendMode.clear,
    );
    canvas.drawLine(
      Offset(rect.width * 0.5 - 2.w + 4.w, 0),
      Offset(rect.width * 0.5 - 2.w - 4.w, 0),
      _pressurePaint
        ..color = Colours.white
        ..strokeWidth = 2.5.w
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.srcOver,
    );
    canvas.restore();
    canvas.restore();
  }
}
