import 'package:animated_visibility/animated_visibility.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:common_utils/common_utils.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_yd_weather/config/constants.dart';
import 'package:flutter_yd_weather/res/colours.dart';
import 'package:flutter_yd_weather/res/gaps.dart';
import 'package:flutter_yd_weather/utils/commons.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/utils/weather_icon_utils.dart';
import 'package:flutter_yd_weather/widget/weather_forecase40_chart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../model/weather_detail_data.dart';
import '../model/weather_forecast40_data.dart';
import '../model/weather_meta_data.dart';
import 'load_asset_image.dart';
import 'opacity_layout.dart';

class WeatherForecase40DetailPage extends StatefulWidget {
  const WeatherForecase40DetailPage({
    super.key,
    required this.initPosition,
    required this.size,
    required this.isDark,
    required this.isWeatherHeaderDark,
    required this.panelOpacity,
    required this.forecast40,
    required this.forecast40Data,
    required this.meta,
  });

  final Offset initPosition;
  final Size size;
  final bool isDark;
  final bool isWeatherHeaderDark;
  final double panelOpacity;
  final List<WeatherDetailData>? forecast40;
  final WeatherForecast40Data? forecast40Data;
  final WeatherMetaData? meta;

  @override
  State<StatefulWidget> createState() => WeatherForecase40DetailPageState();
}

