import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/config/constants.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';

import '../model/weather_detail_data.dart';
import '../res/colours.dart';

class WeatherForecase40Chart extends StatefulWidget {
  const WeatherForecase40Chart({
    super.key,
    this.width,
    this.height,
    this.initSelectedItem,
    required this.forecast40,
    required this.maxTempData,
    required this.minTempData,
    this.callback,
  });

  final double? width;
  final double? height;
  final WeatherDetailData? initSelectedItem;
  final List<WeatherDetailData>? forecast40;
  final WeatherDetailData? maxTempData;
  final WeatherDetailData? minTempData;
  final void Function(WeatherDetailData? currentSelectedItem)? callback;

  @override
  State<StatefulWidget> createState() => WeatherForecase40ChartState();
}

class WeatherForecase40ChartState extends State<WeatherForecase40Chart> {
  WeatherDetailData? _currentSelectedItem;
  final _rect =
      Rect.fromLTRB(16.w + 32.w, 0, ScreenUtil().screenWidth - 16.w - 32.w, 0);
  double _currentAxisX = 0;

  @override
  void initState() {
    super.initState();
    _currentSelectedItem =
        widget.initSelectedItem ?? widget.forecast40?.firstOrNull();
  }

  set currentSelectedItem(WeatherDetailData? currentSelectedItem) {
    final forecast40 = widget.forecast40;
    if (forecast40.isNullOrEmpty()) return;
    final length = forecast40!.length;
    final gaps = 2.5.w;
    final radius = (_rect.width - (length - 1) * gaps) / length / 2;
    final index =
        forecast40.indexWhere((e) => e.date == currentSelectedItem?.date);
    setState(() {
      _currentAxisX = 32.w + (2 * radius + gaps) * index + radius;
      _currentSelectedItem = currentSelectedItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateTime =
        DateTime.tryParse(_currentSelectedItem?.date ?? "") ?? DateTime.now();
    final desc =
        "${DateUtil.formatDate(dateTime, format: Constants.mm_dd)} ${_currentSelectedItem?.day?.wthr} ${_currentSelectedItem?.low.getTemp()}~${_currentSelectedItem?.high.getTemp()}";
    final textStyle = TextStyle(
      fontSize: 12.sp,
      color: Colours.black,
      height: 1,
    );
    final descWidth = desc.getTextContextSizeWidth(textStyle) + 2 * 8.w;
    final remainWidth = _rect.width - descWidth;
    double marginLeft = 0;
    final fixedAxisX = _currentAxisX - 32.w;
    if (fixedAxisX > descWidth * 0.5) {
      marginLeft = fixedAxisX - descWidth * 0.5;
      marginLeft = min(marginLeft, remainWidth);
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 38.w,
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: descWidth,
                  height: 24.w,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: marginLeft),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.w),
                    color: Colours.white,
                  ),
                  child: Text(
                    desc,
                    style: textStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onHorizontalDragDown: (details) {
              _touch(details.localPosition);
            },
            onHorizontalDragUpdate: (details) {
              _touch(details.localPosition);
            },
            onHorizontalDragEnd: (details) {
              _touch(details.localPosition);
            },
            onHorizontalDragStart: (details) {
              _touch(details.localPosition);
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: _WeatherForecase40Decoration(
                weatherForecase40Chart: widget,
                currentSelectedItem: _currentSelectedItem,
              ),
              child: Stack(
                children: [
                  SizedBox(
                    width: 32.w,
                    height: double.infinity,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 18.w),
                            child: Text(
                              widget.maxTempData?.high.getTemp() ?? "",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colours.white,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 24.w + 44.w),
                            child: Text(
                              widget.minTempData?.high.getTemp() ?? "",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colours.white,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 24.w),
                            child: Text(
                              "水",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colours.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: 28.w,
                      child: Row(
                        children: [
                          _buildDateItem(
                              widget.forecast40.getOrNull(0)?.date ?? ""),
                          _buildDateItem(
                              widget.forecast40.getOrNull(9)?.date ?? ""),
                          _buildDateItem(
                              widget.forecast40.getOrNull(19)?.date ?? ""),
                          _buildDateItem(
                              widget.forecast40.getOrNull(29)?.date ?? ""),
                          _buildDateItem(
                              widget.forecast40.getOrNull(39)?.date ?? ""),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(String date) {
    final dateTime = DateTime.tryParse(date) ?? DateTime.now();
    date = DateUtil.formatDate(dateTime, format: "MM/dd");
    return Expanded(
      child: Center(
        child: Text(
          date,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colours.white,
          ),
        ),
      ),
    );
  }

  void _touch(Offset position) {
    final forecast40 = widget.forecast40;
    if (forecast40.isNullOrEmpty()) return;
    final length = forecast40!.length;
    int index = ((position.dx - _rect.left) / (_rect.width / length)).round();
    if (index < 0) index = 0;
    if (index > length - 1) index = length - 1;
    final gaps = 2.5.w;
    final radius = (_rect.width - (length - 1) * gaps) / length / 2;
    setState(() {
      _currentAxisX = 32.w + (2 * radius + gaps) * index + radius;
      _currentSelectedItem = widget.forecast40.getOrNull(index);
      widget.callback?.call(_currentSelectedItem);
    });
  }
}

class _WeatherForecase40Decoration extends Decoration {
  final WeatherForecase40Chart weatherForecase40Chart;
  final WeatherDetailData? currentSelectedItem;

  const _WeatherForecase40Decoration({
    required this.weatherForecase40Chart,
    required this.currentSelectedItem,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _WeatherForecase40Painter(
      weatherForecase40Chart,
      currentSelectedItem,
      onChanged,
    );
  }
}

class _WeatherForecase40Painter extends BoxPainter {
  final WeatherForecase40Chart _weatherForecase40Chart;
  final WeatherDetailData? _currentSelectedItem;
  final _hGap = 32.w;
  final _bGap = 28.w;
  final _path = Path();
  final _linePath = Path();
  final _paint = Paint()
    ..color = Colours.white
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.fill;
  final _linePaint = Paint()
    ..color = Colours.white
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  _WeatherForecase40Painter(
    this._weatherForecase40Chart,
    this._currentSelectedItem,
    VoidCallback? onChanged,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final forecast40 = _weatherForecase40Chart.forecast40;
    if (forecast40.isNullOrEmpty()) return;
    final length = forecast40!.length;
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    final newRect = Rect.fromLTRB(
        rect.left + _hGap, rect.top, rect.right - _hGap, rect.bottom - _bGap);
    final gaps = 2.5.w;
    final radius = (newRect.width - (length - 1) * gaps) / length / 2;
    final lineRect = Rect.fromLTRB(
        newRect.left, newRect.top + 24.w, newRect.right, newRect.bottom - 48.w);
    _drawDashLine(canvas, lineRect, lineRect.top, radius);
    _drawDashLine(canvas, lineRect, lineRect.center.dy, radius);
    _drawDashLine(canvas, lineRect, lineRect.bottom, radius);
    final high = _weatherForecase40Chart.maxTempData?.high ?? 0;
    final low = _weatherForecase40Chart.minTempData?.high ?? 0;
    _linePath.reset();
    Offset currentPoint = Offset.zero;
    forecast40.forEachIndexed((e, index) {
      final isSelected = _currentSelectedItem?.date == e.date;
      _path.reset();
      final isRain = e.day?.weatherType?.isRain() ?? false;
      final circleRect = Rect.fromLTRB(
        newRect.left + (2 * radius + gaps) * index,
        newRect.bottom - 2 * radius,
        newRect.left + (2 * radius + gaps) * index + 2 * radius,
        newRect.bottom,
      );
      if (isRain) {
        _path.arcTo(circleRect, 0, pi, false);
        _path.moveTo(circleRect.left, circleRect.center.dy);
        _path.quadraticBezierTo(
          circleRect.left + radius / 2,
          circleRect.top - radius / 2,
          circleRect.center.dx,
          circleRect.top - 1.5.w,
        );
        _path.quadraticBezierTo(
          circleRect.right - radius / 2,
          circleRect.top - radius / 2,
          circleRect.right,
          circleRect.center.dy,
        );
        _path.close();
      } else {
        _path.addRRect(
            RRect.fromRectAndRadius(circleRect, Radius.circular(100.w)));
      }
      canvas.drawLine(
        Offset(circleRect.center.dx, circleRect.bottom - radius),
        Offset(circleRect.center.dx, newRect.top),
        _linePaint
          ..color =
              isSelected ? Colours.color0DA8FF : Colours.white.withValues(alpha: 0.4)
          ..strokeWidth = isSelected ? 2.w : 0.5.w,
      );
      canvas.drawPath(
          _path, _paint..color = isRain ? Colours.color0DA8FF : Colours.white);

      final currentTemp = e.high ?? 0;
      final percent = (currentTemp - low) / (high - low);
      final point = Offset(
          circleRect.center.dx, lineRect.bottom - lineRect.height * percent);
      if (isSelected) {
        currentPoint = point;
      }
      if (index == 0) {
        _linePath.moveTo(point.dx, point.dy);
      } else {
        _linePath.lineTo(point.dx, point.dy);
      }
    });
    canvas.drawPath(
        _linePath,
        _linePaint
          ..color = Colours.color0DA8FF
          ..strokeWidth = 2.w);
    _path.reset();
    _path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTRB(currentPoint.dx - 6.w, currentPoint.dy - 6.w,
          currentPoint.dx + 6.w, currentPoint.dy + 6.w),
      Radius.circular(100.w),
    ));
    _drawShadows(
      canvas,
      _path,
      [
        BoxShadow(
          color: Colours.color0DA8FF.withValues(alpha: 0.4),
          blurRadius: 4.w,
        ),
      ],
    );
    canvas.drawCircle(currentPoint, 4.w, _paint..color = Colours.color0DA8FF);
  }

  void _drawDashLine(Canvas canvas, Rect rect, double lineY, double radius) {
    final dashWidth = 2.w;
    final spaceWidth = 8.w;
    double startX = rect.left + radius;
    while (startX < rect.right) {
      double endX = startX + dashWidth;
      if (endX > rect.right - radius) {
        endX = rect.right - radius;
      }
      canvas.drawLine(
          Offset(startX, lineY),
          Offset(endX, lineY),
          _linePaint
            ..color = Colours.white.withValues(alpha: 0.8)
            ..strokeWidth = 0.8.w);
      startX += dashWidth + spaceWidth;
    }
  }

  void _drawShadows(Canvas canvas, Path path, List<BoxShadow> shadows) {
    for (final BoxShadow shadow in shadows) {
      final Paint shadowPainter = shadow.toPaint();
      if (shadow.spreadRadius == 0) {
        canvas.drawPath(path.shift(shadow.offset), shadowPainter);
      } else {
        Rect zone = path.getBounds();
        double xScale = (zone.width + shadow.spreadRadius) / zone.width;
        double yScale = (zone.height + shadow.spreadRadius) / zone.height;
        Matrix4 m4 = Matrix4.identity();
        m4.translate(zone.width / 2, zone.height / 2);
        m4.scale(xScale, yScale);
        m4.translate(-zone.width / 2, -zone.height / 2);
        canvas.drawPath(
            path.shift(shadow.offset).transform(m4.storage), shadowPainter);
      }
    }
    canvas.drawPath(path, Paint()..color = Colours.white);
  }
}
