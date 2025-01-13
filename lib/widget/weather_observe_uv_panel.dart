import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/widget/weather_observe_uv_chart.dart';

import '../config/constants.dart';
import '../model/weather_item_data.dart';
import '../res/colours.dart';
import 'blurry_container.dart';

class WeatherObserveUvPanel extends StatelessWidget {
  const WeatherObserveUvPanel({
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
    int uvIndex = weatherItemData.weatherData?.observe?.uvIndex ?? 0;
    int uvIndexMax = weatherItemData.weatherData?.observe?.uvIndexMax ?? 0;
    String uvLevel = weatherItemData.weatherData?.observe?.uvLevel ?? "";
    if (uvIndex <= 0 || uvIndexMax <= 0 || uvLevel.isEmpty) {
      final currentWeatherDetailData =
          weatherItemData.weatherData?.forecast15?.singleOrNull(
        (element) =>
            element.date ==
            DateUtil.formatDate(DateTime.now(), format: Constants.yyyymmdd),
      );
      uvIndex = currentWeatherDetailData?.uvIndex ?? 0;
      uvIndexMax = currentWeatherDetailData?.uvIndexMax ?? 0;
      uvLevel = currentWeatherDetailData?.uvLevel ?? "0";
    }
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
                            uvLevel,
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colours.white,
                              height: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          WeatherObserveUvChart(
                            width: 72.w,
                            height: 72.w,
                            uvIndex: uvIndex,
                            uvIndexMax: uvIndexMax,
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
                "紫外线指数",
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
