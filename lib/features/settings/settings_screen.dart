import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          strings.settingsSubtitle,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.appearance,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ThemeMode>(
                  initialValue: settings.themeMode,
                  decoration: InputDecoration(labelText: strings.appearance),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(strings.systemDefault),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(strings.light),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(strings.dark),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) _setThemeMode(context, controller, mode);
                  },
                ),
                const SizedBox(height: 22),
                Text(
                  strings.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AppLanguage>(
                  initialValue: settings.language,
                  decoration: InputDecoration(labelText: strings.language),
                  items: [
                    DropdownMenuItem(
                      value: AppLanguage.english,
                      child: Text(strings.english),
                    ),
                    DropdownMenuItem(
                      value: AppLanguage.bangla,
                      child: Text(strings.bangla),
                    ),
                  ],
                  onChanged: (language) {
                    if (language != null) {
                      _setLanguage(context, controller, language);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _setThemeMode(
    BuildContext context,
    AppSettingsController controller,
    ThemeMode mode,
  ) async {
    try {
      await controller.setThemeMode(mode);
    } on Exception catch (error) {
      debugPrint('Unable to save theme preference: $error');
      if (!context.mounted) return;
      _showPreferenceError(context);
    }
  }

  Future<void> _setLanguage(
    BuildContext context,
    AppSettingsController controller,
    AppLanguage language,
  ) async {
    try {
      await controller.setLanguage(language);
    } on Exception catch (error) {
      debugPrint('Unable to save language preference: $error');
      if (!context.mounted) return;
      _showPreferenceError(context);
    }
  }

  void _showPreferenceError(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.unknownError)),
    );
  }
}
