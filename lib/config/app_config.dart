import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  // Supabase配置
  static const String supabaseUrl = 'https://fmilpfmdvpbpomygpxtz.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_YkOmauGsEWc3dNLOZgzWuw_ElBMa076';
  
  // 传统API配置（如果需要）
  static const String apiBaseUrl = 'https://api.library.com';
  static const String devApiUrl = 'http://dev-api.library.com';
  static const String testApiUrl = 'http://test-api.library.com';

  static const int connectionTimeout = 30000; // ms
  static const int receiveTimeout = 30000; // ms
  
  // Supabase客户端实例
  static SupabaseClient get supabase => Supabase.instance.client;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
  }

  static void _registerAdapters() {
    // Register Hive adapters for models here
    // Example: Hive.registerAdapter(UserAdapter());
  }

  static Future<void> _openBoxes() async {
    await Hive.openBox<String>('tokens');
    await Hive.openBox<String>('user_cache');
    await Hive.openBox<String>('app_config');
  }

  static Future<void> clearAllData() async {
    await Hive.deleteFromDisk();
    await initialize();
  }
}
