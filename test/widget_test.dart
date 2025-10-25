// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:notes_taking_app/main.dart';
import 'package:notes_taking_app/models/note_model.dart';

void main() {
  Directory? tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir!.path);
    Hive.registerAdapter(NoteModelAdapter());
    if (!Hive.isBoxOpen('notesBox')) {
      await Hive.openBox<NoteModel>('notesBox');
    }
  });

  tearDownAll(() async {
    try {
      if (Hive.isBoxOpen('notesBox')) {
        final box = Hive.box<NoteModel>('notesBox');
        await box.clear();
        await box.close();
      }
    } catch (_) {}

    try {
      if (tempDir != null && await tempDir!.exists()) {
        await tempDir!.delete(recursive: true);
      }
    } catch (_) {}
  });

  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const NotesApp());
    await tester.pumpAndSettle();

    // Basic smoke: App shows 'Notes' title in AppBar
    expect(find.text('Notes'), findsOneWidget);
  });
}
