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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1838),   // Fondo muy oscuro       
            Color(0xFF453089),   // Azul-violeta oscuro
            Color(0xFF5619e5),   // Violeta principal
            
          ],
          stops: [0.1, 0.7, 1.0], // Puedes ajustar los stops para suavizar la transición
        ),
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
                    L10n.getLanguageName(locale.languageCode, locale.countryCode),
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
