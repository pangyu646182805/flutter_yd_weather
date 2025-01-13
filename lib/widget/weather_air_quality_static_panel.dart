import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_yd_weather/model/weather_item_data.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';

import '../config/constants.dart';
import '../res/colours.dart';
import '../res/gaps.dart';
import 'air_quality_bar.dart';
import 'air_quality_query_dialog.dart';
import 'blurry_container.dart';
import 'load_asset_image.dart';
import 'opacity_layout.dart';

class WeatherAirQualityStaticPanel extends StatelessWidget {
  const WeatherAirQualityStaticPanel({
    super.key,
    required this.weatherItemData,
    required this.shrinkOffset,
    required this.isDark,
    required this.panelOpacity,
    this.onTap,
    this.stackKey,
  });

  final WeatherItemData weatherItemData;
  final double shrinkOffset;
  final bool isDark;
  final double panelOpacity;
  final VoidCallback? onTap;
  final GlobalKey? stackKey;

  @override
  Widget build(BuildContext context) {
    final titlePercent = (1 - shrinkOffset / 12.w).fixPercent();
    final percent = ((weatherItemData.maxHeight - 12.w - shrinkOffset) /
            Constants.itemStickyHeight.w)
        .fixPercent();
    return AnimatedOpacity(
      opacity: percent,
      duration: Duration.zero,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          key: stackKey,
          children: [
            BlurryContainer(
              width: double.infinity,
              height: double.infinity,
              blur: 5,
              margin: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
              ),
              padding: EdgeInsets.only(
                top: min(shrinkOffset, Constants.itemStickyHeight.w),
              ),
              color: (isDark ? Colours.white : Colours.black).withValues(alpha: panelOpacity),
              borderRadius: BorderRadius.circular(12.w),
              useBlurry: false,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: -shrinkOffset -
                        min(shrinkOffset, Constants.itemStickyHeight.w),
                    right: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gaps.generateGap(height: 12.w),
                          AnimatedOpacity(
                            opacity: titlePercent,
                            duration: Duration.zero,
                            child: Row(
                              children: [
                                Text(
                                  "${weatherItemData.weatherData?.evn?.aqi} - ${weatherItemData.weatherData?.evn?.aqiLevelName}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colours.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                OpacityLayout(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 4.w,
                                    ),
                                    child: LoadAssetImage(
                                      "ic_query_icon",
                                      width: 14.w,
                                      height: 14.w,
                                      color: Colours.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    SmartDialog.show(
                                      tag: "AirQualityQueryDialog",
                                      alignment: Alignment.bottomCenter,
                                      builder: (_) {
                                        return const AirQualityQueryDialog();
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Gaps.generateGap(height: 10.w),
                          AirQualityBar(
                            width: double.infinity,
                            height: 4.w,
                            aqi: weatherItemData.weatherData?.evn?.aqi ?? 0,
                          ),
                          Gaps.generateGap(height: 8.w),
                          Text(
                            "当前AQI为${weatherItemData.weatherData?.evn?.aqi}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colours.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: 1 - titlePercent,
              duration: Duration.zero,
              child: Container(
                height: Constants.itemStickyHeight.w,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.only(left: 16.w),
                alignment: Alignment.centerLeft,
                child: Text(
                  "空气质量",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colours.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
