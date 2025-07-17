import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: provider.locale,
          icon: const Icon(Icons.language, color: Colors.white),
          dropdownColor: Colors.black87,
          hint: Text('🌐', style: TextStyle(color: Colors.white)),
          onChanged: (Locale? locale) {
            if (locale != null) {
              provider.setLocale(locale);
            }
          },
          items: L10n.all
              .map(
                (locale) => DropdownMenuItem(
                  value: locale,
                  child: Text(
                    L10n.getLanguageName(locale.languageCode),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
