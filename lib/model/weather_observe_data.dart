import 'package:flutter_yd_weather/model/weather_info_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_observe_data.g.dart';

@JsonSerializable()
class WeatherObserveData {
  WeatherInfoData? day;
  WeatherInfoData? night;
  int? type;
  int? temp;
  @JsonKey(name: "tigan")
  String? tiGan;
  @JsonKey(name: "up_time")
  String? upTime;
  String? wthr;
  String? wd;
  String? wp;
  @JsonKey(name: "shidu")
  String? shiDu;

  WeatherObserveData(
    this.day,
    this.night,
    this.type,
    this.temp,
    this.tiGan,
    this.upTime,
    this.wthr,
    this.wd,
    this.wp,
    this.shiDu,
  );

  factory WeatherObserveData.fromJson(Map<String, dynamic> json) =>
      _$WeatherObserveDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherObserveDataToJson(this);
}
