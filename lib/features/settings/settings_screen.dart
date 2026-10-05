import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/location_tracking_service.dart';
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
        const SizedBox(height: 16),
        const _LocationTrackingCard(),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.unknownError)),
    );
  }
}

class _LocationTrackingCard extends ConsumerStatefulWidget {
  const _LocationTrackingCard();

  @override
  ConsumerState<_LocationTrackingCard> createState() =>
      _LocationTrackingCardState();
}

class _LocationTrackingCardState extends ConsumerState<_LocationTrackingCard> {
  bool _running = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final service = ref.watch(locationTrackingServiceProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.locationTracking,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              service.isSupported
                  ? (_running
                        ? strings.locationTrackingOn
                        : strings.locationTrackingOff)
                  : strings.trackingAndroidOnly,
            ),
            const SizedBox(height: 8),
            Text(
              strings.trackingPermissionNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (service.isSupported) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _loading ? null : _toggleTracking,
                icon: _loading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _running ? Icons.location_disabled : Icons.my_location,
                      ),
                label: Text(
                  _running
                      ? strings.stopLocationTracking
                      : strings.startLocationTracking,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    final service = ref.read(locationTrackingServiceProvider);
    if (!service.isSupported) return;
    try {
      final running = await service.isRunning();
      if (mounted) setState(() => _running = running);
    } on Exception catch (error) {
      debugPrint('Unable to read location service status: $error');
    }
  }

  Future<void> _toggleTracking() async {
    final strings = AppLocalizations.of(context)!;
    final service = ref.read(locationTrackingServiceProvider);
    setState(() => _loading = true);
    try {
      if (_running) {
        await service.stop();
        if (mounted) setState(() => _running = false);
      } else {
        await service.start();
        if (mounted) setState(() => _running = true);
      }
    } on Exception catch (error) {
      debugPrint('Unable to change location tracking state: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _running
                  ? strings.locationTrackingStopFailed
                  : strings.locationTrackingStartFailed,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}