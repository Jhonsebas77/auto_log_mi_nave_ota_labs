# Mi Nave — Auto Log

A Flutter app to keep a vehicle's paperwork and running costs in one place:
fuel logs and consumption, legal documents (SOAT, RTM, taxes…), maintenance
history and Medellín's *pico y placa* driving restriction. Built for the
Colombian market; the UI is in Spanish.

Backend: [Supabase](https://supabase.com) (Auth, Postgres with RLS, private
Storage). Targets: **Android, iOS and Web** (PWA).

---

## Features

The home screen (`AppShell`) has five tabs. Phones get a bottom nav bar,
tablets a compact rail, and desktops a full sidebar
(`lib/ui/theme/breakpoints.dart`).

| Tab | What it does |
| --- | --- |
| **Inicio** (Dashboard) | Vehicle card with photo, quick odometer update, today's *pico y placa* status and weekly schedule, and a traffic light for SOAT/RTM expirations. |
| **Gasolina** (Fuel) | Km/gal performance curve (fl_chart), KPIs (average km/gal, cost per km, total and monthly spend, estimated range), and fuel history with sorting and swipe-to-delete. |
| **Legal** | Documents grouped by *Vehículo / Impuestos / Conductor*, expiration countdowns, attachment preview, and detail/edit/delete. |
| **Taller** (Maintenance) | Lifespan bars for oil (5,000 km), tires (40,000 km) and brakes (30,000 km), plus service history filtered by preventive/corrective. |
| **Acciones** | Shortcuts to the register forms. |

Other screens:
- Forms to register fuel, documents and maintenance.
- Add/edit vehicle, with a color picker and photo.
- Settings: notification toggle, app version and logout.

Other behavior:
- **Reminders.** Local notifications fire 30, 15, 7 and 1 days before a
  document expires (timezone `America/Bogota`). They're a no-op on web.
- **Attachments.** Photos and PDFs go to a private Storage bucket and are
  shown through short-lived signed URLs.
- **One vehicle per user.** The app currently supports a single vehicle
  per account.
- **Simulated OCR.** Document OCR is simulated
  (`lib/core/services/ocr/ocr_simulation_service.dart`).

## Tech stack

