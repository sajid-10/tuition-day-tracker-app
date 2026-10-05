# Tuition Tracker

An offline-first Flutter app for managing tuition students, schedules, and
location-based tuition sessions.

## Implemented

- Riverpod, Material 3 themes, and persistent English/Bangla and theme settings.
- Drift/SQLite local storage for students, schedules, sessions, payments,
  arrival prompts, GPS logs, and a future-sync queue, including a v1-to-v2
  migration.
- Local student create/list/archive flows and tuition location, radius,
  duration, and payment-day target editing.
- Weekly schedule editing.
- Android foreground location monitoring with adaptive polling: 15 minutes
  when far away, 10 minutes while approaching, 2 minutes nearby, and 5 minutes
  inside a zone or during an active session.
- Arrival prompts with Start/Not now actions, session time threshold alerts,
  and completed-day payment-target alerts.
- GPS accuracy filtering, exit grace handling, and local location/session logs.
- Repository tests for polling tiers, session completion, GPS drift/grace, and
  schedule updates.

## Limitations

- Background location tracking is Android-only and best-effort. Android may
  delay fixes because of battery optimization or device-specific policies.
- Cloud synchronization, payment entry/history, reports, manual session
  workflows, and iOS background tracking are not implemented. Sync records
  are queued locally but are not uploaded.
- Location tracking has not yet been built and exercised on a physical Android
  device or emulator. Configure the Android SDK and verify all-time location
  and notification permission flows before relying on it.
- The generated Android release currently uses the default application ID and
  debug signing configuration; configure these before distribution.

## Development sequence

1. **Run local validation:** regenerate Drift and localization output, analyze,
   then run all tests.
2. **Verify Android tracking:** build and install on a device/emulator; grant
   all-time location and notification permissions; test arrival actions,
   threshold completion, app minimization/restart, GPS drift, and battery
   restrictions.
3. **Finish local workflows:** add payment entry/history and manual session
   start/stop, then test session recovery and completed-day/payment-cycle rules.
4. **Add sync and reports:** implement a remote backend, retry/conflict
   handling for queued records, and local reports with offline tests.
5. **Prepare release:** accessibility and localization checks, backup/export,
   production application ID/signing, and Android release verification.

Keep core reads/writes and session tracking local. Cloud sync should remain
optional and must not block offline workflows.

## Build and run on Windows

From the project folder in PowerShell:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

Run the app in the Edge browser window:

```powershell
flutter run -d edge
```

Run as a native Windows desktop app:

```powershell
flutter run -d windows
```

The Windows desktop runner is configured in `windows/`. Flutter plugin builds
on Windows require symbolic-link support; if Flutter reports that symlink
support is disabled, enable Developer Mode in Windows Settings and restart
the terminal/IDE before retrying. Edge is a browser fallback if desktop
symlinks are unavailable.

Build an Android APK after tests pass:

```powershell
flutter build apk --release
```

On Android, start tracking from **Settings**. Grant location access **all the
time** in Android app settings and allow notifications when prompted. Tracking
requires a saved student location; it runs as a visible foreground service.

If Flutter reports that plugin builds need symlink support on Windows, enable
Windows Developer Mode (or run the build in an environment with symlink
support), then rerun `flutter pub get` and the validation commands.
