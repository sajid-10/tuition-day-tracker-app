# Tuition Tracker

An offline-first Flutter app for managing tuition students and, in later
increments, schedules, sessions, payments, and location-based tracking.

## Current build status

The project foundation is being built incrementally. The current increment
provides:

- Riverpod application startup
- Material 3 light, dark, and system themes
- Persistent English/Bangla language and theme preferences
- Drift/SQLite tables for students, schedules, sessions, payments, and the sync
  queue
- Local student create/list/archive flows
- A basic dashboard and settings screen

Background location tracking, manual sessions, schedule management, payment
workflows, notifications, reports, and Supabase synchronization are later
phases; the app does not claim to provide those yet.

## Development sequence

Build and verify one phase before starting the next:

1. **Foundation:** project structure, Material 3, Riverpod, localization,
   persistent preferences, Drift schema, repository, dashboard, student list,
   and add/archive flow.
2. **Local workflows:** database CRUD tests, weekly schedules, manual session
   start/stop, duration and completed-day rules, and session history.
3. **Location:** permission explanation, current/manual location selection,
   accuracy handling, Android foreground/background configuration, and
   geofence event tests.
4. **Automatic tracking:** validated enter/exit processing, duplicate-event
   protection, restart recovery, and explicit manual overrides.
5. **Payments and notifications:** payment-cycle calculations, payment
   records, localized local notifications, and notification preferences.
6. **Reports and cloud:** local reports first, then optional Supabase schema,
   retryable sync queue, conflict handling, and offline/network-failure tests.
7. **Release quality:** accessibility, Bengali font verification, all six
   language/theme combinations, device tests, Android release configuration,
   and backup/export.

Keep core reads/writes and session tracking local. Add cloud sync only after
the offline data model and repository behavior are tested.

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

If Flutter reports that plugin builds need symlink support on Windows, enable
Windows Developer Mode (or run the build in an environment with symlink
support), then rerun `flutter pub get` and the validation commands.
