import 'package:flutter_yd_weather/model/weather_info_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_observe_data.g.dart';

@JsonSerializable()
class WeatherObserveData {
  WeatherInfoData? day;
  WeatherInfoData? night;
  int? type;
  @JsonKey(name: "third_type")
  String? weatherType;
  int? temp;
  @JsonKey(name: "tigan")
  String? tiGan;
  String? wthr;
  String? wd;
  String? wp;
  @JsonKey(name: "shidu")
  String? shiDu;
  @JsonKey(name: "uv_index")
  int? uvIndex;
  @JsonKey(name: "uv_index_max")
  int? uvIndexMax;
  @JsonKey(name: "uv_level")
  String? uvLevel;
  String? pressure;
  String? visibility;

  WeatherObserveData(
    this.day,
    this.night,
    this.type,
    this.weatherType,
    this.temp,
    this.tiGan,
    this.wthr,
    this.wd,
    this.wp,
    this.shiDu,
    this.uvIndex,
    this.uvIndexMax,
    this.uvLevel,
    this.pressure,
    this.visibility,
  );

  factory WeatherObserveData.fromJson(Map<String, dynamic> json) =>
      _$WeatherObserveDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherObserveDataToJson(this);
}