| Area | Choice |
| --- | --- |
| SDK | Flutter 3.41 / Dart `^3.11.4` |
| State management | [Riverpod 3](https://riverpod.dev) (`flutter_riverpod`), no code generation |
| Backend | `supabase_flutter` (Auth email + password, Postgres, Storage) |
| Charts / animation | `fl_chart`, `flutter_animate`, `shimmer` (loading skeletons) |
| Notifications | `flutter_local_notifications` + `timezone` |
| Files | `image_picker`, `file_picker` |
| Misc | `intl`, `uuid`, `recase`, `package_info_plus` |

## Project structure

```
lib/
├── main.dart                 # Supabase init, ProviderContainer, runApp
├── app.dart                  # MaterialApp + theme + AuthGate
├── core/
│   ├── constants/            # pico y placa table, maintenance intervals, reminder offsets
│   ├── enums/
│   ├── models/               # hand-written fromJson/toJson, value equality, ValueWrapper-based copyWith
│   ├── data/repositories/    # abstract repositories + supabase/ implementations
│   ├── providers/            # Riverpod providers, notifiers and *Actions classes
│   ├── services/             # attachments (Storage), notifications, OCR (simulated)
│   └── utils/                # calculators (fuel metrics, lifespan, document status), Logger
└── ui/
    ├── views/                # screens (auth, dashboard, fuel, legal, maintenance, vehicles, settings)
    ├── widgets/              # shared widgets
    ├── theme/                # "Engineering Blueprint" theme, text styles, breakpoints
    └── navigator.dart        # CustomNavigator (Navigator 1.0 + custom transitions)
```

Conventions:
- **Library files.** Each folder is a Dart library (`library` + `part`
  files).
- **Repository binding.** Repositories are bound in one place,
  `lib/core/data/repositories/providers.dart`, so implementations are easy
  to swap. Tests override them with in-memory fakes.
- **Logging.** Use `Logger` (`lib/core/utils/logger.dart`) instead of
  calling `debugPrint` directly.

## Supabase setup

1. **Create a project.** Create a Supabase project and enable
   **email + password** auth. Create the user that will log in.
2. **Expose the schema.** Every table lives in the **`auto_log`** schema,
   not `public`. Add it under *Project Settings → API → Exposed schemas*.
   Otherwise every query fails with "The schema must be one of the
   following: public".
3. **Run the migrations.** In the SQL Editor, run the files in
   `supabase/sql/` **in order**:

   | File | Purpose |
   | --- | --- |
   | `0001_vehicles.sql` | `vehicles` table, `updated_at` trigger, RLS, grants |
   | `0002_storage.sql` | `attachments` bucket + per-user folder policies |
   | `0003_fuel_logs.sql` | `fuel_logs` table + RLS |
   | `0004_legal_documents.sql` | `legal_documents` table + RLS |
   | `0005_fuel_logs_extra_fuel.sql` | `is_extra_fuel` column |
   | `0006_attachments_private.sql` | makes the bucket private (signed URLs) |
   | `0007_migrate_attachment_paths.sql` | **manual / commented out**: one-off data migration from public URLs to object paths |
   | `0008_maintenances.sql` | `maintenances` table + RLS |
   | `0009_restrict_anon_grants.sql` | revokes `anon` privileges on `auto_log` |
   | `0010_performance.sql` | indexes (`vehicles.user_id`, `(vehicle_id, date)`) and RLS policies using `(select auth.uid())` |

   Every migration is idempotent.

   > `supabase/sql/` is currently listed in `.gitignore`, so these files
   > exist only locally. Get them from a maintainer if your clone doesn't
   > have them.

Storage layout: `attachments/{userId}/{category}/{uuid}.{ext}`. The
database stores the object path, never a URL. Signed URLs last one hour.

More backend detail lives in `claude/supabase_backend.md`.

## Configuration

Credentials are passed at build time with `--dart-define`. They are never
committed.

```bash
cp config/dart_defines.example.json config/dart_defines.local.json
# then edit config/dart_defines.local.json
```

| Key | Description |
| --- | --- |
| `SUPABASE_URL` | Project URL (`https://<ref>.supabase.co`) |
| `SUPABASE_PUBLISHABLE_KEY` | Publishable (anon) key |
| `AUTH_EMAIL` | Email used to sign in (see note below) |

`config/dart_defines.local.json` is gitignored. The app throws a
`StateError` at startup if any key is missing.

> **Note:** login always signs in with `AUTH_EMAIL`. The email typed on the
> login screen is only checked to be non-empty; the password must be the
> password of the `AUTH_EMAIL` user.

## Running

```bash
flutter pub get

# Android / iOS (device or emulator)
flutter run --dart-define-from-file=config/dart_defines.local.json

# Web
flutter run -d chrome --dart-define-from-file=config/dart_defines.local.json
```

### Building

```bash
flutter build apk --dart-define-from-file=config/dart_defines.local.json
flutter build ipa --dart-define-from-file=config/dart_defines.local.json
flutter build web --dart-define-from-file=config/dart_defines.local.json
```

Platform notes:
- **Android.** The app id is `com.auto_log_mi_nave_ota_labs`. It uses the
  `POST_NOTIFICATIONS` permission and core library desugaring. Reminders use
  inexact alarms, so no exact-alarm permission is needed.
- **iOS.** The deployment target is 13.0. Notification permission is
  requested after the first login.
- **Web.** The PWA manifest is named "Mi Nave". Local notifications aren't
  available on web.

## Quality checks

```bash
flutter analyze   # lint rules in analysis_options.yaml
flutter test      # unit + widget tests
```

Tests live in `test/`:
- **Unit tests** (`test/unit/`) cover the calculators (fuel metrics,
  lifespan, document status, pico y placa), fuel providers, the in-memory
  repositories, model serialization, the notification reconciler and the
  reminder planner.
- **Widget tests** are `test/widget/license_plate_restriction_test.dart`
  and `test/widget_test.dart`. The latter checks that the app boots on the
  login screen with a dummy Supabase config.
- **Fakes and in-memory repositories** are in `test/helpers/`.

Spelling is checked with cSpell (`cspell.config.yaml`, English + Spanish,
with a project word list).

## Performance notes

A performance pass covered both the client and the database. When you
change the related code, keep these in place:

- **Signed URLs are cached.** `signedUrlProvider` (`lib/core/services/service_providers.dart`)
  caches each attachment's signed URL by object path for 55 minutes. The
  image cache is keyed by path rather than by the tokenized URL, so a
  rebuild no longer re-signs the photo, downloads it again and makes it
  flicker. Images are decoded at display size (`ResizeImage`) and camera or
  gallery photos are capped at 1600 px before upload.
- **Rebuilds are narrow.** Models have value equality, and tabs watch
  `selectedVehicleProvider.select((v) => v?.id)` instead of the whole
  vehicle. A refresh that changes nothing doesn't rebuild the UI, and an
  odometer update doesn't rebuild the fuel, legal or maintenance tabs.
- **Tabs are lazy.** `AppShell` mounts a tab (and runs its queries) the
  first time it's opened, and pauses tickers on offstage tabs.
- **Startup doesn't wait on notifications.** Notification init (timezone
  DB + plugin) runs after `runApp`, and uses the smaller `latest_10y`
  timezone data. Notification calls wait for init internally.
- **Fewer round-trips.**
  - Raising the odometer is a single conditional `UPDATE`.
  - Vehicle create, update and odometer changes patch local state with
    the row the server returns, instead of refetching the list.
  - The notification reconciler selects only the columns it needs,
    schedules in parallel, and serializes overlapping runs.
- **The login screen is cheaper to animate.** Its looping animations use
  `RepaintBoundary` plus transform/opacity transitions, so they don't
  relayout or repaint the whole screen every frame.
- **Database.** Indexes and RLS policies are tuned in
  `supabase/sql/0010_performance.sql`.

## Design and docs

- **Theme.** The "Engineering Blueprint" theme is dark (`#0b1623`
  background, `#ff9f30` accent) with sharp corners and a grid overlay.
  JetBrains Mono is bundled in `assets/fonts/`.
- **Design and planning docs** are in `claude/`:
  - `tech_spec.md`: stack and original schema.
  - `design_spec.md`: design system and screens.
  - `supabase_backend.md`: connecting a client to the backend.
  - The original implementation plan.
