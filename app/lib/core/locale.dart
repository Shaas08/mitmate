import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App language. Defaults to the device language if German or English, else German.
final localeProvider = StateProvider<Locale>((ref) {
  final device = PlatformDispatcher.instance.locale.languageCode;
  return Locale(device == 'en' ? 'en' : 'de');
});
