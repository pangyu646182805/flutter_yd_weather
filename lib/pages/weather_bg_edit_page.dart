import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_yd_weather/config/app_runtime_data.dart';
import 'package:flutter_yd_weather/config/constants.dart';
import 'package:flutter_yd_weather/provider/main_provider.dart';
import 'package:flutter_yd_weather/res/colours.dart';
import 'package:flutter_yd_weather/res/gaps.dart';
import 'package:flutter_yd_weather/routers/fluro_navigator.dart';
import 'package:flutter_yd_weather/utils/commons.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/utils/theme_utils.dart';
import 'package:flutter_yd_weather/widget/color_input_dialog.dart';
import 'package:flutter_yd_weather/widget/opacity_layout.dart';
import 'package:flutter_yd_weather/widget/scale_layout.dart';
import 'package:flutter_yd_weather/widget/weather_bg_color_selector.dart';
import 'package:flutter_yd_weather/widget/weather_city_snapshot.dart';
import 'package:provider/provider.dart';

import '../model/weather_bg_model.dart';
import '../utils/color_utils.dart';
import '../utils/weather_data_utils.dart';

class WeatherBgEditPage extends StatefulWidget {
  const WeatherBgEditPage({
    super.key,
    required this.weatherType,
    required this.weatherBgModel,
    this.isEdit = false,
    this.isPreviewMode = false,
  });

  final String weatherType;
  final WeatherBgModel? weatherBgModel;
  final bool isEdit;
  final bool isPreviewMode;

  @override
  State<StatefulWidget> createState() => _WeatherBgEditPageState();
}

