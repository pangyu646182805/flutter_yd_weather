import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/model/city_data.dart';
import 'package:flutter_yd_weather/model/weather_data.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';

import '../config/constants.dart';
import '../res/colours.dart';
import '../res/gaps.dart';
import 'auto_size_text.dart';
import 'load_asset_image.dart';

class WeatherHeaderStaticPanel extends StatelessWidget {
  const WeatherHeaderStaticPanel({
    super.key,
    required this.isDark,
    required this.weatherData,
    required this.cityData,
    required this.height,
    this.marginTopContainerHeight,
    this.refreshOpacity = 0,
    this.refreshDuration = Duration.zero,
    this.refreshDesc = "",
    this.opacity1 = 1,
    this.opacity2 = 1,
    this.opacity3 = 1,
    this.opacity4 = 0,
  });

  final bool isDark;
  final WeatherData? weatherData;
  final CityData? cityData;
  final double? height;
  final double? marginTopContainerHeight;
  final double refreshOpacity;
  final Duration refreshDuration;
  final String refreshDesc;
  final double opacity1;
  final double opacity2;
  final double opacity3;
  final double opacity4;

  @override
  Widget build(BuildContext context) {
    final currentWeatherDetailData = weatherData?.forecast15?.singleOrNull(
      (element) =>
          element.date ==
          DateUtil.formatDate(DateTime.now(), format: Constants.yyyymmdd),
    );
    final isLocationCity = cityData?.isLocationCity ?? false;
    final street = cityData?.street ?? "";
    final city = weatherData?.meta?.city ?? "";
    final title = !isLocationCity || street.isNullOrEmpty() ? city : "$city $street";
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Gaps.generateGap(height: ScreenUtil().statusBarHeight),
        SizedBox(
          width: double.infinity,
          height: height,
          child: IgnorePointer(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: marginTopContainerHeight,
                    alignment: Alignment.center,
                    child: AnimatedOpacity(
                      opacity: refreshOpacity,
                      duration: refreshDuration,
                      child: AnimatedSlide(
                        offset: Offset(0, -0.2 * (1 - refreshOpacity)),
                        duration: refreshDuration,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LoadAssetImage(
                              "ic_refresh_icon",
                              width: 16.w,
                              height: 16.w,
                              color: (isDark ? Colours.white : Colours.black)
                                  .withValues(alpha: 0.6),
                            ),
                            Gaps.generateGap(width: 4.w),
                            Text(
                              refreshDesc,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: (isDark ? Colours.white : Colours.black)
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 60.w),
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      text: title,
                      textStyle: TextStyle(
                        fontSize: 28.sp,
                        color: (isDark ? Colours.white : Colours.black),
                        height: 1,
                        fontFamily: "RobotoThin",
                        shadows: const [
                          BoxShadow(
                            color: Colours.black_3,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxWidth: ScreenUtil().screenWidth - 2 * 60.w,
                    ),
                  ),
                  Gaps.generateGap(height: 5.w),
                  Stack(
                    children: [
                      Column(
                        children: [
                          AnimatedOpacity(
                            opacity: opacity3,
                            duration: Duration.zero,
                            child: Row(
                              children: [
                                Expanded(child: Gaps.generateGap()),
                                Text(
                                  weatherData?.observe?.temp?.toString() ?? "",
                                  style: TextStyle(
                                    fontSize: 92.sp,
                                    color: (isDark
                                        ? Colours.white
                                        : Colours.black),
                                    height: 1,
                                    fontFamily: "RobotoThin",
                                    shadows: const [
                                      BoxShadow(
                                        color: Colours.black_3,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "°",
                                    style: TextStyle(
                                      fontSize: 86.sp,
                                      color: (isDark
                                          ? Colours.white
                                          : Colours.black),
                                      height: 1,
                                      fontFamily: "RobotoThin",
                                      shadows: const [
                                        BoxShadow(
                                          color: Colours.black_3,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gaps.generateGap(height: 5.w),
                          AnimatedOpacity(
                            opacity: opacity2,
                            duration: Duration.zero,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "最\n高",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: (isDark
                                        ? Colours.white
                                        : Colours.black),
                                    height: 1,
                                    fontFamily: "RobotoLight",
                                    shadows: const [
                                      BoxShadow(
                                        color: Colours.black_3,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                Gaps.generateGap(width: 3.w),
                                Text(
                                  currentWeatherDetailData?.high.getTemp() ??
                                      "",
                                  style: TextStyle(
                                    fontSize: 34.sp,
                                    color: (isDark
                                        ? Colours.white
                                        : Colours.black),
                                    height: 1,
                                    fontFamily: "RobotoLight",
                                    shadows: const [
                                      BoxShadow(
                                        color: Colours.black_3,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                Gaps.generateGap(width: 12.w),
                                Text(
                                  "最\n低",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: (isDark
                                        ? Colours.white
                                        : Colours.black),
                                    height: 1,
                                    fontFamily: "RobotoLight",
                                    shadows: const [
                                      BoxShadow(
                                        color: Colours.black_3,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                Gaps.generateGap(width: 3.w),
                                Text(
                                  currentWeatherDetailData?.low.getTemp() ?? "",
                                  style: TextStyle(
                                    fontSize: 34.sp,
                                    color: (isDark
                                        ? Colours.white
                                        : Colours.black),
                                    height: 1,
                                    fontFamily: "RobotoLight",
                                    shadows: const [
                                      BoxShadow(
                                        color: Colours.black_3,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gaps.generateGap(height: 5.w),
                          AnimatedOpacity(
                            opacity: opacity1,
                            duration: Duration.zero,
                            child: Text(
                              weatherData?.observe?.wthr ??
                                  currentWeatherDetailData?.wthr ??
                                  "",
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: (isDark ? Colours.white : Colours.black),
                                height: 1,
                                fontFamily: "RobotoLight",
                                shadows: const [
                                  BoxShadow(
                                    color: Colours.black_3,
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      AnimatedOpacity(
                        opacity: opacity4,
                        duration: Duration.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${weatherData?.observe?.temp.getTemp()} | ${weatherData?.observe?.wthr ?? currentWeatherDetailData?.wthr}",
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: (isDark ? Colours.white : Colours.black),
                                height: 1,
                                fontFamily: "RobotoLight",
                                shadows: const [
                                  BoxShadow(
                                    color: Colours.black_3,
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
