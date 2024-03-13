import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:my_task_planner/constants.dart';

class TransUtil {
  static String trans(String text) {
    return text.tr();
  }

  static bool isArLocale(BuildContext context) {
    return EasyLocalization.of(context).locale == Locale(langArCode);
  }

  static bool isEnLocale(BuildContext context) {
    return EasyLocalization.of(context).locale == Locale(langEnCode);
  }
}
