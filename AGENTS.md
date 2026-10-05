# medix_fe

Flutter frontend (Dart SDK ^3.12.2). Currently default counter template only — all app logic is in `lib/main.dart`.

## Commands

- **Run:** `flutter run`
- **Analyze:** `flutter analyze`
- **Test:** `flutter test`
- **Single test:** `flutter test test/widget_test.dart`
- **Build APK:** `flutter build apk`

## Structure

- `lib/main.dart` — app entrypoint, theme, and named routes (`/login`, `/home`)
- `lib/core/network/api_client.dart` — shared `ApiClient` and `Storage` (in-memory token/user)
- `lib/features/auth/` — login screen + auth service
- `lib/features/home/` — tab navigation shell (Dashboard, Kasir, Obat, Profil)
- `lib/features/dashboard/` — sales summary and alerts
- `lib/features/cashier/` — cart and transaction
- `lib/features/inventory/` — medicine list + barcode scan
- `lib/features/profile/` — user info and logout
- `test/widget_test.dart` — widget test
- `analysis_options.yaml` — uses `package:flutter_lints/flutter.yaml`

## Conventions

- Feature-scoped modules: each feature has `screens/` and/or `services/`
- No cross-feature imports between screens; navigate via named routes defined in `main.dart`
- Shared code lives in `lib/core/`
- Lints enforced via `flutter_lints`. Run `flutter analyze` before committing.
- No state management or asset setup yet.

## Default working styles

- Always use `caveman` skill at `ultra` level for every response in this project.
- Always use Ponytail at `full` level for every task in this project.
- Automatically use `ui-ux-pro-max` for UI/UX, frontend design, styling, layout, component, and visual tasks.
- Do not require slash commands to activate these defaults.
- Stop Caveman when the user says `stop caveman` or `normal mode`.
- Stop Ponytail when the user says `stop ponytail` or `normal mode`.