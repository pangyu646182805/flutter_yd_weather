import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/utils/commons.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../model/weather_alarms_data.dart';
import '../res/colours.dart';
import '../res/gaps.dart';

class WeatherAlarmsDetailPopup extends StatefulWidget {
  const WeatherAlarmsDetailPopup({
    super.key,
    required this.alarms,
    required this.initPosition,
    required this.initHeight,
    this.index = 0,
    required this.isDark,
    required this.panelOpacity,
    this.onIndexChanged,
  });

  final Offset initPosition;
  final double initHeight;
  final int index;
  final bool isDark;
  final double panelOpacity;
  final List<WeatherAlarmsData> alarms;
  final ValueChanged<int>? onIndexChanged;

  @override
  State<StatefulWidget> createState() => WeatherAlarmsDetailPopupState();
}

class WeatherAlarmsDetailPopupState extends State<WeatherAlarmsDetailPopup> {
  int _index = 0;
  List<double> _heights = [];
  double _height = 0;
  Alignment _alignment = Alignment.topCenter;
  double _marginTop = 0;
  double _opacity = 0;
  late SwiperController _swiperController;

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController()..index = widget.index;
    _index = widget.index;
    _alignment = Alignment.topCenter;
    _marginTop = widget.initPosition.dy;
    _height = widget.initHeight;
    _opacity = 0;
    _heights = widget.alarms
        .map((e) =>
            e.desc.getTextContextSizeHeight(
              TextStyle(
                fontSize: 14.sp,
                color: Colours.white,
              ),
              maxWidth: ScreenUtil().screenWidth - 4 * 16.w,
            ) +
            53.w +
            42.w)
        .toList();
    debugPrint("_heights = $_heights");
    Commons.post((_) {
      setState(() {
        _opacity = 1;
        _alignment = Alignment.center;
        _marginTop = 0;
        _height = _heights[widget.index];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _swiperController.dispose();
  }

  void exit() {
    setState(() {
      _opacity = 0;
      _alignment = Alignment.topCenter;
      _marginTop = widget.initPosition.dy;
      _height = widget.initHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 200),
      alignment: _alignment,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          width: double.infinity,
          height: _height,
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(
            left: 16.w,
            top: _marginTop,
            right: 16.w,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            color: (widget.isDark ? Colours.white : Colours.black)
                .withValues(alpha: widget.panelOpacity),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    overscroll: false,
                  ),
                  child: Swiper(
                    key: const Key('alarms_popup_swiper'),
                    controller: _swiperController,
                    loop: false,
                    transformer: ScaleAndFadeTransformer(),
                    itemCount: widget.alarms.length,
                    onIndexChanged: (index) {
                      setState(() {
                        _height = _heights[index];
                        _index = index;
                      });
                      widget.onIndexChanged?.call(index);
                    },
                    itemBuilder: (_, index) {
                      final item = widget.alarms.getOrNull(index);
                      final dateTime = DateTime.tryParse(item?.pubTime ?? "");
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
                            Text(
                              item?.title ?? "",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colours.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Gaps.generateGap(height: 4.w),
                            Text(
                              pubTimeDesc,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colours.white,
                              ),
                            ),
                            Gaps.generateGap(height: 8.w),
                            Text(
                              item?.desc ?? "",
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
                  visible: (widget.alarms.length) > 1,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.w),
                    alignment: Alignment.center,
                    child: AnimatedSmoothIndicator(
                      activeIndex: _index,
                      count: widget.alarms.length,
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
      ),
    );
  }
}
