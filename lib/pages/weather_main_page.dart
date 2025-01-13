import 'dart:async';
import 'dart:math';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_yd_weather/config/app_runtime_data.dart';
import 'package:flutter_yd_weather/main.dart';
import 'package:flutter_yd_weather/mvp/power_presenter.dart';
import 'package:flutter_yd_weather/pages/city_manager_page.dart';
import 'package:flutter_yd_weather/pages/presenter/weather_main_presenter.dart';
import 'package:flutter_yd_weather/pages/provider/weather_provider.dart';
import 'package:flutter_yd_weather/pages/view/weather_main_view.dart';
import 'package:flutter_yd_weather/provider/main_provider.dart';
import 'package:flutter_yd_weather/res/gaps.dart';
import 'package:flutter_yd_weather/routers/app_router.dart';
import 'package:flutter_yd_weather/routers/fluro_navigator.dart';
import 'package:flutter_yd_weather/utils/commons.dart';
import 'package:flutter_yd_weather/utils/device.dart';
import 'package:flutter_yd_weather/utils/log.dart';
import 'package:flutter_yd_weather/utils/theme_utils.dart';
import 'package:flutter_yd_weather/utils/weather_persistent_header_delegate.dart';
import 'package:flutter_yd_weather/widget/load_asset_image.dart';
import 'package:flutter_yd_weather/widget/opacity_layout.dart';
import 'package:flutter_yd_weather/widget/weather_city_selector.dart';
import 'package:flutter_yd_weather/widget/weather_header_widget.dart';
import 'package:flutter_yd_weather/widget/weather_main_clipper.dart';
import 'package:provider/provider.dart';
import 'package:sp_util/sp_util.dart';
import '../base/base_list_page.dart';
import '../config/constants.dart';
import '../model/weather_item_data.dart';
import '../res/colours.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';

import '../utils/color_utils.dart';
import '../utils/weather_main_painter.dart';

class WeatherMainPage extends StatefulWidget {
  const WeatherMainPage({super.key});

  @override
  State<WeatherMainPage> createState() => _WeatherMainPageState();
}

