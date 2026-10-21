import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

abstract final class AppLog {
  static void event(String event, {String? code}) {
    if (!kDebugMode) return;
    developer.log(
      code == null ? event : '$event code=$code',
      name: 'IndicLearn',
    );
  }
}
