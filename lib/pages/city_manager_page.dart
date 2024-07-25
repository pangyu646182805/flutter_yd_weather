import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_yd_weather/base/base_list_view.dart';
import 'package:flutter_yd_weather/model/city_data.dart';
import 'package:flutter_yd_weather/mvp/power_presenter.dart';
import 'package:flutter_yd_weather/pages/provider/city_manager_provider.dart';
import 'package:flutter_yd_weather/provider/main_provider.dart';
import 'package:flutter_yd_weather/routers/app_router.dart';
import 'package:flutter_yd_weather/routers/fluro_navigator.dart';
import 'package:flutter_yd_weather/utils/commons.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:flutter_yd_weather/utils/theme_utils.dart';
import 'package:flutter_yd_weather/widget/city_manager_item.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../base/base_list_page.dart';
import '../res/colours.dart';
import '../res/gaps.dart';
import '../widget/my_app_bar.dart';

class CityManagerPage extends StatefulWidget {
  const CityManagerPage({super.key});

  @override
  State<CityManagerPage> createState() => _CityManagerPageState();
}

class _CityManagerPageState
    extends BaseListPageState<CityManagerPage, CityData, CityManagerProvider>
    implements BaseListView<CityData> {
  @override
  NotRefreshHeader? get notRefreshHeader => const NotRefreshHeader(
        position: IndicatorPosition.locator,
        hitOver: true,
      );

  @override
  void initState() {
    super.initState();
    setEnableRefresh(false);
    setEnableLoad(false);
    Commons.post((_) {
      provider.largeTitleColor = context.textColor01;
      provider.hideLoading();
    });
  }

  @override
  void setScrollController(ScrollController? scrollController) {
    super.setScrollController(scrollController);
    scrollController?.addListener(() {
      final percent = (scrollController.offset / 108.w).fixPercent();
      provider.changeAlpha(context, percent);
    });
  }

  @override
  Widget getRoot(CityManagerProvider provider) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: MyAppBar(
        centerTitle: "城市管理",
        titleColor: provider.titleColor,
        backgroundColor: context.backgroundColor,
        rightIcon1: "ic_search_home",
        onRightIcon1Pressed: () {
          NavigatorUtils.push(context, AppRouter.selectCityPage);
        },
      ),
      body: super.getRoot(provider),
    );
  }

  @override
  Widget getRefreshContent(CityManagerProvider provider) {
    final mainP = context.read<MainProvider>();
    return ValueListenableBuilder(
      valueListenable: mainP.cityDataBox.listenable(),
      builder: (context, cityDataBox, child) {
        return SliverList.separated(
          itemBuilder: (context, index) {
            return buildItem(context, index, provider);
          },
          separatorBuilder: (context, index) {
            return buildItemDecoration(context, index);
          },
          itemCount: cityDataBox.length,
        );
      },
    );
  }

  @override
  Widget getHeader(CityManagerProvider provider) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 72.w,
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(left: 20.w, top: 12.w),
            child: Text(
              "城市管理",
              style: TextStyle(
                fontSize: 28.sp,
                color: provider.largeTitleColor,
              ),
            ),
          ),
        ),
        const HeaderLocator.sliver(),
      ],
    );
  }

  @override
  Widget buildItem(
      BuildContext context, int index, CityManagerProvider provider) {
    return CityManagerItem(
      index: index,
    );
  }

  @override
  Widget buildItemDecoration(context, index) {
    return Gaps.generateGap(height: 12.w);
  }

  @override
  Widget getFooter(CityManagerProvider provider) {
    return SliverToBoxAdapter(
      child: Gaps.generateGap(height: 12.w),
    );
  }

  @override
  CityManagerProvider get baseProvider => provider;

  @override
  PowerPresenter createPresenter() {
    return PowerPresenter<dynamic>(this);
  }

  @override
  CityManagerProvider generateProvider() => CityManagerProvider();
}
