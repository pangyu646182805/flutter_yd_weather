import 'package:animated_visibility/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_yd_weather/main.dart';
import 'package:flutter_yd_weather/model/city_manager_data.dart';
import 'package:flutter_yd_weather/provider/main_provider.dart';
import 'package:flutter_yd_weather/res/gaps.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/utils/theme_utils.dart';
import 'package:flutter_yd_weather/utils/weather_bg_utils.dart';
import 'package:flutter_yd_weather/widget/auto_size_text.dart';
import 'package:flutter_yd_weather/widget/scale_layout.dart';
import 'package:flutter_yd_weather/widget/yd_reorderable_list.dart';
import 'package:provider/provider.dart';
import '../res/colours.dart';
import '../utils/color_utils.dart';
import '../utils/commons.dart';
import '../utils/weather_data_utils.dart';
import 'city_manager_slidable_action.dart';
import 'load_asset_image.dart';

class CityManagerItem extends StatefulWidget {
  const CityManagerItem({
    super.key,
    required this.cityManagerData,
    required this.isEditMode,
    this.isSelected = false,
    this.onTap,
    this.toEditMode,
    this.removeItem,
  });

  final CityManagerData cityManagerData;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final void Function(CityManagerData? data)? toEditMode;
  final void Function(CityManagerData data)? removeItem;

  @override
  State<StatefulWidget> createState() => CityManagerItemState();
}

