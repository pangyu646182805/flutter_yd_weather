import 'dart:async';
import 'package:common_utils/common_utils.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/main.dart';
import 'package:flutter_yd_weather/mvp/power_presenter.dart';
import 'package:flutter_yd_weather/pages/city_manager_page.dart';
import 'package:flutter_yd_weather/pages/presenter/weather_main_presenter.dart';
import 'package:flutter_yd_weather/pages/provider/weather_provider.dart';
import 'package:flutter_yd_weather/pages/view/weather_main_view.dart';
import 'package:flutter_yd_weather/provider/main_provider.dart';
import 'package:flutter_yd_weather/res/gaps.dart';
import 'package:flutter_yd_weather/utils/commons.dart';
import 'package:flutter_yd_weather/utils/log.dart';
import 'package:flutter_yd_weather/utils/weather_persistent_header_delegate.dart';
import 'package:flutter_yd_weather/widget/load_asset_image.dart';
import 'package:flutter_yd_weather/widget/opacity_layout.dart';
import 'package:flutter_yd_weather/widget/weather_header_widget.dart';
import 'package:provider/provider.dart';
import '../base/base_list_page.dart';
import '../config/constants.dart';
import '../model/weather_item_data.dart';
import '../res/colours.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';

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
  final _cityManagerPageKey = GlobalKey<CityManagerPageState>();
  double _weatherContentOpacity = 1;
  double _weatherContainerOpacity = 1;
  bool _weatherContainerOffstage = false;
  Rect _weatherContentRect = Rect.zero;
  Duration _weatherContentPositionedDuration =
      const Duration(milliseconds: 300);
  BorderRadius _weatherContentBorderRadius = BorderRadius.zero;
  double _weatherContentMargin = 0;
  SystemUiOverlayStyle _systemUiOverlayStyle = SystemUiOverlayStyle.light;

  @override
  void initState() {
    super.initState();
    setEnableRefresh(false);
    setEnableLoad(false);
    _refreshWeatherDataEventSubscription =
        eventBus.on<RefreshWeatherDataEvent>().listen((event) {
      _weatherMainPresenter.obtainWeatherData(delayMilliseconds: 200);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _refreshWeatherDataEventSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: _systemUiOverlayStyle,
      child: PopScope(
        onPopInvoked: _onPopInvoked,
        canPop: false,
        child: Stack(
          children: [
            CityManagerPage(
              key: _cityManagerPageKey,
              hideCityManagerPage: _hideCityManagerPage,
            ),
            AnimatedPositioned(
              left: _weatherContentRect.left,
              top: _weatherContentRect.top,
              right: _weatherContentRect.right,
              bottom: _weatherContentRect.bottom,
              duration: _weatherContentPositionedDuration,
              curve: Curves.decelerate,
              child: super.build(context),
            ),
          ],
        ),
      ),
    );
  }

  void _onPopInvoked(bool didPop) {
    if (didPop) return;
    if (_weatherContentOpacity <= 0) {
      _hideCityManagerPage();
      return;
    }

    /// 不推荐使用 `dart:io` 的 exit(0)
    SystemNavigator.pop();
  }

  @override
  Widget getRoot(WeatherProvider provider) {
    final weatherHeaderItemData = provider.list.singleOrNull(
        (element) => element.itemType == Constants.itemTypeWeatherHeader);
    final weatherData = weatherHeaderItemData?.weatherData;
    final isNight = Commons.isNight(DateTime.now());
    String? weatherBg = isNight
        ? weatherData?.observe?.night?.bgPic
        : weatherData?.observe?.day?.bgPic;
    if (weatherBg.isNullOrEmpty()) {
      final currentWeatherDetailData = weatherData?.forecast15?.singleOrNull(
        (element) =>
            element.date ==
            DateUtil.formatDate(DateTime.now(), format: Constants.yyyymmdd),
      );
      weatherBg = isNight
          ? currentWeatherDetailData?.night?.bgPic
          : currentWeatherDetailData?.day?.bgPic;
    }
    return AnimatedOpacity(
      opacity: _weatherContainerOpacity,
      duration: const Duration(milliseconds: 100),
      child: Offstage(
        offstage: _weatherContainerOffstage,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: _weatherContentMargin),
              decoration: BoxDecoration(
                borderRadius: _weatherContentBorderRadius,
              ),
              clipBehavior: Clip.hardEdge,
              child: ExtendedImage.network(
                weatherBg ?? "",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                loadStateChanged:
                    Commons.loadStateChanged(placeholder: Colours.transparent),
              ),
            ),
            AnimatedOpacity(
              opacity: _weatherContentOpacity,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                children: [
                  WeatherHeaderWidget(
                    key: _weatherHeaderKey,
                    weatherItemData: weatherHeaderItemData,
                    onRefresh: () {
                      _weatherMainPresenter.obtainWeatherData(
                          delayMilliseconds: 400);
                    },
                  ),
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
          ],
        ),
      ),
    );
  }

  void _showCityManagerPage() {
    final cityId = context.read<MainProvider>().currentCityData?.cityId ?? "";
    final positions = _cityManagerPageKey.currentState?.fixItemPosition(cityId);
    final contentPosition = positions?.getOrNull(0) ?? Offset.zero;
    final itemPosition = positions?.getOrNull(1) ?? Offset.zero;
    setState(() {
      _weatherContentOpacity = 0;
      _weatherContentBorderRadius = BorderRadius.circular(16.w);
      _weatherContentRect = Rect.fromLTRB(
          0, itemPosition.dy, 0, contentPosition.dy - (itemPosition.dy + 98.w));
      _weatherContentMargin = 16.w;
      _systemUiOverlayStyle = SystemUiOverlayStyle.dark;
      Commons.postDelayed(delayMilliseconds: 300, () {
        setState(() {
          _weatherContainerOpacity = 0;
          _cityManagerPageKey.currentState?.show(cityId);
          Commons.postDelayed(delayMilliseconds: 100, () {
            setState(() {
              _weatherContainerOffstage = true;
            });
          });
        });
      });
    });
  }

  void _hideCityManagerPage() {
    final cityId = context.read<MainProvider>().currentCityData?.cityId ?? "";
    final positions = _cityManagerPageKey.currentState
        ?.fixItemPosition(cityId, jumpTo: false);
    final contentPosition = positions?.getOrNull(0) ?? Offset.zero;
    final itemPosition = positions?.getOrNull(1) ?? Offset.zero;
    setState(() {
      _weatherContentPositionedDuration = Duration.zero;
      _weatherContentRect = Rect.fromLTRB(
          0, itemPosition.dy, 0, contentPosition.dy - (itemPosition.dy + 98.w));
      _weatherContainerOpacity = 1;
      _weatherContainerOffstage = false;
      Commons.postDelayed(delayMilliseconds: 100, () {
        setState(() {
          _weatherContentOpacity = 1;
          _weatherContentBorderRadius = BorderRadius.zero;
          _weatherContentMargin = 0;
          _weatherContentPositionedDuration = const Duration(milliseconds: 300);
          _weatherContentRect = Rect.zero;
          _systemUiOverlayStyle = SystemUiOverlayStyle.light;
          Commons.postDelayed(delayMilliseconds: 300, () {
            _cityManagerPageKey.currentState?.hide(cityId);
          });
        });
      });
    });
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
      refreshGroup.add(SliverMainAxisGroup(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: WeatherPersistentHeaderDelegate(
              weatherItemData,
            ),
          ),
          SliverToBoxAdapter(
            child: Gaps.generateGap(height: 12.w),
          ),
        ],
      ));
    }
    return refreshGroup;
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
    final source = provider.list.firstOrNull()?.weatherData?.source?.title;
    return source.isNullOrEmpty()
        ? null
        : SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 12.w),
              child: Text(
                "天气信息来自$source",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colours.white.withOpacity(0.4),
                ),
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
  WeatherProvider generateProvider() => WeatherProvider();

  @override
  void obtainWeatherDataCallback() {
    _weatherHeaderKey.currentState?.refreshComplete();
  }
}
