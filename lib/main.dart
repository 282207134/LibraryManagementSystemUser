import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_management/config/app_config.dart';
import 'package:library_management/config/router_config.dart';
import 'package:library_management/config/theme_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Supabase
  await Supabase.initialize(
    url: 'https://fmilpfmdvpbpomygpxtz.supabase.co',
    anonKey: 'sb_publishable_YkOmauGsEWc3dNLOZgzWuw_ElBMa076',
  );
  
  // 初始化应用配置
  await AppConfig.initialize();
  
  runApp(const ProviderScope(child: LibraryManagementApp()));
}

class LibraryManagementApp extends ConsumerWidget {
  const LibraryManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Library Management System',
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
