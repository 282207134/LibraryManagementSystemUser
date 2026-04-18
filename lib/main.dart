// 导入Flutter Material Design组件库
import 'package:flutter/material.dart';
// 导入Riverpod状态管理库
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 导入应用配置模块
import 'package:library_management/config/app_config.dart';
// 导入路由配置模块
import 'package:library_management/config/router_config.dart';
// 导入主题配置模块
import 'package:library_management/config/theme_config.dart';
// 导入应用本地化模块
import 'package:library_management/localization/app_localization.dart';
// 导入主题模式提供者
import 'package:library_management/providers/theme_mode_provider.dart';
// 导入Supabase客户端库
import 'package:supabase_flutter/supabase_flutter.dart';

// 应用程序入口函数
void main() async {
  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Supabase后端服务
  await Supabase.initialize(
    url: 'https://fmilpfmdvpbpomygpxtz.supabase.co',
    anonKey: 'sb_publishable_YkOmauGsEWc3dNLOZgzWuw_ElBMa076',
  );
  
  // 初始化应用配置
  await AppConfig.initialize();
  // 初始化本地化服务
  await AppLocalization.init();
  
  // 启动应用,使用ProviderScope包裹以支持状态管理
  runApp(const ProviderScope(child: LibraryManagementApp()));
}

// 图书馆管理系统主应用组件
class LibraryManagementApp extends ConsumerWidget {
  // 构造函数
  const LibraryManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听路由提供者
    final router = ref.watch(routerProvider);
    // 监听主题模式提供者
    final themeMode = ref.watch(themeModeProvider);

    // 监听语言变化并重建应用
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLocalization.notifier,
      builder: (_, language, ___) => MaterialApp.router(
        // 使用语言名称作为key以确保语言切换时正确重建
        key: ValueKey(language.name),
        // 应用标题
        title: AppLocalization.tr('app_title'),
        // 浅色主题配置
        theme: ThemeConfig.lightTheme,
        // 深色主题配置
        darkTheme: ThemeConfig.darkTheme,
        // 当前主题模式
        themeMode: themeMode,
        // 路由配置
        routerConfig: router,
        // 隐藏调试横幅
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
