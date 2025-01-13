import 'dart:math';

import 'package:animated_visibility/animated_visibility.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_yd_weather/model/weather_detail_data.dart';
import 'package:flutter_yd_weather/model/weather_item_data.dart';
import 'package:flutter_yd_weather/pages/provider/weather_provider.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/widget/opacity_layout.dart';
import 'package:flutter_yd_weather/widget/weather_daily_popup.dart';
import 'package:flutter_yd_weather/widget/weather_daily_temp_panel.dart';
import 'package:flutter_yd_weather/widget/weather_temp_line_bar.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../res/colours.dart';
import '../res/gaps.dart';
import '../utils/commons.dart';
import '../utils/weather_icon_utils.dart';
import 'blurry_container.dart';
import 'load_asset_image.dart';

class WeatherDailyStaticPanel extends StatelessWidget {
  const WeatherDailyStaticPanel({
    super.key,
    required this.weatherItemData,
    required this.shrinkOffset,
    required this.isDark,
    required this.panelOpacity,
    this.physics,
    this.currentDailyWeatherType,
    this.changeLineChartDailyWeather,
    this.changeListDailyWeather,
    this.lookMore,
    this.isExpand,
    this.showHideWeatherContent,
  });

  final WeatherItemData weatherItemData;
  final double shrinkOffset;
  final bool isDark;
  final double panelOpacity;
  final ScrollPhysics? physics;
  final String? currentDailyWeatherType;
  final VoidCallback? changeLineChartDailyWeather;
  final VoidCallback? changeListDailyWeather;
  final VoidCallback? lookMore;
  final bool? isExpand;
  final void Function(bool show)? showHideWeatherContent;

