import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_yd_weather/utils/theme_utils.dart';

class Colours {
  static const Color appMain = color02C96F;
  static const Color darkAppMain = color00AC5E;
  static const Color bgColor = white;
  static const Color darkBgColor = Color(0xFF18191A);
  static const Color darkMaterialBg = Color(0xFF303233);
  static const Color line = colorEEEEEE;
  static const Color darkLine = color1D2129;

  static const Color black = Color(0xff000000);
  static const Color black_2 = Color(0x22000000);
  static const Color black_3 = Color(0x33000000);
  static const Color black_6 = Color(0x66000000);
  static const Color black_9 = Color(0x99000000);

  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xffffffff);
  static const Color white_3 = Color(0x33ffffff);
  static const Color white_6 = Color(0x66ffffff);
  static const Color white_9 = Color(0x99ffffff);

  static const Color color1C1C28 = Color(0xff1C1C28);
  static const Color color999999 = Color(0xff999999);
  static const Color color666666 = Color(0xff666666);
  static const Color color333333 = Color(0xff333333);
  static const Color color444444 = Color(0xff444444);
  static const Color colorCCCCCC = Color(0xffcccccc);
  static const Color colorFF8A00 = Color(0xFFFF8A00);
  static const Color colorFE2C3C = Color(0xFFFE2C3C);
  static const Color color80FE2C3C = Color(0x80FE2C3C);
  static const Color colorEBEBEB = Color(0xFFEBEBEB);
  static const Color colorF0F0F0 = Color(0xFFF0F0F0);
  static const Color colorFFDD00 = Color(0xFFFFDD00);
  static const Color colorAAAAAA = Color(0xFFAAAAAA);
  static const Color colorD1D1D1 = Color(0xFFD1D1D1);
  static const Color colorFFB359 = Color(0xFFFFB359);
  static const Color colorF5F5F5 = Color(0xFFF5F5F5);
  static const Color colorF6F6F6 = Color(0xFFF6F6F6);
  static const Color color17606060 = Color(0x17606060);
  static const Color colorFFF1B8 = Color(0xFFFFF1B8);
  static const Color colorF8F8F8 = Color(0xFFF8F8F8);
  static const Color colorFFFAD7 = Color(0xFFFFFAD7);
  static const Color colorFF9900 = Color(0xFFFF9900);
  static const Color color14000000 = Color(0x14000000);
  static const Color color80CECECE = Color(0x80CECECE);
  static const Color color808080 = Color(0xFF808080);
  static const Color colorE5E5E5 = Color(0xFFE5E5E5);
  static const Color colorEEEEEE = Color(0xFFEEEEEE);
  static const Color color1D2129 = Color(0xFF1D2129);
  static const Color colorC5C5C5 = Color(0xFFC5C5C5);
  static const Color color8AFFFFFF = Color(0x8AFFFFFF);
  static const Color colorFFD178 = Color(0xFFFFD178);
  static const Color colorFFFCEB = Color(0xFFFFFCEB);
  static const Color colorEAEAEA = Color(0xFFEAEAEA);
  static const Color colorFCFCFC = Color(0xFFFCFCFC);
  static const Color colorB5E7E7E7 = Color(0xB5E7E7E7);
  static const Color color777777 = Color(0xFF777777);
  static const Color colorFF8383 = Color(0xFFFF8383);
  static const Color colorD8D8D8 = Color(0xFFD8D8D8);
  static const Color colorF3F4F6 = Color(0xFFF3F4F6);
  static const Color colorFF7B82 = Color(0xFFFF7B82);
  static const Color color2B9E9E9E = Color(0x2B9E9E9E);
  static const Color colorD6D6D6 = Color(0xFFD6D6D6);
  static const Color color0A000000 = Color(0x0A000000);
  static const Color color17000000 = Color(0x17000000);
  static const Color colorFBFBFB = Color(0xFFFBFBFB);
  static const Color colorFFBAAB = Color(0xFFFFBAAB);
  static const Color colorFF916F = Color(0xFFFF916F);
  static const Color colorF7F7F7 = Color(0xFFF7F7F7);
  static const Color colorD5D5D5 = Color(0xFFD5D5D5);
  static const Color color00AC5E = Color(0xFF00AC5E);
  static const Color colorFF432A = Color(0xFFFF432A);
  static const Color color02C96F = Color(0xFF02C96F);
  static const Color colorE64A41 = Color(0xFFE64A41);
  static const Color colorFF6B77 = Color(0xFFFF6B77);
  static const Color colorFFA0A8 = Color(0xFFFFA0A8);
  static const Color colorFFFCF8 = Color(0xFFFFFCF8);
  static const Color colorFFF1F2 = Color(0xFFFFF1F2);
  static const Color colorFFACB2 = Color(0xFFFFACB2);
  static const Color colorE3E3E3 = Color(0xFFE3E3E3);
  static const Color color0E1014 = Color(0xFF0E1014);
  static const Color color9696A6 = Color(0xFF9696A6);
  static const Color color14171F = Color(0xFF14171F);
  static const Color colorE6E6E6 = Color(0xFFE6E6E6);
  static const Color color2C2C42 = Color(0xFF2C2C42);
  static const Color colorF3F4F9 = Color(0xFFF3F4F9);
  static const Color color2A2A3D = Color(0xFF2A2A3D);
}

extension ColoursExtension on BuildContext {
  Color get appMain => isDark ? Colours.darkAppMain : Colours.appMain;
  Color get textColor01 => isDark ? Colours.color9696A6 : Colours.color333333;

  Color get cardColor01 => isDark ? Colours.color0E1014 : Colours.colorF6F6F6;
  Color get cardColor02 => isDark ? Colours.color1D2129 : Colours.colorF6F6F6;
  Color get cardColor03 => isDark ? Colours.color14171F : Colours.white;
  Color get cardColor04 => isDark ? Colours.color333333 : Colours.colorF8F8F8;
  Color get cardColor05 => isDark ? Colours.color2C2C42 : Colours.colorE6E6E6;
  Color get cardColor06 => isDark ? Colours.color2A2A3D : Colours.colorF3F4F9;
}
