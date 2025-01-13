import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_yd_weather/utils/commons.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';

import '../model/weather_env_data.dart';
import '../res/colours.dart';
import '../res/gaps.dart';
import 'air_quality_bar.dart';
import 'air_quality_query_dialog.dart';
import 'load_asset_image.dart';
import 'opacity_layout.dart';

class AirQualityDetailPopup extends StatefulWidget {
  const AirQualityDetailPopup({
    super.key,
    required this.initPosition,
    required this.isDark,
    required this.panelOpacity,
    required this.evn,
  });

  final Offset initPosition;
  final bool isDark;
  final double panelOpacity;
  final WeatherEnvData? evn;

  @override
  State<StatefulWidget> createState() => AirQualityDetailPopupState();
}

class AirQualityDetailPopupState extends State<AirQualityDetailPopup> {
  Alignment _alignment = Alignment.topCenter;
  double _marginTop = 0;
  double _panelOpacity = 1;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _panelOpacity = 1;
    _opacity = 0;
    _alignment = Alignment.topCenter;
    _marginTop = widget.initPosition.dy;
    Commons.post((_) {
      setState(() {
        _alignment = Alignment.center;
        _marginTop = 0;
        Commons.postDelayed(delayMilliseconds: 200, () {
          setState(() {
            _opacity = 1;
          });
        });
      });
    });
  }

  void exit() {
    setState(() {
      _alignment = Alignment.topCenter;
      _marginTop = widget.initPosition.dy;
      _opacity = 0;
      Commons.postDelayed(delayMilliseconds: 200, () {
        setState(() {
          _panelOpacity = 0;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 200),
      alignment: _alignment,
      child: AnimatedOpacity(
        opacity: _panelOpacity,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              width: double.infinity,
              height: 88.w,
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                left: 16.w,
                top: _marginTop,
                right: 16.w,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                color: (widget.isDark ? Colours.white : Colours.black)
                    .withValues(alpha: widget.panelOpacity),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gaps.generateGap(height: 12.w),
                  Row(
                    children: [
                      Text(
                        "${widget.evn?.aqi} - ${widget.evn?.aqiLevelName}",
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
                  Gaps.generateGap(height: 10.w),
                  AirQualityBar(
                    width: double.infinity,
                    height: 4.w,
                    aqi: widget.evn?.aqi ?? 0,
                  ),
                  Gaps.generateGap(height: 8.w),
                  Text(
                    "当前AQI为${widget.evn?.aqi}",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colours.white,
                    ),
                  )
                ],
              ),
            ),
            Gaps.generateGap(height: 12.w),
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 12.w,
                  children: [
                    _buildItem("PM2.5", widget.evn?.pm25 ?? 0),
                    _buildItem("PM10", widget.evn?.pm10 ?? 0),
                    _buildItem("NO", subscript: "2", widget.evn?.no2 ?? 0),
                    _buildItem("SO", subscript: "2", widget.evn?.so2 ?? 0),
                    _buildItem("O", subscript: "3", widget.evn?.o3 ?? 0),
                    _buildItem("CO", widget.evn?.co ?? 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    String title,
    int value, {
    String? subscript,
  }) {
    return Container(
      width: (ScreenUtil().screenWidth - 16.w * 2 - 12.w * 2) / 3,
      height: 72.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.w),
        color: (widget.isDark ? Colours.white : Colours.black).withValues(alpha: widget.panelOpacity),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colours.white,
                  height: 1,
                  fontFamily: "RobotoLight",
                  fontWeight: FontWeight.bold,
                ),
              ),
              Visibility(
                visible: subscript.isNotNullOrEmpty(),
                child: Text(
                  subscript ?? "",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colours.white,
                    height: 1,
                    fontFamily: "RobotoLight",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Gaps.generateGap(width: 2.w),
              Text(
                "ug/m³",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colours.white.withValues(alpha: 0.6),
                  height: 1,
                ),
              ),
            ],
          ),
          Gaps.generateGap(height: 12.w),
          Text(
            "${value.toDouble()}",
            style: TextStyle(
              fontSize: 18.sp,
              color: Colours.white,
              height: 1,
              fontFamily: "RobotoLight",
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
