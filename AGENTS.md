# medix_fe

Flutter frontend (Dart SDK ^3.12.2). Currently default counter template only — all app logic is in `lib/main.dart`.

## Commands

- **Run:** `flutter run`
- **Analyze:** `flutter analyze`
- **Test:** `flutter test`
- **Single test:** `flutter test test/widget_test.dart`
- **Build APK:** `flutter build apk`

## Structure

- `lib/main.dart` — sole source file, app entrypoint
- `test/widget_test.dart` — single default widget test
- `analysis_options.yaml` — uses `package:flutter_lints/flutter.yaml`
- `ios/` — standard iOS runner (Swift)

## Conventions

- Lints enforced via `flutter_lints`. Run `flutter analyze` before committing.
- No state management, routing, or asset setup yet — project is at template stage.
