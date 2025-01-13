import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../config/constants.dart';
import '../model/weather_item_data.dart';
import '../res/colours.dart';
import '../res/gaps.dart';
import 'blurry_container.dart';

class WeatherAlarmsStaticPanel extends StatelessWidget {
  const WeatherAlarmsStaticPanel({
    super.key,
    required this.weatherItemData,
    required this.shrinkOffset,
    required this.isDark,
    required this.panelOpacity,
    this.onTap,
    this.stackKey,
    this.swiperController,
    this.index = 0,
    this.physics,
    this.onIndexChanged,
  });

  final WeatherItemData weatherItemData;
  final double shrinkOffset;
  final bool isDark;
  final double panelOpacity;
  final VoidCallback? onTap;
  final GlobalKey? stackKey;
  final SwiperController? swiperController;
  final int index;
  final ScrollPhysics? physics;
  final ValueChanged<int>? onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final titlePercent = (1 - shrinkOffset / 12.w).fixPercent();
    final timePercent = (1 - shrinkOffset / 28.w).fixPercent();
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
                    child: Visibility(
                      visible: weatherItemData.weatherData?.alarms
                              .isNotNullOrEmpty() ??
                          false,
                      child: Swiper(
                        key: const Key('alarms_swiper'),
                        controller: swiperController,
                        loop: false,
                        transformer: ScaleAndFadeTransformer(),
                        physics: physics,
                        itemCount:
                            weatherItemData.weatherData?.alarms?.length ?? 0,
                        onIndexChanged: onIndexChanged,
                        itemBuilder: (_, index) {
                          final item = weatherItemData.weatherData?.alarms
                              ?.getOrNull(index);
                          final dateTime =
                              DateTime.tryParse(item?.pubTime ?? "");
                          String pubTimeDesc = "";
                          if (dateTime != null) {
                            final diff = DateTime.now().millisecondsSinceEpoch -
                                dateTime.millisecondsSinceEpoch;
                            final fewHours = (diff / 1000 / 60 / 60).floor();
                            pubTimeDesc = "$fewHours小时前更新";
                            if (fewHours <= 0) {
                              final fewMinutes = (diff / 1000 / 60).floor();
                              pubTimeDesc = "$fewMinutes分钟前更新";
                              if (fewMinutes <= 0) {
                                final fewMills = (diff / 1000).floor();
                                pubTimeDesc = "$fewMills秒前更新";
                              }
                            }
                          }
                          return SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Gaps.generateGap(height: 12.w),
                                AnimatedOpacity(
                                  opacity: titlePercent,
                                  duration: Duration.zero,
                                  child: Text(
                                    item?.title ?? "",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colours.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Gaps.generateGap(height: 4.w),
                                AnimatedOpacity(
                                  opacity: timePercent,
                                  duration: Duration.zero,
                                  child: Text(
                                    pubTimeDesc,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colours.white,
                                    ),
                                  ),
                                ),
                                Gaps.generateGap(height: 8.w),
                                Text(
                                  item?.desc ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colours.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Visibility(
                      visible:
                          (weatherItemData.weatherData?.alarms?.length ?? 0) >
                              1,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.w),
                        alignment: Alignment.center,
                        child: AnimatedSmoothIndicator(
                          activeIndex: index,
                          count:
                              weatherItemData.weatherData?.alarms?.length ?? 0,
                          effect: ExpandingDotsEffect(
                            expansionFactor: 1.5,
                            spacing: 3.w,
                            dotWidth: 6.w,
                            dotHeight: 2.w,
                            activeDotColor: Colours.white,
                            dotColor: Colours.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: 1 - timePercent,
              duration: Duration.zero,
              child: Container(
                height: Constants.itemStickyHeight.w,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.only(left: 16.w),
                alignment: Alignment.centerLeft,
                child: Text(
                  "极端天气",
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
