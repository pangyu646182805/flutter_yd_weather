import 'package:common_utils/common_utils.dart';
import 'package:flutter_yd_weather/model/weather_data.dart';
import 'package:flutter_yd_weather/utils/commons_ext.dart';
import 'package:hive/hive.dart';
import '../config/constants.dart';

part 'simple_weather_data.g.dart';

@HiveType(typeId: Constants.simpleWeatherDataTypeId)
class SimpleWeatherData {
  @HiveField(0)
  String? city;
  @HiveField(1)
  int? temp;
  @HiveField(2)
  int? tempHigh;
  @HiveField(3)
  int? tempLow;
  @HiveField(4)
  String? weatherType;
  @HiveField(5)
  String? weatherDesc;
  @HiveField(6)
  String? sunrise;
  @HiveField(7)
  String? sunset;

  SimpleWeatherData(
    this.city,
    this.temp,
    this.tempHigh,
    this.tempLow,
    this.weatherType,
    this.weatherDesc,
    this.sunrise,
    this.sunset,
  );

  SimpleWeatherData.fromWeatherData(WeatherData? weatherData) {
    city = weatherData?.meta?.city;
    temp = weatherData?.observe?.temp;
    final currentWeatherDetailData = weatherData?.forecast15?.singleOrNull(
      (element) =>
          element.date ==
          DateUtil.formatDate(DateTime.now(), format: Constants.yyyymmdd),
    );
    tempHigh = currentWeatherDetailData?.high;
    tempLow = currentWeatherDetailData?.low;
    weatherType = weatherData?.observe?.weatherType ?? currentWeatherDetailData?.weatherType;
    weatherDesc = weatherData?.observe?.wthr ?? currentWeatherDetailData?.wthr;
    sunrise = currentWeatherDetailData?.sunrise;
    sunset = currentWeatherDetailData?.sunset;
  }
}
