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