class _WeatherBgEditPageState extends State<WeatherBgEditPage>
    with SingleTickerProviderStateMixin {
  bool _isNight = false;
  final _hColorSelectorKey = GlobalKey<WeatherBgColorSelectorState>();
  final _sColorSelectorKey = GlobalKey<WeatherBgColorSelectorState>();
  final _vColorSelectorKey = GlobalKey<WeatherBgColorSelectorState>();
  final _colorInputDialogKey = GlobalKey<ColorInputDialogState>();
  List<Color> _colors = [];
  List<Color> _nightColors = [];
  List<HSVColor> _hsvColors = [];
  List<HSVColor> _hsvNightColors = [];
  bool _isStartSelected = true;
  SystemUiOverlayStyle? _systemUiOverlayStyle;

  @override
  void initState() {
    super.initState();
    _colors =
        widget.weatherBgModel?.colors?.map((e) => Color(e)).toList() ?? [];
    _nightColors =
        (widget.weatherBgModel?.nightColors ?? widget.weatherBgModel?.colors)
                ?.map((e) => Color(e))
                .toList() ??
            [];
    _hsvColors = _colors.map((e) => HSVColor.fromColor(e)).toList();
    _hsvNightColors = _nightColors.map((e) => HSVColor.fromColor(e)).toList();
    Commons.post((_) {
      _changeColorSelectorValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainP = context.read<MainProvider>();
    final key = (mainP.currentCityData?.isLocationCity ?? false)
        ? Constants.locationCityId
        : mainP.currentCityData?.cityId;
    final weatherData = AppRuntimeData.instance.getWeatherData(key ?? "");
    final data = WeatherDataUtils.generateWeatherItems(
      mainP.currentWeatherCardSort,
      mainP.currentWeatherObservesCardSort,
      weatherData,
    );
    return AnnotatedRegion(
      value: _systemUiOverlayStyle ?? context.systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Gaps.generateGap(height: ScreenUtil().statusBarHeight),
            Container(
              width: double.infinity,
              height: 64.w,
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Row(
                children: [
                  Expanded(
                    child: OpacityLayout(
                      onPressed: () {
                        if (_isNight) {
                          setState(() {
                            _isStartSelected = true;
                            _isNight = false;
                            _changeColorSelectorValue();
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: EdgeInsets.symmetric(vertical: 12.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.w),
                          color: context.black.withValues(alpha: 
                            _isNight ? 0 : 0.25,
                          ),
                        ),
                        child: Text(
                          "日间",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: context.black,
                            fontWeight: _isNight ? null : FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: OpacityLayout(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: EdgeInsets.symmetric(vertical: 12.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.w),
                          color: context.black.withValues(alpha: 
                            _isNight ? 0.25 : 0,
                          ),
                        ),
                        child: Text(
                          "夜间",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: context.black,
                            fontWeight: _isNight ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (!_isNight) {
                          setState(() {
                            _isStartSelected = true;
                            _isNight = true;
                            _changeColorSelectorValue();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final scale = (constraints.maxHeight - 16.w) /
                      ScreenUtil().screenHeight;
                  return Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          maxWidth: ScreenUtil().screenWidth,
                          maxHeight: ScreenUtil().screenHeight,
                          child: Transform.scale(
                            alignment: Alignment.topCenter,
                            scale: scale,
                            child: WeatherCitySnapshot(
                              cityData: mainP.currentCityData,
                              data: data,
                              needMask: false,
                              colors: (_isNight ? _nightColors : _colors)
                                      .isNullOrEmpty()
                                  ? null
                                  : (_isNight ? _nightColors : _colors),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !widget.isPreviewMode,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: ScreenUtil().screenWidth * scale,
                            padding: EdgeInsets.only(
                              top: 138.w,
                              bottom: 132.w,
                            ),
                            margin: EdgeInsets.only(bottom: 16.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildBubbleBox(
                                  ColorUtils.color2HEX(
                                      (_isNight ? _nightColors : _colors)
                                          .getOrNull(0),
                                      toUpperCase: true),
                                  () {
                                    if (!_isStartSelected) {
                                      _isStartSelected = true;
                                      _changeColorSelectorValue();
                                      setState(() {});
                                    } else {
                                      _showColorInputDialog();
                                    }
                                  },
                                  direction: BubbleDirection.bottom,
                                  isSelected: _isStartSelected,
                                ),
                                _buildBubbleBox(
                                  ColorUtils.color2HEX(
                                      (_isNight ? _nightColors : _colors)
                                          .getOrNull(1),
                                      toUpperCase: true),
                                  () {
                                    if (_isStartSelected) {
                                      _isStartSelected = false;
                                      _changeColorSelectorValue();
                                      setState(() {});
                                    } else {
                                      _showColorInputDialog();
                                    }
                                  },
                                  direction: BubbleDirection.top,
                                  isSelected: !_isStartSelected,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Visibility(
              visible: !widget.isPreviewMode,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 32.w,
                  right: 32.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "色相：",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.black,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.generateGap(height: 4.w),
                    WeatherBgColorSelector(
                      key: _hColorSelectorKey,
                      width: double.infinity,
                      height: 20.w,
                      max: 360,
                      onValueChanged: (hue) {
                        setState(() {
                          final hsvColor = _isNight
                              ? _hsvNightColors[_isStartSelected ? 0 : 1]
                              : _hsvColors[_isStartSelected ? 0 : 1];
                          final newHsvColor = HSVColor.fromAHSV(
                              1, hue, hsvColor.saturation, hsvColor.value);
                          _isNight
                              ? _hsvNightColors[_isStartSelected ? 0 : 1] =
                                  newHsvColor
                              : _hsvColors[_isStartSelected ? 0 : 1] =
                                  newHsvColor;
                          _isNight
                              ? _nightColors[_isStartSelected ? 0 : 1] =
                                  newHsvColor.toColor()
                              : _colors[_isStartSelected ? 0 : 1] =
                                  newHsvColor.toColor();
                        });
                      },
                      colors: [
                        0xFFFF0000,
                        0xFFFF00FF,
                        0xFF0000FF,
                        0xFF00FFFF,
                        0xFF00FF00,
                        0xFFFFFF00,
                        0xFFFF0000
                      ].reversed.map((e) => Color(e)).toList(),
                      stops: const [0, 1 / 6, 1 / 3, 1 / 2, 2 / 3, 5 / 6, 1],
                    ),
                    Gaps.generateGap(height: 16.w),
                    Text(
                      "饱和度：",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.black,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.generateGap(height: 4.w),
                    WeatherBgColorSelector(
                      key: _sColorSelectorKey,
                      width: double.infinity,
                      height: 20.w,
                      max: 1,
                      onValueChanged: (saturation) {
                        setState(() {
                          final hsvColor = _isNight
                              ? _hsvNightColors[_isStartSelected ? 0 : 1]
                              : _hsvColors[_isStartSelected ? 0 : 1];
                          final newHsvColor = HSVColor.fromAHSV(
                              1, hsvColor.hue, saturation, hsvColor.value);
                          _isNight
                              ? _hsvNightColors[_isStartSelected ? 0 : 1] =
                                  newHsvColor
                              : _hsvColors[_isStartSelected ? 0 : 1] =
                                  newHsvColor;
                          _isNight
                              ? _nightColors[_isStartSelected ? 0 : 1] =
                                  newHsvColor.toColor()
                              : _colors[_isStartSelected ? 0 : 1] =
                                  newHsvColor.toColor();
                        });
                      },
                      colors: [
                        Colours.white,
                        HSVColor.fromAHSV(
                                1,
                                (_isNight
                                        ? _hsvNightColors[
                                            _isStartSelected ? 0 : 1]
                                        : _hsvColors[_isStartSelected ? 0 : 1])
                                    .hue,
                                1,
                                1)
                            .toColor(),
                      ],
                    ),
                    Gaps.generateGap(height: 16.w),
                    Text(
                      "亮度：",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.black,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.generateGap(height: 4.w),
                    WeatherBgColorSelector(
                      key: _vColorSelectorKey,
                      width: double.infinity,
                      height: 20.w,
                      max: 1,
                      onValueChanged: (value) {
                        setState(() {
                          final hsvColor = _isNight
                              ? _hsvNightColors[_isStartSelected ? 0 : 1]
                              : _hsvColors[_isStartSelected ? 0 : 1];
                          final newHsvColor = HSVColor.fromAHSV(
                              1, hsvColor.hue, hsvColor.saturation, value);
                          _isNight
                              ? _hsvNightColors[_isStartSelected ? 0 : 1] =
                                  newHsvColor
                              : _hsvColors[_isStartSelected ? 0 : 1] =
                                  newHsvColor;
                          _isNight
                              ? _nightColors[_isStartSelected ? 0 : 1] =
                                  newHsvColor.toColor()
                              : _colors[_isStartSelected ? 0 : 1] =
                                  newHsvColor.toColor();
                        });
                      },
                      colors: const [
                        Colours.black,
                        Colours.white,
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Gaps.generateGap(height: widget.isPreviewMode ? 0 : 12.w),
            Visibility(
              visible: !widget.isPreviewMode,
              child: SizedBox(
                width: double.infinity,
                height: 64.w,
                child: Row(
                  children: [
                    Expanded(
                      child: OpacityLayout(
                        onPressed: () {
                          NavigatorUtils.goBack(context);
                        },
                        child: Center(
                          child: Text(
                            "取消",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: context.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: OpacityLayout(
                        child: Center(
                          child: Text(
                            "确定",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: context.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onPressed: () {
                          final weatherBgModel = WeatherBgModel(
                            isSelected: widget.isEdit
                                ? widget.weatherBgModel?.isSelected
                                : null,
                            supportEdit: true,
                            colors: _colors.map((e) => e.value).toList(),
                            nightColors:
                                _nightColors.map((e) => e.value).toList(),
                          );
                          AppRuntimeData.instance.addWeatherBg(
                            widget.weatherType,
                            weatherBgModel,
                            editWeatherBgModel:
                                widget.isEdit ? widget.weatherBgModel : null,
                            callback: () {
                              NavigatorUtils.goBack(context);
                            },
                          );
                        },
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

  Widget _buildBubbleBox(
    String content,
    VoidCallback onPressed, {
    BubbleDirection direction = BubbleDirection.bottom,
    bool isSelected = true,
  }) {
    return ScaleLayout(
      onPressed: onPressed,
      child: BubbleBox(
        shape: BubbleShapeBorder(
          radius: BorderRadius.circular(12.w),
          direction: direction,
          arrowAngle: 6.w,
          position: const BubblePosition.center(0),
        ),
        backgroundColor: isSelected ? Colours.colorD5D5D5 : Colours.white,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
        child: Text(
          content,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colours.color333333,
            height: 1,
          ),
        ),
      ),
    );
  }

  void _changeColorSelectorValue() {
    final hsvColor = _isNight
        ? _hsvNightColors[_isStartSelected ? 0 : 1]
        : _hsvColors[_isStartSelected ? 0 : 1];
    _hColorSelectorKey.currentState?.changeValue(hsvColor.hue);
    _sColorSelectorKey.currentState?.changeValue(hsvColor.saturation);
    _vColorSelectorKey.currentState?.changeValue(hsvColor.value);
  }

  void _showColorInputDialog() {
    setState(() {
      _systemUiOverlayStyle = SystemUiOverlayStyle.light;
    });
    SmartDialog.show(
      tag: "ColorInputDialog",
      clickMaskDismiss: true,
      onDismiss: () {
        setState(() {
          _systemUiOverlayStyle = null;
        });
        _colorInputDialogKey.currentState?.exit();
      },
      animationTime: const Duration(milliseconds: 400),
      animationBuilder: (
        controller,
        child,
        animationParam,
      ) {
        return child;
      },
      builder: (_) {
        return ColorInputDialog(
          key: _colorInputDialogKey,
          completed: (color) {
            if (color != null) {
              setState(() {
                _isNight
                    ? _nightColors[_isStartSelected ? 0 : 1] = color
                    : _colors[_isStartSelected ? 0 : 1] = color;
                _isNight
                    ? _hsvNightColors[_isStartSelected ? 0 : 1] =
                        HSVColor.fromColor(color)
                    : _hsvColors[_isStartSelected ? 0 : 1] =
                        HSVColor.fromColor(color);
                _changeColorSelectorValue();
              });
            }
          },
        );
      },
    );
  }
}
