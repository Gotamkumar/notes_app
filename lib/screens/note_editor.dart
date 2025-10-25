import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

class NoteEditor extends StatefulWidget {
  final NoteModel? note;
  final int? noteKey; // Hive key when editing

  const NoteEditor({super.key, this.note, this.noteKey});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }

    _titleController.addListener(() {
      if (!_isDirty) setState(() => _isDirty = true);
    });
    _contentController.addListener(() {
      if (!_isDirty) setState(() => _isDirty = true);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;

    final box = Hive.box<NoteModel>('notesBox');
    final now = DateTime.now();

    if (widget.note == null) {
      final note = NoteModel(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        createdAt: now,
        lastModified: now,
      );
      await box.add(note);
    } else {
      // Update an existing note keeping createdAt
      final updated = NoteModel(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        createdAt: widget.note!.createdAt,
        lastModified: now,
      );
      if (widget.noteKey != null) {
        await box.put(widget.noteKey, updated);
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            onPressed: _isDirty ? _saveNote : null,
            icon: const Icon(Icons.save),
            tooltip: 'Save',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Write your note here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        child: const Icon(Icons.check),
      ),
    );
  }
}
