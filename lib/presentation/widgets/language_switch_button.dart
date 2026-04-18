import 'package:flutter/material.dart';
import 'package:library_management/localization/app_localization.dart';

class LanguageSwitchButton extends StatelessWidget { // 语言切换按钮
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLanguage>(
      tooltip: AppLocalization.tr('language'), // 提示文本
      icon: const Icon(Icons.language), // 语言图标
      onSelected: (lang) => AppLocalization.setLanguage(lang), // 选择语言
      itemBuilder: (context) => AppLanguage.values
          .map(
            (lang) => PopupMenuItem<AppLanguage>(
              value: lang,
              child: Text(AppLocalization.languageLabel(lang)), // 显示语言标签
            ),
          )
          .toList(),
    );
  }
}
