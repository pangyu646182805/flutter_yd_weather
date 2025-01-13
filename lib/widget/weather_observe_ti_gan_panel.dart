import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/res/gaps.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';

import '../config/constants.dart';
import '../model/weather_item_data.dart';
import '../res/colours.dart';
import 'blurry_container.dart';

class WeatherObserveTiGanPanel extends StatelessWidget {
  const WeatherObserveTiGanPanel({
    super.key,
    required this.data,
    required this.shrinkOffset,
    required this.isDark,
    required this.panelOpacity,
  });

  final WeatherItemData data;
  final double shrinkOffset;
  final bool isDark;
  final double panelOpacity;

  @override
  Widget build(BuildContext context) {
    final weatherItemData = data;
    final percent =
        ((Constants.itemObservePanelHeight.w - 12.w - shrinkOffset) /
                Constants.itemStickyHeight.w)
            .fixPercent();
    final temp = weatherItemData.weatherData?.observe?.temp ?? 0;
    final tiGanTemp =
        double.tryParse(weatherItemData.weatherData?.observe?.tiGan ?? "")
                ?.round() ??
            0;
    final tiGanTempDesc = (tiGanTemp - temp).abs() < 2
        ? "与实际温度相似"
        : (tiGanTemp > temp
            ? "比实际温度高${(tiGanTemp - temp).getTemp()}"
            : "比实际温度低${(temp - tiGanTemp).getTemp()}");
    return AnimatedOpacity(
      opacity: percent,
      duration: Duration.zero,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: shrinkOffset,
            right: 0,
            bottom: 0,
            child: BlurryContainer(
              width: double.infinity,
              height: double.infinity,
              blur: 5,
              color: (isDark ? Colours.white : Colours.black).withValues(alpha: panelOpacity),
              borderRadius: BorderRadius.circular(12.w),
              padding: EdgeInsets.only(
                top: Constants.itemStickyHeight.w,
              ),
              useBlurry: false,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: -shrinkOffset,
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tiGanTemp.getTemp(),
                            style: TextStyle(
                              fontSize: 32.sp,
                              color: Colours.white,
                              height: 1,
                            ),
                          ),
                          Gaps.generateGap(height: 33.w),
                          Text(
                            tiGanTempDesc,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colours.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: shrinkOffset,
            child: Container(
              height: min(Constants.itemStickyHeight.w,
                      Constants.itemObservePanelHeight.w - shrinkOffset)
                  .positiveNumber(),
              padding: EdgeInsets.only(left: 16.w),
              alignment: Alignment.centerLeft,
              child: Text(
                "体感温度",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colours.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