class _WeatherMainPageState
    extends BaseListPageState<WeatherMainPage, WeatherItemData, WeatherProvider>
    implements WeatherMainView {
  late WeatherMainPresenter _weatherMainPresenter;
  final _weatherHeaderKey = GlobalKey<WeatherHeaderWidgetState>();
  late StreamSubscription<RefreshWeatherDataEvent>
      _refreshWeatherDataEventSubscription;
  late StreamSubscription<SwitchWeatherCityEvent>
      _switchWeatherCityEventSubscription;
  final _cityManagerPageKey = GlobalKey<CityManagerPageState>();
  final _weatherCitySelectorKey = GlobalKey<WeatherCitySelectorState>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  SystemUiOverlayStyle _systemUiOverlayStyle = SystemUiOverlayStyle.light;
  bool _isShowCityManagerPage = false;
  Rect? _weatherContentRect;
  double _weatherContentOpacity = 1;
  late AnimationController _dailyWeatherAnimationController;
  Animation<double>? _dailyWeatherAnimation;

  @override
  void initState() {
    super.initState();
    setEnableRefresh(false);
    setEnableLoad(false);
    _refreshWeatherDataEventSubscription =
        eventBus.on<RefreshWeatherDataEvent>().listen((event) {
      _weatherMainPresenter.obtainWeatherData(
          delayMilliseconds: 200, isAdd: event.isAdd);
    });
    _switchWeatherCityEventSubscription =
        eventBus.on<SwitchWeatherCityEvent>().listen((event) {
      if (event.scrollToTopDelay > 0) {
        Commons.postDelayed(delayMilliseconds: event.scrollToTopDelay, () {
          scrollToTop();
        });
      } else {
        scrollToTop();
      }
      if (event.refreshWeatherData) {
        _weatherMainPresenter.obtainWeatherData(delayMilliseconds: 200);
      }
    });
    AppRuntimeData.instance.onWeatherBgChanged = () {
      provider.onWeatherBgChanged();
      _refreshStatusBar();
    };
    final mainP = context.read<MainProvider>();
    mainP.onWeatherCardSortChanged = (currentWeatherCardSort) {
      provider.reorder(currentWeatherCardSort);
    };
    mainP.onWeatherObservesCardSortChanged =
        (currentWeatherCardSort, currentWeatherObservesCardSort) {
      provider.reorderObserves(
          currentWeatherCardSort, currentWeatherObservesCardSort);
    };
    _animationController = AnimationController(vsync: this)
      ..duration = const Duration(milliseconds: 300)
      ..addStatusListener((status) {
        final cityId =
            context.read<MainProvider>().currentCityData?.cityId ?? "";
        if (status == AnimationStatus.completed) {
          _cityManagerPageKey.currentState?.show(cityId);
          setState(() {
            _systemUiOverlayStyle = context.isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark;
          });
        } else if (status == AnimationStatus.dismissed) {
          _cityManagerPageKey.currentState?.hide(cityId);
          _refreshStatusBar();
        }
      });
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _dailyWeatherAnimationController = AnimationController(vsync: this)
      ..duration = const Duration(milliseconds: 300);
  }

  @override
  void dispose() {
    super.dispose();
    AppRuntimeData.instance.dispose();
    _refreshWeatherDataEventSubscription.cancel();
    _switchWeatherCityEventSubscription.cancel();
    _animationController.dispose();
    _dailyWeatherAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: _systemUiOverlayStyle,
      child: PopScope(
        onPopInvokedWithResult: _onPopInvoked,
        canPop: false,
        child: Stack(
          children: [
            CityManagerPage(
              key: _cityManagerPageKey,
              hideCityManagerPage: _hideCityManagerPage,
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (_, __) {
                final animValue = _animation.value;
                final clipRectAnimValue = _isShowCityManagerPage
                    ? (animValue * 1.25).fixPercent()
                    : 1 - animValue;
                final clipper = WeatherMainClipper(
                  fromRect: _isShowCityManagerPage ? null : _weatherContentRect,
                  toRect: _isShowCityManagerPage ? _weatherContentRect : null,
                  animValue: clipRectAnimValue,
                  radius: 16.w * animValue,
                );
                final opacity = 1 - ((animValue - 0.8) / 0.2).fixPercent();
                final color1 =
                    provider.weatherBg?.colors.getOrNull(0) ?? Colours.white;
                final color2 =
                    provider.weatherBg?.colors.getOrNull(1) ?? Colours.white;
                final similarity1 =
                    ColorUtils.calSimilarity(context.backgroundColor, color1);
                final similarity2 =
                    ColorUtils.calSimilarity(context.backgroundColor, color2);
                return ClipPath(
                  clipper: clipper,
                  child: Offstage(
                    offstage: animValue >= 1,
                    child: AnimatedOpacity(
                      opacity: opacity,
                      duration: Duration.zero,
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            decoration: BoxDecoration(
                              gradient: provider.weatherBg,
                            ),
                          ),
                          Visibility(
                            visible: context.isDark,
                            child: Container(
                              decoration: BoxDecoration(
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
                          CustomPaint(
                            size: Size.infinite,
                            painter: similarity1 > 0.95 && similarity2 > 0.95
                                ? WeatherMainPainter(
                                    weatherMainClipper: clipper,
                                    borderWidth: 1.w * animValue,
                                    borderColor:
                                        context.black.withValues(alpha: animValue),
                                  )
                                : null,
                            child: super.build(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onPopInvoked(bool didPop, _) {
    if (didPop) return;
    if (_cityManagerPageKey.currentState?.isEditMode ?? false) {
      _cityManagerPageKey.currentState?.closeEditMode();
      return;
    }
    if (_animationController.isAnimating) return;
    if (_animation.value >= 1) {
      _hideCityManagerPage();
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget getRoot(WeatherProvider provider) {
    final animValue = _animation.value;
    final opacity = _isShowCityManagerPage
        ? ((0.2 - animValue) / 0.2).fixPercent()
        : 1 - ((animValue - 0.8) / 0.2).fixPercent();
    final weatherHeaderItemData = provider.list.singleOrNull(
        (element) => element.itemType == Constants.itemTypeWeatherHeader);
    final content = AnimatedOpacity(
      opacity: opacity,
      duration: Duration.zero,
      child: AnimatedOpacity(
        opacity: _weatherContentOpacity,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: ScreenUtil().statusBarHeight +
                    (weatherHeaderItemData?.minHeight ?? 0),
              ),
              child: Listener(
                onPointerUp: (_) {
                  _weatherHeaderKey.currentState?.onRelease();
                },
                child: super.getRoot(provider),
              ),
            ),
            WeatherHeaderWidget(
              key: _weatherHeaderKey,
              weatherItemData: weatherHeaderItemData,
              onRefresh: () {
                _weatherMainPresenter.obtainWeatherData(delayMilliseconds: 400);
              },
            ),
            Positioned(
              right: 0,
              top: ScreenUtil().statusBarHeight,
              child: OpacityLayout(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  margin: EdgeInsets.all(8.w),
                  child: LoadAssetImage(
                    "ic_add",
                    width: 20.w,
                    height: 20.w,
                    color: provider.isWeatherHeaderDark
                        ? Colours.white
                        : Colours.black,
                  ),
                ),
                onPressed: () {
                  _showCityManagerPage();
                },
              ),
            ),
          ],
        ),
      ),
    );
    return GestureDetector(
      onLongPress: _showWeatherCitySelector,
      child: content,
    );
  }

  void _showWeatherCitySelector() {
    HapticFeedback.lightImpact();
    SmartDialog.show(
      tag: "WeatherCitySelector",
      maskColor: Colours.transparent,
      animationTime: const Duration(milliseconds: 200),
      clickMaskDismiss: true,
      onDismiss: () {
        _weatherCitySelectorKey.currentState?.exit();
      },
      animationBuilder: (
        controller,
        child,
        animationParam,
      ) {
        return child;
      },
      builder: (_) {
        return WeatherCitySelector(
          key: _weatherCitySelectorKey,
          changeWeatherBgCallback: () {
            NavigatorUtils.push(
              context,
              AppRouter.weatherBgListPage,
              transition: TransitionType.inFromBottom,
            );
          },
        );
      },
    );
  }

  void _showCityManagerPage() {
    if (_animationController.isAnimating) return;
    final cityId = context.read<MainProvider>().currentCityData?.cityId ?? "";
    final positions = _cityManagerPageKey.currentState?.fixItemPosition(cityId);
    final itemPosition = positions?.getOrNull(1) ?? Offset.zero;
    _weatherContentRect = Rect.fromLTRB(16.w, itemPosition.dy,
        ScreenUtil().screenWidth - 16.w, itemPosition.dy + 98.w);
    _isShowCityManagerPage = true;
    _animationController
      ..duration = const Duration(milliseconds: 400)
      ..forward();
  }

  void _hideCityManagerPage() {
    if (_animationController.isAnimating) return;
    final cityId = context.read<MainProvider>().currentCityData?.cityId ?? "";
    final positions = _cityManagerPageKey.currentState
        ?.fixItemPosition(cityId, jumpTo: false);
    final itemPosition = positions?.getOrNull(1) ?? Offset.zero;
    _weatherContentRect = Rect.fromLTRB(16.w, itemPosition.dy,
        ScreenUtil().screenWidth - 16.w, itemPosition.dy + 98.w);
    _isShowCityManagerPage = false;
    _animationController
      ..reverseDuration = const Duration(milliseconds: 300)
      ..reverse();
  }

  @override
  WeatherProvider get baseProvider => provider;

  @override
  void setScrollController(ScrollController? scrollController) {
    super.setScrollController(scrollController);
    scrollController?.addListener(() {
      final offset = scrollController.offset;
      final weatherHeaderItemData = provider.list.singleOrNull(
          (element) => element.itemType == Constants.itemTypeWeatherHeader);
      final percent = offset /
          ((weatherHeaderItemData?.maxHeight ?? 0) -
              (weatherHeaderItemData?.minHeight ?? 0));
      _weatherHeaderKey.currentState?.change(offset, percent);
    });
  }

  @override
  List<Widget> getRefreshGroup(WeatherProvider provider) {
    final refreshGroup = <Widget>[];
    for (var weatherItemData in provider.list) {
      if (weatherItemData.itemType == Constants.itemTypeWeatherHeader) continue;
      Widget buildSliverPersistentHeader({double? maxPanelExtent}) {
        return SliverPersistentHeader(
          pinned: true,
          delegate: WeatherPersistentHeaderDelegate(
            weatherItemData,
            weatherItemData.itemType == Constants.itemTypeAlarms ||
                    weatherItemData.itemType == Constants.itemTypeAirQuality ||
                    weatherItemData.itemType ==
                        Constants.itemTypeDailyWeather ||
                    weatherItemData.itemType == Constants.itemTypeObserve
                ? (show) {
                    setState(() {
                      _weatherContentOpacity = show ? 1 : 0;
                    });
                  }
                : null,
            maxPanelExtent,
            weatherItemData.itemType == Constants.itemTypeDailyWeather
                ? SpUtil.getString(Constants.currentDailyWeatherType,
                        defValue: Constants.listDailyWeather) ??
                    Constants.listDailyWeather
                : null,
            weatherItemData.itemType == Constants.itemTypeDailyWeather
                ? _changeLineChartDailyWeather
                : null,
            weatherItemData.itemType == Constants.itemTypeDailyWeather
                ? _changeListDailyWeather
                : null,
            weatherItemData.itemType == Constants.itemTypeDailyWeather
                ? _lookMore
                : null,
            weatherItemData.itemType == Constants.itemTypeDailyWeather
                ? AppRuntimeData.instance.isDailyWeatherExpand
                : null,
          ),
        );
      }

      refreshGroup.add(SliverMainAxisGroup(
        slivers: [
          weatherItemData.itemType == Constants.itemTypeDailyWeather
              ? AnimatedBuilder(
                  animation: _dailyWeatherAnimationController,
                  builder: (_, __) {
                    final maxPanelExtent = _dailyWeatherAnimation?.value ??
                        weatherItemData.maxHeight;
                    return buildSliverPersistentHeader(
                      maxPanelExtent: maxPanelExtent,
                    );
                  },
                )
              : buildSliverPersistentHeader(),
          SliverToBoxAdapter(
            child: Gaps.generateGap(height: 12.w),
          ),
        ],
      ));
    }
    return refreshGroup;
  }

  void _changeLineChartDailyWeather() {
    final currentDailyWeatherType = SpUtil.getString(
            Constants.currentDailyWeatherType,
            defValue: Constants.listDailyWeather) ??
        Constants.listDailyWeather;
    if (currentDailyWeatherType == Constants.lineChartDailyWeather) {
      return;
    }
    SpUtil.putString(
        Constants.currentDailyWeatherType, Constants.lineChartDailyWeather);
    AppRuntimeData.instance.currentDailyWeatherType =
        Constants.lineChartDailyWeather;
    final dailyWeatherItemData = provider.list
        .singleOrNull((e) => e.itemType == Constants.itemTypeDailyWeather);
    if (dailyWeatherItemData != null) {
      final isCompleted = _dailyWeatherAnimationController.isCompleted;
      if (isCompleted) {
        _dailyWeatherAnimation = Tween<double>(
                begin: min(
                    dailyWeatherItemData.maxHeight,
                    dailyWeatherItemData.animMaxHeight ??
                        dailyWeatherItemData.maxHeight),
                end: max(
                    dailyWeatherItemData.maxHeight,
                    dailyWeatherItemData.animMaxHeight ??
                        dailyWeatherItemData.maxHeight))
            .animate(_dailyWeatherAnimationController);
        _dailyWeatherAnimationController.reverse();
      } else {
        _dailyWeatherAnimation = Tween<double>(
                begin: max(
                    dailyWeatherItemData.maxHeight,
                    dailyWeatherItemData.animMaxHeight ??
                        dailyWeatherItemData.maxHeight),
                end: min(
                    dailyWeatherItemData.maxHeight,
                    dailyWeatherItemData.animMaxHeight ??
                        dailyWeatherItemData.maxHeight))
            .animate(_dailyWeatherAnimationController);
        _dailyWeatherAnimationController.forward();
      }
    }
  }

  void _changeListDailyWeather() {
    final currentDailyWeatherType = SpUtil.getString(
            Constants.currentDailyWeatherType,
            defValue: Constants.listDailyWeather) ??
        Constants.listDailyWeather;
    if (currentDailyWeatherType == Constants.listDailyWeather) {
      return;
    }
    AppRuntimeData.instance.isDailyWeatherExpand = false;
    SpUtil.putString(
        Constants.currentDailyWeatherType, Constants.listDailyWeather);
    AppRuntimeData.instance.currentDailyWeatherType =
        Constants.listDailyWeather;
    final dailyWeatherItemData = provider.list
        .singleOrNull((e) => e.itemType == Constants.itemTypeDailyWeather);
    if (dailyWeatherItemData != null) {
      final isCompleted = _dailyWeatherAnimationController.isCompleted;
      if (isCompleted) {
        _dailyWeatherAnimation = Tween<double>(
                begin: max(
                    dailyWeatherItemData.maxHeight,
                    dailyWeatherItemData.animMaxHeight ??
                        dailyWeatherItemData.maxHeight),
                end: min(
                    dailyWeatherItemData.maxHeight,
                    dailyWeatherItemData.animMaxHeight ??
                        dailyWeatherItemData.maxHeight))
            .animate(_dailyWeatherAnimationController);
        _dailyWeatherAnimationController.reverse();
      } else {
        _dailyWeatherAnimation = Tween<double>(
                begin: min(
                    dailyWeatherItemData.maxHeight,
                    dailyWeatherItemData.animMaxHeight ??
                        dailyWeatherItemData.maxHeight),
                end: max(
                    dailyWeatherItemData.maxHeight,
                    dailyWeatherItemData.animMaxHeight ??
                        dailyWeatherItemData.maxHeight))
            .animate(_dailyWeatherAnimationController);
        _dailyWeatherAnimationController.forward();
      }
    }
  }

  void _lookMore() {
    final dailyWeatherItemData = provider.list
        .singleOrNull((e) => e.itemType == Constants.itemTypeDailyWeather);
    if (dailyWeatherItemData != null) {
      final listDailyWeatherHeight1 = Constants.itemStickyHeight.w +
          Constants.dailyWeatherItemHeight.w *
              min(
                  Constants.dailyWeatherItemCount,
                  dailyWeatherItemData.weatherData?.forecast15?.length ??
                      Constants.dailyWeatherItemCount) +
          Constants.dailyWeatherBottomHeight.w;
      final listDailyWeatherHeight2 = Constants.itemStickyHeight.w +
          Constants.dailyWeatherItemHeight.w *
              max(
                  Constants.dailyWeatherItemCount,
                  dailyWeatherItemData.weatherData?.forecast15?.length ??
                      Constants.dailyWeatherItemCount) +
          Constants.dailyWeatherBottomHeight.w;
      final isDailyWeatherExpand = AppRuntimeData.instance.isDailyWeatherExpand;
      final isCompleted = _dailyWeatherAnimationController.isCompleted;
      if (isDailyWeatherExpand) {
        AppRuntimeData.instance.isDailyWeatherExpand = false;
        if (isCompleted) {
          _dailyWeatherAnimation = Tween<double>(
                  begin: listDailyWeatherHeight1, end: listDailyWeatherHeight2)
              .animate(_dailyWeatherAnimationController);
          _dailyWeatherAnimationController.reverse();
        } else {
          _dailyWeatherAnimation = Tween<double>(
                  begin: listDailyWeatherHeight2, end: listDailyWeatherHeight1)
              .animate(_dailyWeatherAnimationController);
          _dailyWeatherAnimationController.forward();
        }
      } else {
        AppRuntimeData.instance.isDailyWeatherExpand = true;
        if (isCompleted) {
          _dailyWeatherAnimation = Tween<double>(
                  begin: listDailyWeatherHeight2, end: listDailyWeatherHeight1)
              .animate(_dailyWeatherAnimationController);
          _dailyWeatherAnimationController.reverse();
        } else {
          _dailyWeatherAnimation = Tween<double>(
                  begin: listDailyWeatherHeight1, end: listDailyWeatherHeight2)
              .animate(_dailyWeatherAnimationController);
          _dailyWeatherAnimationController.forward();
        }
      }
    }
  }

  @override
  double getAnchor(WeatherProvider provider, double contentHeight) {
    if (!mounted) return 0.0;
    if (contentHeight <= 0) return 0.0;
    final weatherHeaderItemData = provider.list.singleOrNull(
        (element) => element.itemType == Constants.itemTypeWeatherHeader);
    final anchor = ((weatherHeaderItemData?.maxHeight ?? 0) -
            (weatherHeaderItemData?.minHeight ?? 0)) /
        contentHeight;
    Log.e("anchor = $anchor contentHeight = $contentHeight");
    return anchor.fixPercent();
  }

  @override
  Widget buildItem(BuildContext context, int index, WeatherProvider provider) {
    return Gaps.empty;
  }

  @override
  Widget? getFooter(WeatherProvider provider) {
    final isDark = provider.isDark;
    final source = provider.list.firstOrNull()?.weatherData?.source?.title;
    return source.isNullOrEmpty()
        ? null
        : SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 12.w),
              child: Column(
                children: [
                  Text(
                    "天气信息来自$source",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: (isDark ? Colours.white : Colours.black)
                          .withValues(alpha: 0.4),
                      height: 1,
                    ),
                  ),
                  Gaps.generateGap(height: 12.w),
                  OpacityLayout(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.w),
                        border: Border.all(
                          width: 0.5.w,
                          color: (isDark ? Colours.white : Colours.black)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LoadAssetImage(
                            "ic_sort_icon",
                            width: 18.w,
                            height: 18.w,
                            color: (isDark ? Colours.white : Colours.black)
                                .withValues(alpha: 0.5),
                          ),
                          Gaps.generateGap(width: 4.w),
                          Text(
                            "卡片排序",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: (isDark ? Colours.white : Colours.black)
                                  .withValues(alpha: 0.5),
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      NavigatorUtils.push(
                        context,
                        AppRouter.weatherCardSortPage,
                        transition: TransitionType.inFromBottom,
                      );
                    },
                  ),
                  Visibility(
                    visible: Device.isIOS,
                    child: Gaps.generateGap(
                      height: ScreenUtil().bottomBarHeight,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  @override
  PowerPresenter createPresenter() {
    final PowerPresenter<dynamic> powerPresenter =
        PowerPresenter<dynamic>(this);
    _weatherMainPresenter = WeatherMainPresenter();
    powerPresenter.requestPresenter([_weatherMainPresenter]);
    return powerPresenter;
  }

  @override
  WeatherProvider generateProvider() {
    final mainP = context.read<MainProvider>();
    return WeatherProvider()
      ..generateWeatherBg(
        null,
        cacheWeatherType: mainP.currentCityData?.weatherData?.weatherType,
        cacheSunrise: mainP.currentCityData?.weatherData?.sunrise,
        cacheSunset: mainP.currentCityData?.weatherData?.sunset,
      );
  }

  void _refreshStatusBar() {
    setState(() {
      _systemUiOverlayStyle = provider.isWeatherHeaderDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark;
    });
  }

  @override
  void beforeObtainWeatherData() {
    AppRuntimeData.instance.isDailyWeatherExpand = false;
    _dailyWeatherAnimation = null;
  }

  @override
  void obtainWeatherDataCallback(bool isAdd, reObtainWeatherData) {
    _weatherHeaderKey.currentState?.refreshComplete();
    _cityManagerPageKey.currentState?.refresh(isAdd);
    if (!_isShowCityManagerPage) {
      _refreshStatusBar();
    }
  }
}
