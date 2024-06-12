import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_yd_weather/utils/theme_utils.dart';

extension StringExt on String? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;

  bool isNotNullOrEmpty() => !isNullOrEmpty();
}

extension ContextExtension on BuildContext {
  SystemUiOverlayStyle get systemUiOverlayStyle => isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
}

extension ListExt<E> on List<E>? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;

  bool isNotNullOrEmpty() => !this.isNullOrEmpty();

  E? singleOrNull(bool Function(E element) test) {
    if (this == null) return null;
    E? single;
    bool found = false;
    for (var element in this!) {
      if (test(element)) {
        if (found) continue;
        single = element;
        found = true;
      }
    }
    if (!found) return null;
    return single;
  }

  E? getOrNull(int index) {
    if (this == null) return null;
    return index >= 0 && index <= this!.length - 1 ? this![index] : null;
  }
}