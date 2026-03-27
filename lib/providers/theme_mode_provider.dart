import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _themeModeKey = 'theme_mode';
const _appConfigBoxName = 'app_config';

ThemeMode _parseThemeMode(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

String _serializeThemeMode(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  late final Box<String> _box;

  @override
  ThemeMode build() {
    _box = Hive.box<String>(_appConfigBoxName);
    return _parseThemeMode(_box.get(_themeModeKey));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _box.put(_themeModeKey, _serializeThemeMode(mode));
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

