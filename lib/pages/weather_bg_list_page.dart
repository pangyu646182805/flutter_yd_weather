import 'package:animated_visibility/animated_visibility.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/config/app_runtime_data.dart';
import 'package:flutter_yd_weather/config/constants.dart';
import 'package:flutter_yd_weather/res/colours.dart';
import 'package:flutter_yd_weather/routers/app_router.dart';
import 'package:flutter_yd_weather/routers/fluro_navigator.dart';
import 'package:flutter_yd_weather/utils/color_utils.dart';
import 'package:flutter_yd_weather/utils/commons.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/utils/theme_utils.dart';
import 'package:flutter_yd_weather/widget/load_asset_image.dart';
import 'package:flutter_yd_weather/widget/my_app_bar.dart';
import 'package:flutter_yd_weather/widget/scale_layout.dart';

import '../model/weather_bg_model.dart';

class WeatherBgListPage extends StatefulWidget {
  const WeatherBgListPage({super.key});

  @override
  State<StatefulWidget> createState() => _WeatherBgListPageState();
}

class _WeatherBgListPageState extends State<WeatherBgListPage> {
  late ScrollController _scrollController;
  final _weatherBgMapNotifier =
      ValueNotifier<Map<String, List<WeatherBgModel>>>({});
  bool _isNight = false;
  bool _isShowMenu = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    AppRuntimeData.instance.onWeatherBgMapChanged = (weatherBgMap) {
      debugPrint("weatherBgMap = $weatherBgMap");
      _weatherBgMapNotifier.value = {...weatherBgMap};
    };
    _weatherBgMapNotifier.value = {
      ...AppRuntimeData.instance.getWeatherBgMap()
    };
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    AppRuntimeData.instance.onWeatherBgMapChanged = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: MyAppBar(
        backgroundColor: context.backgroundColor,
        backImg: "ic_close_icon1",
        centerTitle: "天气背景",
        titleColor: context.black,
        rightAction1: _isShowMenu ? "全部删除" : (_isNight ? "夜间" : "日间"),
        onRightAction1Pressed: () {
          if (_isShowMenu) {
            AppRuntimeData.instance.removeAllWeatherBg(callback: () {
              setState(() {
                _isShowMenu = false;
              });
            });
          } else {
            setState(() {
              _isNight = !_isNight;
            });
          }
        },
      ),
      body: ValueListenableBuilder(
        valueListenable: _weatherBgMapNotifier,
        builder: (_, weatherBgMap, ___) {
          return EasyRefresh.builder(
            scrollController: _scrollController,
            notRefreshHeader: const NotRefreshHeader(
              position: IndicatorPosition.locator,
              hitOver: true,
            ),
            childBuilder: (_, physics) {
              return NotificationListener(
                onNotification: (notification) {
                  if (_isShowMenu) {
                    setState(() {
                      _isShowMenu = false;
                    });
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: physics,
                  padding: EdgeInsets.only(bottom: 12.w),
                  itemBuilder: (_, index) {
                    final weatherType = weatherBgMap.keys.toList()[index];
                    final itemData = weatherBgMap.values.toList()[index];
                    return _buildItem(context, weatherType, itemData);
                  },
                  itemCount: weatherBgMap.length,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, String weatherType, List<WeatherBgModel> data) {
    final selectedItem = data.singleOrNull((e) => e.isSelected ?? false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 42.w,
          padding: EdgeInsets.only(left: 20.w),
          alignment: Alignment.centerLeft,
          child: Text(
            _getTitle(weatherType),
            style: TextStyle(
              fontSize: 18.sp,
              color: context.textColor01,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12.w,
              crossAxisSpacing: 12.w,
              childAspectRatio:
                  ScreenUtil().screenWidth / ScreenUtil().screenHeight,
            ),
            itemBuilder: (_, index) {
              final weatherBgModel = data.getOrNull(index);
              if (weatherBgModel != null) {
                return _buildWeatherBgItem(weatherType, weatherBgModel);
              } else {
                return _buildWeatherBgAddItem(
                  weatherType,
                  selectedItem,
                );
              }
            },
            itemCount: data.length < Constants.maxWeatherBgCount
                ? data.length + 1
                : data.length,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherBgItem(String weatherType, WeatherBgModel data) {
    final colors = ((_isNight ? data.nightColors : data.colors) ?? data.colors)
            ?.map((e) => Color(e))
            .toList() ??
        [];
    final color1 = colors.getOrNull(0) ?? Colours.white;
    final color2 = colors.getOrNull(1) ?? Colours.white;
    final similarity1 =
        ColorUtils.calSimilarity(context.backgroundColor, color1);
    final similarity2 =
        ColorUtils.calSimilarity(context.backgroundColor, color2);
    final isDark =
        ThemeData.estimateBrightnessForColor(color1) == Brightness.dark;
    return ScaleLayout(
      scale: 0.95,
      onPressed: () {
        if (_isShowMenu) {
          setState(() {
            _isShowMenu = false;
          });
        } else {
          if (!(data.isSelected ?? false)) {
            AppRuntimeData.instance.setCurrentWeatherBg(weatherType, data);
          }
        }
      },
      onLongPressed: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isShowMenu = !_isShowMenu;
        });
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.w),
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: similarity1 > 0.95 && similarity2 > 0.95
                  ? Border.all(
                      width: 1.w,
                      color: context.black,
                    )
                  : null,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedVisibility(
              visible: !_isShowMenu && (data.isSelected ?? false),
              enter: fadeIn(),
              exit: fadeOut(),
              enterDuration: const Duration(milliseconds: 200),
              exitDuration: const Duration(milliseconds: 200),
              child: LoadAssetImage(
                "ic_xuanzhong",
                width: 32.w,
                height: 32.w,
                color: isDark ? Colours.white : Colours.black,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedVisibility(
              visible: _isShowMenu,
              enter: scaleIn() + fadeIn(),
              exit: scaleOut() + fadeOut(),
              enterDuration: const Duration(milliseconds: 200),
              exitDuration: const Duration(milliseconds: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: data.supportEdit ?? false,
                    child: ScaleLayout(
                      scale: 0.95,
                      onPressed: () {
                        setState(() {
                          _isShowMenu = false;
                          Commons.post((_) {
                            NavigatorUtils.push(
                              context,
                              AppRouter.weatherBgEditPage,
                              arguments: {
                                "weatherType": weatherType,
                                "weatherBgModel": data,
                                "isEdit": true,
                              },
                              transition: TransitionType.inFromBottom,
                            );
                          });
                        });
                      },
                      child: Container(
                        width: 48.w,
                        height: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.w),
                          color: Colours.white,
                        ),
                        child: Text(
                          "编辑",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colours.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ScaleLayout(
                    scale: 0.95,
                    onPressed: () {
                      setState(() {
                        _isShowMenu = false;
                        Commons.post((_) {
                          NavigatorUtils.push(
                            context,
                            AppRouter.weatherBgEditPage,
                            arguments: {
                              "weatherType": weatherType,
                              "weatherBgModel": data,
                              "isPreviewMode": true,
                            },
                            transition: TransitionType.inFromBottom,
                          );
                        });
                      });
                    },
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.w),
                        color: Colours.white,
                      ),
                      child: Text(
                        "预览",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colours.black,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: data.supportEdit ?? false,
                    child: ScaleLayout(
                      scale: 0.95,
                      onPressed: () {
                        setState(() {
                          _isShowMenu = false;
                          Commons.post((_) {
                            AppRuntimeData.instance
                                .removeWeatherBg(weatherType, data);
                          });
                        });
                      },
                      child: Container(
                        width: 48.w,
                        height: 48.w,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: 12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.w),
                          color: Colours.white,
                        ),
                        child: Text(
                          "删除",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colours.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherBgAddItem(
    String weatherType,
    WeatherBgModel? selectedItem,
  ) {
    return ScaleLayout(
      scale: 0.95,
      onPressed: () {
        setState(() {
          _isShowMenu = false;
          Commons.post((_) {
            NavigatorUtils.push(
              context,
              AppRouter.weatherBgEditPage,
              arguments: {
                "weatherType": weatherType,
                "weatherBgModel": selectedItem,
              },
              transition: TransitionType.inFromBottom,
            );
          });
        });
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.w),
              border: Border.all(
                width: 2.w,
                color: context.black.withValues(alpha: 0.2),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 2.w,
              height: 32.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.w),
                color: context.black.withValues(alpha: 0.2),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 32.w,
              height: 2.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.w),
                color: context.black.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(String weatherType) {
    switch (weatherType) {
      case "CLEAR":
        return "晴天";
      case "PARTLY_CLOUDY":
        return "多云";
      case "CLOUDY":
        return "阴";
      case "LIGHT_HAZE":
        return "轻度雾霾、中度雾霾";
      case "HEAVY_HAZE":
        return "重度雾霾";
      case "LIGHT_RAIN":
        return "小雨";
      case "MODERATE_RAIN":
        return "中雨、大雨、暴雨";
      case "FOG":
        return "雾";
      case "LIGHT_SNOW":
        return "小雪、中雪、大雪、暴雪";
      case "DUST":
        return "浮尘、沙尘";
      case "WIND":
        return "大风";
    }
    return "";
  }
}
