// 导入Hive本地数据库库
import 'package:hive_flutter/hive_flutter.dart';
// 导入Supabase客户端库
import 'package:supabase_flutter/supabase_flutter.dart';

// 应用配置类,集中管理所有配置项
class AppConfig {
  // Supabase服务URL地址
  static const String supabaseUrl = 'https://fmilpfmdvpbpomygpxtz.supabase.co';
  // Supabase匿名访问密钥
  static const String supabaseAnonKey = 'sb_publishable_YkOmauGsEWc3dNLOZgzWuw_ElBMa076';

  // Web端基础URL地址(用于邮件跳转等场景)
  static const String webBaseUrl = 'https://library-management-system-chi-lyart.vercel.app';
  // 密码重置重定向URL
  static const String passwordResetRedirectUrl = '$webBaseUrl/reset-password';
  // 邮箱验证重定向URL
  static const String emailConfirmRedirectUrl = '$webBaseUrl/login';
  
  // 传统API基础URL配置(备用)
  static const String apiBaseUrl = 'https://api.library.com';
  // 开发环境API地址
  static const String devApiUrl = 'http://dev-api.library.com';
  // 测试环境API地址
  static const String testApiUrl = 'http://test-api.library.com';

  // 连接超时时间(毫秒)
  static const int connectionTimeout = 30000; // ms
  // 接收超时时间(毫秒)
  static const int receiveTimeout = 30000; // ms
  
  // 获取Supabase客户端实例
  static SupabaseClient get supabase => Supabase.instance.client;

  // 初始化应用配置
  static Future<void> initialize() async {
    // 初始化Hive数据库
    await Hive.initFlutter();
    // 注册数据适配器
    _registerAdapters();
    // 打开数据存储盒
    await _openBoxes();
  }

  // 注册Hive数据适配器
  static void _registerAdapters() {
    // 在此处注册模型的数据适配器
    // 例如: Hive.registerAdapter(UserAdapter());
  }

  // 打开Hive数据存储盒
  static Future<void> _openBoxes() async {
    // 打开令牌存储盒
    await Hive.openBox<String>('tokens');
    // 打开用户缓存存储盒
    await Hive.openBox<String>('user_cache');
    // 打开应用配置存储盒
    await Hive.openBox<String>('app_config');
  }

  // 清除所有本地数据
  static Future<void> clearAllData() async {
    // 从磁盘删除所有Hive数据
    await Hive.deleteFromDisk();
    // 重新初始化
    await initialize();
  }
}
