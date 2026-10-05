import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('SharedPreferences was not initialized.'),
);

enum AppLanguage {
  english('en'),
  bangla('bn');

  const AppLanguage(this.languageCode);

  final String languageCode;

  Locale get locale => Locale(languageCode);
}

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.english,
  });

  final ThemeMode themeMode;
  final AppLanguage language;
}

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends Notifier<AppSettings> {
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language';

  @override
  AppSettings build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      themeMode: switch (preferences.getString(_themeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      language: switch (preferences.getString(_languageKey)) {
        'bn' => AppLanguage.bangla,
        _ => AppLanguage.english,
      },
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(_themeKey, themeMode.name);
    state = AppSettings(themeMode: themeMode, language: state.language);
  }

  Future<void> setLanguage(AppLanguage language) async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(_languageKey, language.languageCode);
    state = AppSettings(themeMode: state.themeMode, language: language);
  }
}