class CityManagerItemState extends State<CityManagerItem>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final mainP = context.read<MainProvider>();
    final cityData = widget.cityManagerData.cityData;
    final isLocationCity = cityData?.isLocationCity ?? false;
    final weatherData = cityData?.weatherData;
    final street = cityData?.street ?? "";
    final city = weatherData?.city ?? "";
    final title = !isLocationCity || street.isNullOrEmpty() ? city : "$city $street";
    widget.cityManagerData.slidableController ??= SlidableController(this);
    final weatherBg = WeatherBgUtils.generateWeatherBg(
      weatherData?.weatherType ?? "",
      Commons.isNight(
        DateTime.now(),
        sunrise: weatherData?.sunrise,
        sunset: weatherData?.sunset,
      ),
    );
    final color1 = weatherBg.colors.getOrNull(0) ?? Colours.white;
    final color2 = weatherBg.colors.getOrNull(1) ?? Colours.white;
    final similarity1 =
        ColorUtils.calSimilarity(context.backgroundColor, color1);
    final similarity2 =
        ColorUtils.calSimilarity(context.backgroundColor, color2);
    final isDark = WeatherDataUtils.isWeatherHeaderDark(weatherBg);
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Slidable(
        controller: widget.cityManagerData.slidableController,
        key: widget.cityManagerData.key,
        enabled: !isLocationCity && !widget.isEditMode,
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.2,
          children: [
            AnimatedBuilder(
              animation: widget.cityManagerData.slidableController!.animation,
              builder: (_, __) {
                return CityManagerSlidableAction(
                  percent: (widget.cityManagerData.slidableController!.animation
                              .value /
                          0.2)
                      .fixPercent(),
                  onTap: () {
                    widget.removeItem?.call(widget.cityManagerData);
                  },
                );
              },
            ),
          ],
        ),
        child: ScaleLayout(
          scale: 0.95,
          onPressed: () {
            if (!widget.isEditMode) {
              if (cityData?.cityId != mainP.currentCityData?.cityId) {
                mainP.currentCityData = cityData;
                eventBus.fire(RefreshWeatherDataEvent());
              }
              widget.onTap?.call();
            } else {
              if (!isLocationCity) {
                widget.onTap?.call();
              }
            }
          },
          onLongPressed: isLocationCity
              ? () {
                  HapticFeedback.lightImpact();
                  widget.toEditMode?.call(widget.cityManagerData);
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 98.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.w),
              gradient: weatherBg,
              border: similarity1 > 0.95 && similarity2 > 0.95
                  ? Border.all(
                      width: 1.w,
                      color: context.black,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Visibility(
                  visible: context.isDark,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.w),
                      gradient: LinearGradient(
                        colors: [
                          Colours.black.withValues(alpha: 0.2),
                          Colours.black.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      AnimatedVisibility(
                        visible: widget.isEditMode && !isLocationCity,
                        enter: fadeIn(),
                        exit: fadeOut(),
                        enterDuration: const Duration(milliseconds: 200),
                        exitDuration: const Duration(milliseconds: 200),
                        child: ReorderableListener(
                          canStart: () => !isLocationCity,
                          child: Container(
                            height: double.infinity,
                            margin: EdgeInsets.only(
                              right: 12.w,
                            ),
                            child: LoadAssetImage(
                              "ic_menu_icon",
                              width: 24.w,
                              height: 24.w,
                              color: isDark ? Colours.white : Colours.black,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: DelayedReorderableListener(
                          canStart: () => !isLocationCity,
                          child: Container(
                            color: Colours.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: LayoutBuilder(
                                            builder: (_, c) {
                                              final maxWidth = c.maxWidth;
                                              return Row(
                                                children: [
                                                  AutoSizeText(
                                                    text: title,
                                                    textStyle: TextStyle(
                                                      fontSize: 20.sp,
                                                      color: isDark
                                                          ? Colours.white
                                                          : Colours.black,
                                                      height: 1,
                                                      fontFamily: "RobotoLight",
                                                    ),
                                                    maxWidth: maxWidth - 12.w,
                                                  ),
                                                  Visibility(
                                                    visible: isLocationCity,
                                                    child: LoadAssetImage(
                                                      "writing_icon_location1",
                                                      width: 22.w,
                                                      height: 22.w,
                                                      color: isDark
                                                          ? Colours.white
                                                          : Colours.black,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ))
                                        ],
                                      ),
                                      Gaps.generateGap(height: 4.w),
                                      Text(
                                        "${weatherData?.weatherDesc} ${weatherData?.tempHigh.getTemp()} / ${weatherData?.tempLow.getTemp()}",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: isDark
                                              ? Colours.white
                                              : Colours.black,
                                          fontFamily: "RobotoLight",
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      weatherData?.temp.getTemp() ?? "",
                                      style: TextStyle(
                                        fontSize: 38.sp,
                                        color: isDark
                                            ? Colours.white
                                            : Colours.black,
                                        height: 1,
                                        fontFamily: "RobotoLight",
                                      ),
                                    ),
                                    AnimatedVisibility(
                                      visible:
                                          widget.isEditMode && !isLocationCity,
                                      enter: fadeIn(),
                                      exit: fadeOut(),
                                      enterDuration:
                                          const Duration(milliseconds: 200),
                                      exitDuration:
                                          const Duration(milliseconds: 200),
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 12.w),
                                        child: Stack(
                                          children: [
                                            AnimatedVisibility(
                                              visible: widget.isEditMode &&
                                                  !widget.isSelected,
                                              enter: fadeIn(),
                                              exit: fadeOut(),
                                              enterDuration: const Duration(
                                                  milliseconds: 20),
                                              exitDuration: const Duration(
                                                  milliseconds: 20),
                                              child: LoadAssetImage(
                                                "ic_check_icon",
                                                width: 22.w,
                                                height: 22.w,
                                                color: isDark
                                                    ? Colours.white
                                                    : Colours.black,
                                              ),
                                            ),
                                            AnimatedVisibility(
                                              visible: widget.isEditMode &&
                                                  widget.isSelected,
                                              enter: fadeIn(),
                                              exit: fadeOut(),
                                              enterDuration: const Duration(
                                                  milliseconds: 20),
                                              exitDuration: const Duration(
                                                  milliseconds: 20),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width: 22.w,
                                                    height: 22.w,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.w),
                                                      color: widget.isSelected
                                                          ? Colours.white
                                                          : Colours.transparent,
                                                    ),
                                                  ),
                                                  LoadAssetImage(
                                                    "ic_checked_icon",
                                                    width: 22.w,
                                                    height: 22.w,
                                                    color: Colours.appMain,
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
                              ],
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
        ),
      ),
    );
    return YdReorderableItem(
      key: widget.cityManagerData.key, //
      childBuilder: (_, state) {
        if (state == ReorderableItemState.dragProxy) {
          widget.toEditMode?.call(widget.cityManagerData);
        }
        return AnimatedOpacity(
          opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
          duration: Duration.zero,
          child: AnimatedVisibility(
            visible: !widget.cityManagerData.removed,
            enter: expandVertically(alignment: -1) + fadeIn(),
            exit: shrinkVertically(alignment: -1) + fadeOut(),
            enterDuration: const Duration(milliseconds: 200),
            exitDuration: const Duration(milliseconds: 200),
            child: content,
          ),
        );
      },
    );
  }
}
