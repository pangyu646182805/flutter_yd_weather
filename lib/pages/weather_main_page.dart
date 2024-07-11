import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/mvp/power_presenter.dart';
import 'package:flutter_yd_weather/pages/presenter/weather_main_presenter.dart';
import 'package:flutter_yd_weather/pages/provider/weather_provider.dart';
import 'package:flutter_yd_weather/res/gaps.dart';
import 'package:flutter_yd_weather/utils/log.dart';
import 'package:flutter_yd_weather/utils/weather_persistent_header_delegate.dart';
import 'package:flutter_yd_weather/widget/weather_header_widget.dart';
import 'package:provider/provider.dart';
import '../base/base_list_page.dart';
import '../base/base_list_view.dart';
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
    implements BaseListView<WeatherItemData> {
  late WeatherMainPresenter _weatherMainPresenter;
  final _weatherHeaderKey = GlobalKey<WeatherHeaderWidgetState>();

  @override
  void initState() {
    super.initState();
    setEnableRefresh(false);
    setEnableLoad(false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colours.color1B81A7,
            Colours.color2FA6BA,
            Colours.color6DC1C1,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ChangeNotifierProvider<WeatherProvider>(
        create: (_) => provider,
        child: Consumer<WeatherProvider>(builder: (_, p, __) {
          final weatherHeaderItemData = p.list.singleOrNull(
              (element) => element.itemType == Constants.itemTypeWeatherHeader);
          return Stack(
            children: [
              WeatherHeaderWidget(
                key: _weatherHeaderKey,
                weatherItemData: weatherHeaderItemData,
              ),
              Column(
                children: [
                  Gaps.generateGap(height: ScreenUtil().statusBarHeight),
                  Gaps.generateGap(height: weatherHeaderItemData?.minHeight),
                  Expanded(
                    child: super.build(context),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  WeatherProvider get baseProvider => provider;

  @override
  void setScrollController(ScrollController? scrollController) {
    super.setScrollController(scrollController);
    scrollController?.addListener(() {
      final offset = scrollController.offset;
      final weatherHeaderItemData = provider.list.singleOrNull((element) => element.itemType == Constants.itemTypeWeatherHeader);
      final percent = offset / ((weatherHeaderItemData?.maxHeight ?? 0) - (weatherHeaderItemData?.minHeight ?? 0));
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
        ],
      ));
    }
    return refreshGroup;
  }

  @override
  double getAnchor(WeatherProvider provider, double contentHeight) {
    if (!mounted) return 0.0;
    final weatherHeaderItemData = provider.list.singleOrNull((element) => element.itemType == Constants.itemTypeWeatherHeader);
    final anchor = ((weatherHeaderItemData?.maxHeight ?? 0) - (weatherHeaderItemData?.minHeight ?? 0))  / contentHeight;
    Log.e("anchor = $anchor");
    return anchor;
  }

  @override
  Widget buildItem(BuildContext context, int index, WeatherProvider provider) {
    return Gaps.empty;
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
  WeatherProvider generateProvider() => WeatherProvider()..setWeatherData(null);
}
