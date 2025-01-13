import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/res/colours.dart';
import 'package:flutter_yd_weather/utils/weather_temp_line_bar_clipper.dart';

class WeatherTempLineBar extends StatelessWidget {
  const WeatherTempLineBar({
    super.key,
    this.temp,
    required this.width,
    required this.height,
    required this.high,
    required this.low,
    required this.maxTemp,
    required this.minTemp,
  });

  final double width;
  final double height;
  final int? temp;
  final int high;
  final int low;
  final int maxTemp;
  final int minTemp;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final tempBarWidth =
            ((high - low) / (maxTemp - minTemp)) * constraints.maxWidth;
        final marginLeft =
            ((low - minTemp) / (maxTemp - minTemp)) * constraints.maxWidth;
        double todayTempMarginLeft = 0;
        if (temp != null) {
          todayTempMarginLeft =
              ((temp! - minTemp) / (maxTemp - minTemp)) * constraints.maxWidth;
          if (todayTempMarginLeft < 0) {
            todayTempMarginLeft = 0;
          }
          if (todayTempMarginLeft > constraints.maxWidth - height) {
            todayTempMarginLeft = constraints.maxWidth - height;
          }
          if (todayTempMarginLeft < marginLeft) {
            todayTempMarginLeft = marginLeft;
          }
          if (todayTempMarginLeft > marginLeft + tempBarWidth - height) {
            todayTempMarginLeft = marginLeft + tempBarWidth - height;
          }
        }
        final colors = <Color>[];
        final stops = <double>[];
        double startStop = 0;
        if (minTemp <= 0) {
          colors.add(Colours.color55DFFC);
          startStop += (0 - minTemp) / (maxTemp - minTemp);
          stops.add(startStop);
        }
        if (maxTemp > 0 && minTemp <= 15) {
          colors.add(Colours.colorEADE6F);
          startStop +=
              (min(maxTemp, 15) - max(minTemp, 0)) / (maxTemp - minTemp);
          stops.add(startStop);
        }
        if (maxTemp > 15 && minTemp <= 30) {
          colors.add(Colours.colorFEBA4F);
          startStop +=
              (min(maxTemp, 30) - max(minTemp, 15)) / (maxTemp - minTemp);
          stops.add(startStop);
        }
        if (maxTemp > 30) {
          colors.add(Colours.colorFF6F55);
          stops.add(1);
        }
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.w),
            color: Colours.black.withValues(alpha: 0.05),
          ),
          child: ClipPath(
            clipper: WeatherTempLineBarClipper(
              rect: Rect.fromLTWH(
                marginLeft,
                0,
                tempBarWidth,
                height,
              ),
            ),
            child: Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.w),
                gradient: LinearGradient(
                  colors: colors,
                  stops: stops,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Visibility(
                visible: temp != null,
                child: Stack(
                  children: [
                    Container(
                      width: height,
                      height: height,
                      margin: EdgeInsets.only(left: todayTempMarginLeft),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.w),
                        color: Colours.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
