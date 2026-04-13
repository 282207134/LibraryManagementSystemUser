import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_management/config/app_config.dart';
import 'package:library_management/config/router_config.dart';
import 'package:library_management/config/theme_config.dart';
import 'package:library_management/localization/app_localization.dart';
import 'package:library_management/providers/theme_mode_provider.dart';
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
  await AppLocalization.init();
  
  runApp(const ProviderScope(child: LibraryManagementApp()));
}

class LibraryManagementApp extends ConsumerWidget {
  const LibraryManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLocalization.notifier,
      builder: (_, language, ___) => MaterialApp.router(
        key: ValueKey(language.name),
        title: AppLocalization.tr('app_title'),
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
