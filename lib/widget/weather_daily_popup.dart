import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/res/colours.dart';
import 'package:flutter_yd_weather/res/gaps.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/widget/load_asset_image.dart';

import '../config/constants.dart';
import '../model/weather_detail_data.dart';
import '../utils/weather_icon_utils.dart';
import 'infinite_card_stack_widget.dart';

class WeatherDailyPopup extends StatefulWidget {
  const WeatherDailyPopup({
    super.key,
    this.initialIndex = 0,
    required this.forecast15,
    required this.weatherBg,
    required this.isDark,
    required this.panelOpacity,
  });

  final int initialIndex;
  final List<WeatherDetailData>? forecast15;
  final LinearGradient? weatherBg;
  final bool isDark;
  final double panelOpacity;

  @override
  State<StatefulWidget> createState() => WeatherDailyPopupState();
}

class WeatherDailyPopupState extends State<WeatherDailyPopup> {
  final _infiniteCardStackKey = GlobalKey<InfiniteCardStackWidgetState>();

  void exit() {
    _infiniteCardStackKey.currentState?.exit();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: InfiniteCardStackWidget(
        key: _infiniteCardStackKey,
        initialIndex: widget.initialIndex,
        ratio: (ScreenUtil().screenWidth - 2 * 16.w - 24.w) / 208.w,
        scale: 0.95,
        showCount: 3,
        itemHeight: 208.w,
        itemBuilder: (_, index) {
          final item = widget.forecast15.getOrNull(index);
          final date = item?.date ?? "";
          return Stack(
            children: [
              OverflowBox(
                alignment: Alignment.center,
                maxWidth: ScreenUtil().screenWidth,
                maxHeight: ScreenUtil().screenHeight,
                child: Container(
                  width: ScreenUtil().screenWidth,
                  height: ScreenUtil().screenHeight,
                  decoration: BoxDecoration(
                    gradient: widget.weatherBg,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                color: (widget.isDark ? Colours.white : Colours.black)
                    .withValues(alpha: widget.panelOpacity),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Gaps.generateGap(height: 16.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateUtil.formatDateStr(date,
                                format: Constants.mm_dd),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colours.white,
                              height: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Visibility(
                            visible:
                                item?.aqiLevelName.isNotNullOrEmpty() ?? false,
                            child: Gaps.generateGap(width: 4.w),
                          ),
                          Visibility(
                            visible:
                                item?.aqiLevelName.isNotNullOrEmpty() ?? false,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                color:
                                    item?.aqi.getAqiColor().withValues(alpha: 0.48),
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
                      Gaps.generateGap(height: 16.w),
                      Row(
                        children: [
                          Expanded(
                            child: _buildItem(
                              item,
                              false,
                            ),
                          ),
                          Expanded(
                            child: _buildItem(
                              item,
                              true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        curve: Curves.easeOutBack,
        itemCount: widget.forecast15?.length ?? 0,
        paddingLeft: 16.w,
        paddingRight: 16.w,
        borderRadius: BorderRadius.circular(12.w),
        enterAnim: true,
        enterDuration: const Duration(milliseconds: 200),
        enterDelayDuration: const Duration(milliseconds: 50),
      ),
    );
  }

  Widget _buildItem(WeatherDetailData? item, bool isDark) {
    return Column(
      children: [
        LoadAssetImage(
          WeatherIconUtils.getWeatherIconByType(
            isDark ? item?.night?.type ?? -1 : item?.day?.type ?? -1,
            isDark
                ? item?.night?.weatherType ?? ""
                : item?.day?.weatherType ?? "",
            isDark,
          ),
          width: 32.w,
          height: 32.w,
        ),
        Gaps.generateGap(height: 16.w),
        Text(
          isDark ? "夜间" : "白天",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colours.white,
            height: 1,
          ),
        ),
        Gaps.generateGap(height: 8.w),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDark ? item?.night?.wthr ?? "" : item?.day?.wthr ?? "",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colours.white.withValues(alpha: 0.6),
                height: 1,
              ),
            ),
            Gaps.generateGap(width: 8.w),
            Text(
              isDark ? (item?.low ?? 0).getTemp() : (item?.high ?? 0).getTemp(),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colours.white.withValues(alpha: 0.6),
                height: 1,
              ),
            ),
          ],
        ),
        Gaps.generateGap(height: 8.w),
        Text(
          "${item?.wd ?? ""}${item?.wp ?? ""}",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colours.white.withValues(alpha: 0.6),
            height: 1,
          ),
        ),
        Gaps.generateGap(height: 12.w),
        Container(
          width: 24.w,
          height: 0.5.w,
          color: Colours.white.withValues(alpha: 0.6),
        ),
        Gaps.generateGap(height: 12.w),
        Text(
          isDark ? "日落 ${item?.sunset ?? ""}" : "日出 ${item?.sunrise ?? ""}",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colours.white,
            height: 1,
          ),
        ),
      ],
    );
  }
}