class WeatherForecase40DetailPageState
    extends State<WeatherForecase40DetailPage> {
  int _index = 0;
  double _opacity = 0;
  double _opacity1 = 1;
  double _opacity2 = 0;
  Size _size = Size.zero;
  double _marginTop = 0;
  final List<List<WeatherDetailData>> _pageData = [];
  WeatherDetailData? _currentSelectedItem;
  final _weatherForecase40ChartKey = GlobalKey<WeatherForecase40ChartState>();
  late SwiperController _swiperController;

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController();
    _opacity = 0;
    _opacity1 = 1;
    _opacity2 = 0;
    _size = widget.size;
    _marginTop =
        widget.initPosition.dy - 48.w - 12.w - ScreenUtil().statusBarHeight;
    final temp = [...?widget.forecast40];
    final firstDateTime =
        DateTime.tryParse(temp.firstOrNull()?.date ?? "") ?? DateTime.now();
    final lastDateTime =
        DateTime.tryParse(temp.lastOrNull?.date ?? "") ?? DateTime.now();
    final firstWeekday = firstDateTime.weekday;
    final fixedFirstWeekday = firstWeekday >= 7 ? 0 : firstWeekday;
    int index = 1;
    List<WeatherDetailData> list;
    _pageData.clear();
    for (int i = 0; i < 2; i++) {
      list = [];
      for (int j = 0; j < 28; j++) {
        if (i == 0) {
          if (j < fixedFirstWeekday) {
            list.add(
              WeatherDetailData.date(
                DateUtil.formatDate(
                    firstDateTime
                        .subtract(Duration(days: fixedFirstWeekday - j)),
                    format: Constants.yyyymmdd),
              ),
            );
          } else {
            final removeItem = temp.removeAt(0);
            if (_currentSelectedItem == null) {
              final dateTime =
                  DateTime.tryParse(removeItem.date ?? "") ?? DateTime.now();
              final isToday = DateUtil.isToday(dateTime.millisecondsSinceEpoch);
              if (isToday) {
                _currentSelectedItem = removeItem;
              }
            }
            list.add(removeItem);
          }
        } else {
          if (temp.isNotEmpty) {
            list.add(temp.removeAt(0));
          } else {
            list.add(
              WeatherDetailData.date(
                DateUtil.formatDate(lastDateTime.add(Duration(days: index)),
                    format: Constants.yyyymmdd),
              ),
            );
            index++;
          }
        }
      }
      _pageData.add(list);
    }
    Commons.post((_) {
      setState(() {
        _size = Size(ScreenUtil().screenWidth - 2 * 16.w, 488.w);
        _marginTop = 0;
        Commons.postDelayed(delayMilliseconds: 200, () {
          setState(() {
            _opacity = 1;
            _opacity2 = 1;
          });
        });
      });
    });
  }

  void exit() {
    setState(() {
      _opacity = 0;
      Commons.postDelayed(delayMilliseconds: 200, () {
        setState(() {
          _size = widget.size;
          _marginTop = widget.initPosition.dy -
              48.w -
              12.w -
              ScreenUtil().statusBarHeight;
          _opacity2 = 0;
          Commons.postDelayed(delayMilliseconds: 200, () {
            setState(() {
              _opacity1 = 0;
            });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _swiperController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gaps.generateGap(height: ScreenUtil().statusBarHeight),
        AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: double.infinity,
            height: 48.w,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: OpacityLayout(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.w),
                      child: LoadAssetImage(
                        "ic_close_icon1",
                        width: 22.w,
                        height: 22.w,
                        color: widget.isWeatherHeaderDark ? Colours.white : Colours.black,
                      ),
                    ),
                    onPressed: () {
                      SmartDialog.dismiss(tag: "WeatherForecase40DetailPage");
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.meta?.city ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: widget.isWeatherHeaderDark ? Colours.white : Colours.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: EasyRefresh.builder(
            childBuilder: (_, physics) {
              return SizedBox(
                height: double.infinity,
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                  physics: physics,
                  child: Column(
                    children: [
                      Align(
                        alignment: widget.initPosition.dx <
                                ScreenUtil().screenWidth / 2
                            ? Alignment.topLeft
                            : Alignment.topRight,
                        child: AnimatedOpacity(
                          opacity: _opacity1,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedContainer(
                            width: _size.width,
                            height: _size.height,
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(top: _marginTop),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.w),
                              color: (widget.isDark
                                      ? Colours.white
                                      : Colours.black)
                                  .withValues(alpha: widget.panelOpacity),
                            ),
                            child: AnimatedOpacity(
                              opacity: _opacity2,
                              duration: const Duration(milliseconds: 200),
                              child: _buildWeatherForecase40Calendar(),
                            ),
                          ),
                        ),
                      ),
                      Gaps.generateGap(height: 12.w),
                      AnimatedOpacity(
                        opacity: _opacity,
                        duration: const Duration(milliseconds: 200),
                        child: _buildWeatherForecase40Chart(),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherForecase40Calendar() {
    final dateTime =
        DateTime.tryParse(_currentSelectedItem?.date ?? "") ?? DateTime.now();
    final currentDateStr =
        DateUtil.formatDate(dateTime, format: Constants.mm_dd);
    String currentWeekDay = DateUtil.getWeekday(dateTime, languageCode: "zh");
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        height: 488.w,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.w),
              child: Row(
                children: [
                  _buildWeekTitle("日"),
                  _buildWeekTitle("一"),
                  _buildWeekTitle("二"),
                  _buildWeekTitle("三"),
                  _buildWeekTitle("四"),
                  _buildWeekTitle("五"),
                  _buildWeekTitle("六"),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 348.w,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        overscroll: false,
                      ),
                      child: Swiper(
                        key: const Key('weather_forecase40_detail_swiper'),
                        controller: _swiperController,
                        loop: false,
                        itemCount: _pageData.length,
                        onIndexChanged: (index) {
                          _swiperController.index = index;
                          setState(() {
                            _index = index;
                          });
                        },
                        itemBuilder: (_, index) {
                          final data = _pageData[index];
                          final ratio =
                              ((ScreenUtil().screenWidth - 2 * 16.w) / 7) /
                                  (348.w / 4);
                          return MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            removeBottom: true,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: ratio,
                              ),
                              itemBuilder: (_, index) {
                                final item = data[index];
                                final isSelected =
                                    _currentSelectedItem?.date == item.date;
                                final isEnabled = item.day != null;
                                final dateTime =
                                    DateTime.tryParse(item.date ?? "") ??
                                        DateTime.now();
                                String dateStr = DateUtil.formatDate(dateTime,
                                    format: Constants.dd);
                                final isToday = DateUtil.isToday(
                                    dateTime.millisecondsSinceEpoch);
                                final preItem = data.getOrNull(index - 1);
                                if (preItem != null) {
                                  final preDateTime =
                                      DateTime.tryParse(preItem.date ?? "") ??
                                          DateTime.now();
                                  if (dateTime.month != preDateTime.month) {
                                    dateStr = DateUtil.formatDate(dateTime,
                                        format: "M月");
                                  }
                                }
                                return GestureDetector(
                                  onTap: isEnabled
                                      ? () {
                                          setState(() {
                                            _currentSelectedItem = item;
                                          });
                                          _weatherForecase40ChartKey
                                                  .currentState
                                                  ?.currentSelectedItem =
                                              _currentSelectedItem;
                                        }
                                      : null,
                                  child: Stack(
                                    children: [
                                      AnimatedVisibility(
                                        visible: isSelected,
                                        enter: fadeIn(),
                                        exit: fadeOut(),
                                        enterDuration:
                                            const Duration(milliseconds: 200),
                                        exitDuration:
                                            const Duration(milliseconds: 200),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6.w),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6.w),
                                            color: isSelected
                                                ? (widget.isDark
                                                        ? Colours.black
                                                        : Colours.white)
                                                    .withValues(alpha: widget.panelOpacity)
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: SingleChildScrollView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Gaps.generateGap(height: 12.w),
                                              Text(
                                                isToday ? "今天" : dateStr,
                                                style: TextStyle(
                                                  fontSize: 15.w,
                                                  color: Colours.white
                                                      .withValues(alpha: 
                                                          isEnabled ? 1 : 0.6),
                                                  height: 1,
                                                  fontWeight: isToday
                                                      ? FontWeight.bold
                                                      : null,
                                                ),
                                              ),
                                              Gaps.generateGap(height: 4.w),
                                              isEnabled
                                                  ? LoadAssetImage(
                                                      WeatherIconUtils
                                                          .getWeatherIconByType(
                                                              item.day?.type ??
                                                                  -1,
                                                              item.day?.weatherType ??
                                                                  "",
                                                              false),
                                                      width: 24.w,
                                                      height: 24.w,
                                                    )
                                                  : SizedBox(
                                                      width: 24.w,
                                                      height: 24.w,
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Visibility(
                                          visible:
                                              item.day?.weatherType.isRain() ??
                                                  false,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                              vertical: 3.w,
                                            ),
                                            margin:
                                                EdgeInsets.only(bottom: 12.w),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100.w),
                                              color: Colours.color0DA8FF,
                                            ),
                                            child: Text(
                                              "降水",
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colours.white,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              itemCount: data.length,
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
                    child: Container(
                      alignment: Alignment.center,
                      child: AnimatedSmoothIndicator(
                        activeIndex: _index,
                        count: _pageData.length,
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
                ],
              ),
            ),
            Gaps.generateGap(height: 6.w),
            Container(
              width: double.infinity,
              height: 0.5.w,
              color: Colours.white.withValues(alpha: 0.2),
            ),
            Gaps.generateGap(height: 6.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentDateStr,
                            style: TextStyle(
                              fontSize: 18.w,
                              color: Colours.white,
                              height: 1,
                              fontFamily: "RobotoThin",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gaps.generateGap(height: 8.w),
                          Text(
                            currentWeekDay,
                            style: TextStyle(
                              fontSize: 15.w,
                              color: Colours.white,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: _currentSelectedItem?.aqiLevelName
                                        .isNotNullOrEmpty() ??
                                    false,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.w),
                                    color: _currentSelectedItem?.aqi
                                        .getAqiColor()
                                        .withValues(alpha: 0.48),
                                  ),
                                  child: Text(
                                    _currentSelectedItem?.aqiLevelName ?? "",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colours.white,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Gaps.generateGap(width: 4.w),
                              Text(
                                "${_currentSelectedItem?.high}/${_currentSelectedItem?.low}°",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colours.white,
                                  height: 1,
                                  fontFamily: "RobotoThin",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Gaps.generateGap(height: 8.w),
                          Text(
                            "${_currentSelectedItem?.day?.wthr} ${_currentSelectedItem?.day?.wd}${_currentSelectedItem?.day?.wp}",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colours.white,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekTitle(String title) {
    return Expanded(
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colours.white,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherForecase40Chart() {
    final maxTempData = widget.forecast40
        ?.reduce((e1, e2) => (e1.high ?? 0) > (e2.high ?? 0) ? e1 : e2);
    final minTempData = widget.forecast40
        ?.reduce((e1, e2) => (e1.high ?? 0) < (e2.high ?? 0) ? e1 : e2);
    return Container(
      width: double.infinity,
      height: 288.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.w),
        color: (widget.isDark ? Colours.white : Colours.black).withValues(alpha: widget.panelOpacity),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gaps.generateGap(height: 12.w),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              "40日天气趋势",
              style: TextStyle(
                fontSize: 18.sp,
                color: Colours.white,
                height: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Gaps.generateGap(height: 16.w),
          Align(
            alignment: Alignment.topCenter,
            child: RichText(
              text: TextSpan(
                text: "${widget.forecast40Data?.downDays ?? 0}",
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colours.white,
                  height: 1,
                  fontFamily: "RobotoLight",
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: "天降温",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colours.white.withValues(alpha: 0.6),
                      height: 1,
                      fontFamily: "RobotoLight",
                    ),
                  ),
                  WidgetSpan(child: Gaps.generateGap(width: 4.w)),
                  TextSpan(
                    text: "${widget.forecast40Data?.upDays ?? 0}",
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colours.white,
                      height: 1,
                      fontFamily: "RobotoLight",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "天升温",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colours.white.withValues(alpha: 0.6),
                      height: 1,
                      fontFamily: "RobotoLight",
                    ),
                  ),
                  WidgetSpan(child: Gaps.generateGap(width: 4.w)),
                  TextSpan(
                    text: "${widget.forecast40Data?.rainDays ?? 0}",
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colours.white,
                      height: 1,
                      fontFamily: "RobotoLight",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "天有降水",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colours.white.withValues(alpha: 0.6),
                      height: 1,
                      fontFamily: "RobotoLight",
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: WeatherForecase40Chart(
              key: _weatherForecase40ChartKey,
              width: double.infinity,
              height: double.infinity,
              initSelectedItem: _currentSelectedItem,
              forecast40: widget.forecast40,
              maxTempData: maxTempData,
              minTempData: minTempData,
              callback: (currentSelectedItem) {
                if (_currentSelectedItem != currentSelectedItem) {
                  HapticFeedback.lightImpact();
                }
                final index = _pageData.indexWhere((e) =>
                    e.singleOrNull(
                        (e1) => e1.date == currentSelectedItem?.date) !=
                    null);
                if (index >= 0 && _swiperController.index != index) {
                  _swiperController.index = index;
                  _swiperController.move(index);
                }
                setState(() {
                  _currentSelectedItem = currentSelectedItem;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
