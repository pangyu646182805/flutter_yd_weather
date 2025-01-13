import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/model/weather_item_data.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';

import '../config/constants.dart';
import '../res/colours.dart';
import '../res/gaps.dart';
import '../utils/weather_icon_utils.dart';
import 'blurry_container.dart';
import 'load_asset_image.dart';

class WeatherHourStaticPanel extends StatelessWidget {
  const WeatherHourStaticPanel({
    super.key,
    required this.weatherItemData,
    required this.shrinkOffset,
    required this.isDark,
    required this.panelOpacity,
    this.physics,
  });

  final WeatherItemData weatherItemData;
  final double shrinkOffset;
  final bool isDark;
  final double panelOpacity;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final percent = ((weatherItemData.maxHeight - 12.w - shrinkOffset) /
            Constants.itemStickyHeight.w)
        .fixPercent();
    final currentWeatherDetailData =
        weatherItemData.weatherData?.forecast15?.singleOrNull(
      (element) =>
          element.date ==
          DateUtil.formatDate(DateTime.now(), format: Constants.yyyymmdd),
    );
    final length = weatherItemData.weatherData?.hourFc?.length ?? 0;
    return AnimatedOpacity(
      opacity: percent,
      duration: Duration.zero,
      child: Stack(
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
              top: Constants.itemStickyHeight.w,
            ),
            color: (isDark ? Colours.white : Colours.black)
                .withValues(alpha: panelOpacity),
            borderRadius: BorderRadius.circular(12.w),
            useBlurry: false,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: -shrinkOffset,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 0.5.w,
                        color: Colours.white.withValues(alpha: 0.2),
                      ),
                      Expanded(
                        child: ListView.separated(
                          physics: physics,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 16.w,
                          ),
                          itemCount: physics is NeverScrollableScrollPhysics
                              ? min(6, length)
                              : length,
                          itemBuilder: (_, index) {
                            final item = weatherItemData.weatherData?.hourFc
                                .getOrNull(index);
                            final time = item?.time ?? "";
                            final isSunrise =
                                item?.sunrise.isNotNullOrEmpty() ?? false;
                            final isSunset =
                                item?.sunset.isNotNullOrEmpty() ?? false;
                            return Column(
                              children: [
                                Gaps.generateGap(height: 12.w),
                                Text(
                                  isSunrise
                                      ? (item?.sunrise ?? "")
                                      : isSunset
                                          ? (item?.sunset ?? "")
                                          : time.getWeatherHourTime(
                                              sunrise: currentWeatherDetailData
                                                  ?.sunrise,
                                              sunset: currentWeatherDetailData
                                                  ?.sunset,
                                            ),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colours.white,
                                    height: 1,
                                  ),
                                ),
                                Gaps.generateGap(height: 12.w),
                                LoadAssetImage(
                                  isSunrise
                                      ? "ic_sunrise_icon"
                                      : isSunset
                                          ? "ic_sunset_icon"
                                          : WeatherIconUtils
                                              .getWeatherIconByType(
                                              item?.type ?? -1,
                                              item?.weatherType ?? "",
                                              time.isNight(
                                                sunrise:
                                                    currentWeatherDetailData
                                                        ?.sunrise,
                                                sunset: currentWeatherDetailData
                                                    ?.sunset,
                                              ),
                                            ),
                                  width: 24.w,
                                  height: 24.w,
                                ),
                                Gaps.generateGap(height: 12.w),
                                Text(
                                  isSunrise
                                      ? "日出"
                                      : isSunset
                                          ? "日落"
                                          : item?.temp.getTemp() ?? "",
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    color: Colours.white,
                                    height: 1,
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (_, index) {
                            return Gaps.generateGap(width: 28.w);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: Constants.itemStickyHeight.w,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.only(left: 16.w),
            alignment: Alignment.centerLeft,
            child: Text(
              "每小时天气预报",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colours.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
