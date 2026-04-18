// 导入Flutter Material Design组件库
import 'package:flutter/material.dart';
// 导入Riverpod状态管理库
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 导入Hive本地数据库库
import 'package:hive_flutter/hive_flutter.dart';

// 主题模式存储键名
const _themeModeKey = 'theme_mode';
// 应用配置存储盒名称
const _appConfigBoxName = 'app_config';

// 解析主题模式字符串为ThemeMode枚举
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

// 将ThemeMode枚举序列化为字符串
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

// 主题模式通知器类,管理主题状态的变更和持久化
class ThemeModeNotifier extends Notifier<ThemeMode> {
  // Hive数据存储盒
  late final Box<String> _box;

  @override
  // 构建方法,初始化时从本地存储加载主题设置
  ThemeMode build() {
    _box = Hive.box<String>(_appConfigBoxName);
    return _parseThemeMode(_box.get(_themeModeKey));
  }

  // 设置主题模式并保存到本地存储
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _box.put(_themeModeKey, _serializeThemeMode(mode));
  }
}

// 主题模式提供者,供其他组件监听和使用
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

