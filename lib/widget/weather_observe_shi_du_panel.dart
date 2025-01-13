import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/widget/weather_observe_shi_du_chart.dart';

import '../config/constants.dart';
import '../model/weather_item_data.dart';
import '../res/colours.dart';
import 'blurry_container.dart';

class WeatherObserveShiDuPanel extends StatelessWidget {
  const WeatherObserveShiDuPanel({
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            weatherItemData.weatherData?.observe?.shiDu ?? "",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colours.white,
                              height: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          WeatherObserveShiDuChart(
                            width: 72.w,
                            height: 72.w,
                            shiDu:
                                weatherItemData.weatherData?.observe?.shiDu ??
                                    "",
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
                "湿度",
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
