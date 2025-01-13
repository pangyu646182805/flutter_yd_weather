import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_yd_weather/config/app_runtime_data.dart';
import 'package:flutter_yd_weather/main.dart';
import 'package:flutter_yd_weather/model/city_data.dart';
import 'package:flutter_yd_weather/utils/color_utils.dart';
import 'package:flutter_yd_weather/utils/commons.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/utils/pair.dart';
import 'package:flutter_yd_weather/utils/weather_data_utils.dart';
import 'package:flutter_yd_weather/widget/blurry_container.dart';
import 'package:flutter_yd_weather/widget/scale_layout.dart';
import 'package:flutter_yd_weather/widget/scroll_snap_list.dart';
import 'package:flutter_yd_weather/widget/weather_city_selector_item.dart';
import 'package:flutter_yd_weather/widget/weather_city_snapshot.dart';
import 'package:provider/provider.dart';
import 'package:sp_util/sp_util.dart';

import '../config/constants.dart';
import '../model/weather_item_data.dart';
import '../provider/main_provider.dart';
import '../res/colours.dart';

class WeatherCitySelector extends StatefulWidget {
  const WeatherCitySelector({
    super.key,
    this.changeWeatherBgCallback,
  });

  final void Function()? changeWeatherBgCallback;

  @override
  State<StatefulWidget> createState() => WeatherCitySelectorState();
}

class WeatherCitySelectorState extends State<WeatherCitySelector>
    with SingleTickerProviderStateMixin {
  final _list = <Pair<CityData?, List<WeatherItemData>>>[];
  CityData? _currentCityData;
  List<WeatherItemData>? _currentData;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _listKey = GlobalKey<ScrollSnapListState>();
  double _scale = 0.6;
  double _opacity = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..duration = const Duration(milliseconds: 200);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    Commons.post((_) {
      _generateData();
    });
  }

  Future<void> _generateData() async {
    _list.clear();
    final mainP = context.read<MainProvider>();
    final currentCityIdList =
        SpUtil.getStringList(Constants.currentCityIdList) ?? [];
    for (var cityId in currentCityIdList) {
      final cityData = mainP.cityDataBox.get(cityId);
      final findCityId = cityData?.cityId ?? "";
      if (findCityId.isNotNullOrEmpty()) {
        final pair = Pair(
          first: cityData,
          second: WeatherDataUtils.generateWeatherItems(
            mainP.currentWeatherCardSort,
            mainP.currentWeatherObservesCardSort,
            AppRuntimeData.instance.getWeatherData(cityId),
          ),
        );
        if (cityId == Constants.locationCityId) {
          _list.insert(0, pair);
        } else {
          _list.add(pair);
        }
      }
    }
    final initIndex = _list.indexWhere((e) => e.first == mainP.currentCityData);
    _animationController.forward();
    Commons.post((_) {
      _listKey.currentState?.focusToItem(initIndex);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void exit() {
    _listKey.currentState?.animateScroll(-ScreenUtil().screenWidth);
    _animationController.reverse();
  }

  void _dismiss({bool changeWeatherBg = false}) {
    SmartDialog.dismiss(tag: "WeatherCitySelector").then((_) {
      if (changeWeatherBg) {
        widget.changeWeatherBgCallback?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) {
        final animValue = _animation.value;
        return GestureDetector(
          onTap: _dismiss,
          child: BlurryContainer(
            width: double.infinity,
            height: double.infinity,
            color: ColorUtils.adjustAlpha(
                Colours.black.withValues(alpha: 0.15), animValue),
            blur: 25 * animValue,
            borderRadius: BorderRadius.zero,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      height: ScreenUtil().screenHeight * 0.6,
                      child: ScrollSnapList(
                        key: _listKey,
                        duration: 200,
                        curve: Curves.decelerate,
                        scrollPhysics: const BouncingScrollPhysics(),
                        initialOffset: Offset(-ScreenUtil().screenWidth, 0),
                        reverse: true,
                        onItemFocus: (index, isTap) {
                          debugPrint(
                              "onItemFocus index = $index isTap = $isTap");
                          if (isTap) {
                            _switchWeatherCity(index, 200);
                          }
                        },
                        onCurrentTap: (index) {
                          _switchWeatherCity(index, 0);
                        },
                        onTap: _dismiss,
                        itemSize: ScreenUtil().screenWidth * 0.6,
                        itemBuilder: (_, index) {
                          final item = _list[index];
                          return WeatherCitySelectorItem(
                            pair: item,
                          );
                        },
                        itemCount: _list.length,
                        dynamicItemSize: true,
                        dynamicSizeEquation: (difference) {
                          return 1 - min(difference.abs() / 1500, 0.6);
                        }, //optional
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    opacity: animValue,
                    duration: Duration.zero,
                    child: ScaleLayout(
                      scale: 0.95,
                      child: Container(
                        width: 172.w,
                        height: 42.w,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 42.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.w),
                          color: Colours.black.withValues(alpha: 0.2),
                          border: Border.all(
                            width: 0.5.w,
                            color: Colours.white.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          "更改天气背景",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colours.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        _dismiss(changeWeatherBg: true);
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: _currentData.isNotNullOrEmpty(),
                  child: AnimatedScale(
                    scale: _scale,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.decelerate,
                    onEnd: () {
                      if (_scale >= 1) {
                        _dismiss();
                      }
                    },
                    child: WeatherCitySnapshot(
                      cityData: _currentCityData,
                      data: _currentData,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _switchWeatherCity(int index, int delay) {
    Commons.postDelayed(delayMilliseconds: delay, () {
      setState(() {
        _currentCityData = _list[index].first;
        _currentData = _list[index].second;
        Commons.postDelayed(delayMilliseconds: 200, () {
          final mainP = context.read<MainProvider>();
          final isSame =
              _list[index].first?.cityId == mainP.currentCityData?.cityId;
          if (!isSame) {
            mainP.currentCityData = _list[index].first;
          }
          eventBus.fire(
            SwitchWeatherCityEvent(
              refreshWeatherData: !isSame,
              scrollToTopDelay: 200,
            ),
          );
          setState(() {
            _opacity = 0;
            _scale = 1;
          });
        });
      });
    });
  }
}
