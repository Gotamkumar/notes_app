# Notes Taking App (Flutter + Hive)

A simple offline-first notes app built with Flutter using Hive for local storage.

This project demonstrates a complete CRUD flow (Create, Read, Update, Delete) for notes stored locally with Hive.

Key features
- Create, Read, Update, Delete (CRUD) notes
- Each note contains: `title`, `content`, `createdAt`, `lastModified`
- Uses a Hive model with a manual `TypeAdapter` (no code generation required)
- Hive box called `notesBox`
- Reactive UI: `ValueListenableBuilder` listens to Hive changes
- Home screen list of notes, note editor screen for add/edit, FAB to add notes
- Delete via swipe (Dismissible) or long-press with confirmation

Project structure (important files)

- `lib/main.dart` — App entry, Hive initialization, adapter registration, opens `notesBox`
- `lib/models/note_model.dart` — Note model (fields: title, content, createdAt, lastModified)
- `lib/models/note_model_adapter.dart` — Manual Hive `TypeAdapter` for `NoteModel`
- `lib/screens/home_screen.dart` — Home screen listing notes (uses `ValueListenableBuilder`)
- `lib/screens/note_editor.dart` — Add/Edit note screen
- `lib/widgets/note_tile.dart` — Small tile widget used in the list
- `test/widget_test.dart` — A small smoke test to ensure the app boots

Dependencies
- Flutter SDK (see environment in `pubspec.yaml`)
- hive
- hive_flutter
- intl

Quick start (run locally)

Prerequisites: Flutter installed and configured for your target platform.

From the project root:

```bash
# install dependencies
flutter pub get

# run the app (choose a device/emulator)
flutter run
```

To run the tests:

```bash
flutter test
```

To analyze the project:

```bash
flutter analyze
```

Hive details and notes

- The app registers a manual `TypeAdapter` implemented in `lib/models/note_model_adapter.dart` and opens a box named `notesBox` in `main.dart`.
- The manual adapter reads and writes the `NoteModel` fields including `DateTime` values. This avoids requiring `build_runner` and `hive_generator`.

Optional: use code generation (if you prefer)

If you'd rather use generated adapters with `hive_generator`, do the following:

1. Add to `dev_dependencies` in `pubspec.yaml`:

```yaml
dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.0.0
```

2. Add Hive annotations to the `NoteModel` (see Hive docs).
3. Run the generator:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

After generation you can register the generated adapter instead of the manual one.

Developer notes & next steps

- The UI currently uses a `ListView` with `Card` tiles; you can switch to a `GridView` or add sorting/search.
- There are a couple of informational lints from `flutter analyze` about `BuildContext` across async gaps in `home_screen.dart`. They do not break functionality but you can fix them by capturing `mounted` checks and localizing contexts if desired.
- Consider adding more tests for add/edit/delete flows.

License & attribution

This project template was created to demonstrate using Hive in a Flutter app. Modify or re-use as desired.

If you want, I can:
- Convert the manual adapter to a generated one and wire up `build_runner`.
- Add search, sort, or grid view and tests for CRUD actions.
- Fix the analyzer info lint by updating `home_screen.dart` to avoid using context across async gaps.

Just tell me which of the next steps you'd like me to take and I'll implement it.
