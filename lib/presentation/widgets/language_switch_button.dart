import 'package:flutter/material.dart';
import 'package:library_management/localization/app_localization.dart';

class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLanguage>(
      tooltip: AppLocalization.tr('language'),
      icon: const Icon(Icons.language),
      onSelected: (lang) => AppLocalization.setLanguage(lang),
      itemBuilder: (context) => AppLanguage.values
          .map(
            (lang) => PopupMenuItem<AppLanguage>(
              value: lang,
              child: Text(AppLocalization.languageLabel(lang)),
            ),
          )
          .toList(),
    );
  }
}