  @override
  Widget build(BuildContext context) {
    final maxHeight = weatherItemData.maxHeight;
    final animMaxHeight = weatherItemData.animMaxHeight ?? maxHeight;
    double height = maxHeight;
    if (maxHeight ==
        Constants.itemStickyHeight.w +
            Constants.dailyWeatherItemHeight.w *
                min(
                    Constants.dailyWeatherItemCount,
                    weatherItemData.weatherData?.forecast15?.length ??
                        Constants.dailyWeatherItemCount) +
            Constants.dailyWeatherBottomHeight.w) {
      if (currentDailyWeatherType == Constants.lineChartDailyWeather) {
        height = animMaxHeight;
      } else if (isExpand ?? false) {
        height = Constants.itemStickyHeight.w +
            Constants.dailyWeatherItemHeight.w *
                max(
                    Constants.dailyWeatherItemCount,
                    weatherItemData.weatherData?.forecast15?.length ??
                        Constants.dailyWeatherItemCount) +
            Constants.dailyWeatherBottomHeight.w;
      }
    } else {
      if (currentDailyWeatherType == Constants.listDailyWeather) {
        height = animMaxHeight;
      }
    }
    final percent =
        ((height - 12.w - shrinkOffset) / Constants.itemStickyHeight.w)
            .fixPercent();
    final maxTempData = weatherItemData.weatherData?.forecast15
        ?.reduce((e1, e2) => (e1.high ?? 0) > (e2.high ?? 0) ? e1 : e2);
    final minTempData = weatherItemData.weatherData?.forecast15
        ?.reduce((e1, e2) => (e1.low ?? 0) < (e2.low ?? 0) ? e1 : e2);
    final itemWidth = 68.5.w;
    final length = weatherItemData.weatherData?.forecast15?.length ?? 0;
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
                        child: Stack(
                          children: [
                            AnimatedVisibility(
                              visible: currentDailyWeatherType ==
                                  Constants.lineChartDailyWeather,
                              enter: fadeIn(),
                              exit: fadeOut(),
                              enterDuration: const Duration(milliseconds: 300),
                              exitDuration: const Duration(milliseconds: 300),
                              child: ListView.builder(
                                physics: physics,
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    physics is NeverScrollableScrollPhysics
                                        ? min(5, length)
                                        : length,
                                itemExtent: itemWidth,
                                itemBuilder: (_, index) {
                                  return showHideWeatherContent != null
                                      ? OpacityLayout(
                                          onPressed: () {
                                            _showWeatherDailyPopup(
                                              context,
                                              index,
                                            );
                                          },
                                          child:
                                              _buildLineChartDailyWeatherItem(
                                            index,
                                            itemWidth,
                                            maxTempData,
                                            minTempData,
                                          ),
                                        )
                                      : _buildLineChartDailyWeatherItem(
                                          index,
                                          itemWidth,
                                          maxTempData,
                                          minTempData,
                                        );
                                },
                              ),
                            ),
                            AnimatedVisibility(
                              visible: currentDailyWeatherType ==
                                  Constants.listDailyWeather,
                              enter: fadeIn(),
                              exit: fadeOut(),
                              enterDuration: const Duration(milliseconds: 300),
                              exitDuration: const Duration(milliseconds: 300),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      removeBottom: true,
                                      child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        itemCount: length,
                                        itemExtent:
                                            Constants.dailyWeatherItemHeight.w,
                                        itemBuilder: (_, index) {
                                          return showHideWeatherContent != null
                                              ? OpacityLayout(
                                                  onPressed: () {
                                                    _showWeatherDailyPopup(
                                                      context,
                                                      index,
                                                    );
                                                  },
                                                  child:
                                                      _buildListDailyWeatherItem(
                                                    index,
                                                    maxTempData,
                                                    minTempData,
                                                  ),
                                                )
                                              : _buildListDailyWeatherItem(
                                                  index,
                                                  maxTempData,
                                                  minTempData,
                                                );
                                        },
                                      ),
                                    ),
                                  ),
                                  OpacityLayout(
                                    onPressed: lookMore,
                                    child: Container(
                                      width: 88.w,
                                      height:
                                          Constants.dailyWeatherBottomHeight.w -
                                              0.5.w,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            (isExpand ?? false) ? "收起" : "展开",
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colours.white
                                                  .withValues(alpha: 0.6),
                                              height: 1,
                                            ),
                                          ),
                                          Gaps.generateGap(width: 8.w),
                                          AnimatedRotation(
                                            turns:
                                                (isExpand ?? false) ? -0.5 : 0,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            child: LoadAssetImage(
                                              "ic_expand_icon",
                                              width: 10.w,
                                              height: 10.w,
                                              color: Colours.white
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "15日天气预报",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colours.white.withValues(alpha: 0.6),
                  ),
                ),
                Visibility(
                  visible: currentDailyWeatherType.isNotNullOrEmpty(),
                  child: Row(
                    children: [
                      OpacityLayout(
                        onPressed: changeLineChartDailyWeather,
                        child: Container(
                          height: Constants.itemStickyHeight.w,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          alignment: Alignment.center,
                          child: Text(
                            "曲线",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colours.white.withValues(alpha: 
                                  currentDailyWeatherType ==
                                          Constants.lineChartDailyWeather
                                      ? 1
                                      : 0.6),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1.w,
                        height: 12.w,
                        color: Colours.white.withValues(alpha: 0.6),
                      ),
                      OpacityLayout(
                        onPressed: changeListDailyWeather,
                        child: Container(
                          height: Constants.itemStickyHeight.w,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          margin: EdgeInsets.only(right: 4.w),
                          alignment: Alignment.center,
                          child: Text(
                            "列表",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colours.white.withValues(alpha: 
                                  currentDailyWeatherType ==
                                          Constants.listDailyWeather
                                      ? 1
                                      : 0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWeatherDailyPopup(BuildContext context, int index) {
    showHideWeatherContent?.call(false);
    final weatherProvider = context.read<WeatherProvider>();
    final weatherDailyPopupKey = GlobalKey<WeatherDailyPopupState>();
    SmartDialog.show(
      maskColor: Colours.transparent,
      animationTime: const Duration(milliseconds: 400),
      clickMaskDismiss: true,
      onDismiss: () {
        weatherDailyPopupKey.currentState?.exit();
        Commons.postDelayed(delayMilliseconds: 400, () {
          showHideWeatherContent?.call(true);
        });
      },
      animationBuilder: (
        controller,
        child,
        animationParam,
      ) {
        return child;
      },
      builder: (_) {
        return WeatherDailyPopup(
          key: weatherDailyPopupKey,
          initialIndex: index,
          forecast15: weatherItemData.weatherData?.forecast15,
          weatherBg: weatherProvider.weatherBg,
          isDark: weatherProvider.isDark,
          panelOpacity: weatherProvider.panelOpacity,
        );
      },
    );
  }

  Widget _buildListDailyWeatherItem(
    int index,
    WeatherDetailData? maxTempData,
    WeatherDetailData? minTempData,
  ) {
    final item = weatherItemData.weatherData?.forecast15.getOrNull(index);
    final date = item?.date ?? "";
    final weatherDateTime = date.getWeatherDateTime();
    final isToday = date.isToday();
    final isBefore = date.isBefore();
    return AnimatedOpacity(
      opacity: isBefore ? 0.5 : 1,
      duration: Duration.zero,
      child: Container(
        width: double.infinity,
        height: Constants.dailyWeatherItemHeight.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weatherDateTime,
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: Colours.white,
                          height: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gaps.generateGap(height: 4.w),
                      Text(
                        DateUtil.formatDateStr(date, format: Constants.mmdd),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colours.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  Gaps.generateGap(width: 38.w),
                  LoadAssetImage(
                    WeatherIconUtils.getWeatherIconByType(
                      item?.day?.type ?? -1,
                      item?.day?.weatherType ?? "",
                      false,
                    ),
                    width: 24.w,
                    height: 24.w,
                  ),
                  Gaps.generateGap(width: 38.w),
                  Container(
                    width: 42.w,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (item?.low ?? 0).getTemp(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colours.white.withValues(alpha: isBefore ? 1 : 0.5),
                        height: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: WeatherTempLineBar(
                      width: double.infinity,
                      height: 4.w,
                      temp: isToday
                          ? weatherItemData.weatherData?.observe?.temp
                          : null,
                      high: item?.high ?? 0,
                      low: item?.low ?? 0,
                      maxTemp: maxTempData?.high ?? 0,
                      minTemp: minTempData?.low ?? 0,
                    ),
                  ),
                  Gaps.generateGap(width: 16.w),
                  Text(
                    (item?.high ?? 0).getTemp(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colours.white,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 0.5.w,
              color: Colours.white.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartDailyWeatherItem(
    int index,
    double itemWidth,
    WeatherDetailData? maxTempData,
    WeatherDetailData? minTempData,
  ) {
    final preItem =
        weatherItemData.weatherData?.forecast15.getOrNull(index - 1);
    final item = weatherItemData.weatherData?.forecast15.getOrNull(index);
    final nextItem =
        weatherItemData.weatherData?.forecast15.getOrNull(index + 1);
    final date = item?.date ?? "";
    final weatherDateTime = date.getWeatherDateTime();
    final isBefore = date.isBefore();
    return SizedBox(
      width: itemWidth,
      child: Column(
        children: [
          Gaps.generateGap(height: 12.w),
          Text(
            weatherDateTime,
            style: TextStyle(
              fontSize: 14.sp,
              color: isBefore ? Colours.white.withValues(alpha: 0.5) : Colours.white,
              height: 1,
            ),
          ),
          Gaps.generateGap(height: 12.w),
          Text(
            DateUtil.formatDateStr(date, format: Constants.mmdd),
            style: TextStyle(
              fontSize: 12.sp,
              color: isBefore ? Colours.white.withValues(alpha: 0.5) : Colours.white,
              height: 1,
            ),
          ),
          Gaps.generateGap(height: 12.w),
          Text(
            item?.day?.wthr ?? "",
            style: TextStyle(
              fontSize: 14.sp,
              color: isBefore ? Colours.white.withValues(alpha: 0.5) : Colours.white,
              height: 1,
            ),
          ),
          Gaps.generateGap(height: 12.w),
          AnimatedOpacity(
            opacity: isBefore ? 0.5 : 1,
            duration: Duration.zero,
            child: LoadAssetImage(
              WeatherIconUtils.getWeatherIconByType(
                item?.day?.type ?? -1,
                item?.day?.weatherType ?? "",
                false,
              ),
              width: 24.w,
              height: 24.w,
            ),
          ),
          WeatherDailyTempPanel(
            width: itemWidth,
            height: 128.w,
            preData: preItem,
            data: item,
            nextData: nextItem,
            maxTemp: maxTempData?.high ?? 0,
            minTemp: minTempData?.low ?? 0,
          ),
          AnimatedOpacity(
            opacity: isBefore ? 0.5 : 1,
            duration: Duration.zero,
            child: LoadAssetImage(
              WeatherIconUtils.getWeatherIconByType(
                item?.night?.type ?? -1,
                item?.night?.weatherType ?? "",
                true,
              ),
              width: 24.w,
              height: 24.w,
            ),
          ),
          Gaps.generateGap(height: 12.w),
          Text(
            item?.night?.wthr ?? "",
            style: TextStyle(
              fontSize: 14.sp,
              color: isBefore ? Colours.white.withValues(alpha: 0.5) : Colours.white,
              height: 1,
            ),
          ),
          Gaps.generateGap(height: 12.w),
          Text(
            item?.wd ?? "",
            style: TextStyle(
              fontSize: 14.sp,
              color: isBefore ? Colours.white.withValues(alpha: 0.5) : Colours.white,
              height: 1,
            ),
          ),
          Gaps.generateGap(height: 12.w),
          Text(
            item?.wp ?? "",
            style: TextStyle(
              fontSize: 14.sp,
              color: isBefore ? Colours.white.withValues(alpha: 0.5) : Colours.white,
              height: 1,
            ),
          ),
          Visibility(
            visible: item?.aqiLevelName.isNotNullOrEmpty() ?? false,
            child: Gaps.generateGap(height: 8.w),
          ),
          Visibility(
            visible: item?.aqiLevelName.isNotNullOrEmpty() ?? false,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.w),
                color: item?.aqi.getAqiColor().withValues(alpha: 0.48),
              ),
              child: Text(
                item?.aqiLevelName ?? "",
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
