// 导入Flutter Material Design组件库
import 'package:flutter/material.dart';

// 应用颜色定义类,集中管理所有颜色常量
class AppColors {
  // 主色调
  static const Color primary = Color(0xFF2196F3);
  // 主色调浅色
  static const Color primaryLight = Color(0xFF64B5F6);
  // 主色调深色
  static const Color primaryDark = Color(0xFF1976D2);

  // 辅助色
  static const Color secondary = Color(0xFFFF9800);
  // 辅助色浅色
  static const Color secondaryLight = Color(0xFFFFB74D);
  // 辅助色深色
  static const Color secondaryDark = Color(0xFFF57C00);

  // 功能色 - 成功
  static const Color success = Color(0xFF4CAF50);
  // 功能色 - 警告
  static const Color warning = Color(0xFFFFC107);
  // 功能色 - 错误
  static const Color error = Color(0xFFF44336);
  // 功能色 - 信息
  static const Color info = Color(0xFF2196F3);

  // 浅色主题背景色
  static const Color lightBackground = Color(0xFFFAFAFA);
  // 浅色主题表面色
  static const Color lightSurface = Color(0xFFFFFFFF);
  // 浅色主题卡片背景色
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  // 浅色主题分割线颜色
  static const Color lightDivider = Color(0xFFE0E0E0);
  // 浅色主题禁用状态颜色
  static const Color lightDisabled = Color(0xFFBDBDBD);

  // 深色主题背景色
  static const Color darkBackground = Color(0xFF121212);
  // 深色主题表面色
  static const Color darkSurface = Color(0xFF1E1E1E);
  // 深色主题卡片背景色
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  // 深色主题分割线颜色
  static const Color darkDivider = Color(0xFF404040);
  // 深色主题禁用状态颜色
  static const Color darkDisabled = Color(0xFF666666);

  // 文本主色
  static const Color textPrimary = Color(0xFF212121);
  // 文本次要色
  static const Color textSecondary = Color(0xFF757575);
  // 文本提示色
  static const Color textHint = Color(0xFFBDBDBD);
  // 文本反色(用于深色背景)
  static const Color textInverse = Color(0xFFFFFFFF);

  // 深色主题文本主色
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  // 深色主题文本次要色
  static const Color darkTextSecondary = Color(0xFFC7C7C7);
  // 深色主题文本提示色
  static const Color darkTextHint = Color(0xFF888888);
}

// 主题配置类,定义浅色和深色主题
class ThemeConfig {
  // 获取浅色主题配置
  static ThemeData get lightTheme {
    return ThemeData(
      // 使用Material Design 3
      useMaterial3: true,
      // 亮度模式为浅色
      brightness: Brightness.light,
      // 主色调
      primaryColor: AppColors.primary,
      // Scaffold背景色
      scaffoldBackgroundColor: AppColors.lightBackground,
      // 卡片颜色
      cardColor: AppColors.lightCardBackground,
      // 分割线颜色
      dividerColor: AppColors.lightDivider,
      
      // 颜色方案配置
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
      ),

      // AppBar主题配置
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      // 浮动操作按钮主题配置
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // 凸起按钮主题配置
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // 轮廓按钮主题配置
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // 文本按钮主题配置
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),

      // 输入框装饰主题配置
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      // 文本主题配置
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        labelSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  // 获取深色主题配置
  static ThemeData get darkTheme {
    return ThemeData(
      // 使用Material Design 3
      useMaterial3: true,
      // 亮度模式为深色
      brightness: Brightness.dark,
      // 主色调
      primaryColor: AppColors.primary,
      // Scaffold背景色
      scaffoldBackgroundColor: AppColors.darkBackground,
      // 卡片颜色
      cardColor: AppColors.darkCardBackground,
      // 分割线颜色
      dividerColor: AppColors.darkDivider,
      
      // 颜色方案配置
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
      ),

      // AppBar主题配置
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      // 浮动操作按钮主题配置
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // 凸起按钮主题配置
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // 文本选择主题配置
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x552196F3),
        selectionHandleColor: AppColors.primary,
      ),

      // 输入框装饰主题配置
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.darkTextHint),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
        helperStyle: const TextStyle(color: AppColors.darkTextHint),
        errorStyle: const TextStyle(color: AppColors.error),
        prefixIconColor: AppColors.darkTextSecondary,
        suffixIconColor: AppColors.darkTextSecondary,
      ),

      // 文本主题配置
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        displaySmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextSecondary,
        ),
        labelSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextHint,
        ),
      ),
    );
  }
}
