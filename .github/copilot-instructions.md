<!-- .github/copilot-instructions.md - guidance for AI coding agents -->

This repository is a Flutter application (single-package) created from the default Flutter template.

Key facts (big picture)
- Language: Dart / Flutter. Entry point: `lib/main.dart`.
- Platforms: Android (android/), iOS (ios/), web (web/), Windows/macOS/Linux (platform folders present). The app follows the single-app, multi-platform Flutter convention.
- Build tooling: uses the Flutter tool and Gradle wrappers in `android/` for Android builds. See `pubspec.yaml` for package metadata.

What to prioritize
- Preserve the Flutter project structure. Changes to `android/`, `ios/`, `windows/`, `macos/`, `linux/` folders must respect generated build files and platform API contracts.
- Keep `pubspec.yaml` in sync when adding packages (update versions and run `flutter pub get`).

Common developer workflows (explicit commands)
- Run app locally (dev with hot reload):
  - `flutter run` (specify `-d` for a device id, e.g. `-d chrome` or `-d <device>`)
- Run tests: `flutter test`
- Get dependencies: `flutter pub get`
- Build release APK: `flutter build apk`
- Android Gradle wrapper: use `android/gradlew.bat` on Windows when running platform Gradle tasks.

Project-specific conventions and patterns
- UI code is in `lib/` (entry `lib/main.dart`). Follow the existing pattern of small Stateful/Stateless Widgets and using Flutter's `ThemeData`/`ColorScheme`.
- No additional packages are declared in `pubspec.yaml` — prefer adding only essential dependencies and pin minor versions.
- Platform code is left at generated defaults. If you add platform channels or native plugins, add clear comments and register them in the platform project files (e.g., Android `MainActivity`, iOS `AppDelegate`).

Integration points and cross-component communication
- Flutter <-> native: currently none custom — use MethodChannels only when needed and document channel names in the Dart side (e.g., `MethodChannel('com.example.myapp/channel')`) and the native side.
- Assets and fonts: none are defined. If adding, list them in `pubspec.yaml` under `flutter.assets` and `flutter.fonts`.

Examples from the codebase
- Entry widget: `lib/main.dart` defines `MyApp` (StatelessWidget) and `MyHomePage` (StatefulWidget). Use similar structure for new pages:
  - `MyApp` sets `MaterialApp` with `theme` and `home`.
  - Keep widgets small and localized in `lib/` (create subfolders like `lib/src/` or `lib/widgets/` as the project grows).

When editing code
- Add imports at top of Dart files (use package imports, e.g. `package:meine_app/...`).
- Run `flutter analyze` (or the IDE analyzer) to pick up lint issues; the project uses `analysis_options.yaml` and `flutter_lints`.

What not to do
- Do not modify generated platform project files unless implementing a well-documented change (document the why and how in the PR).
- Avoid adding heavy dependencies without justification.

Where to look next
- `pubspec.yaml` — package info and SDK constraint.
- `lib/main.dart` — app entrypoint and UI pattern examples.
- `android/`, `ios/`, `web/`, `windows/` — platform integration points.

If something is unclear
- Ask which platform or target behavior is expected (web, mobile, desktop). Provide minimal repro steps and the device target when requesting code changes.

Short checklist for PRs
- Run `flutter analyze` and `flutter test` locally.
- Update `pubspec.yaml` for any added dependencies and run `flutter pub get`.
- Document native changes in the PR description and point to modified platform files.
