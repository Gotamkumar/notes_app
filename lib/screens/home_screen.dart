import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';
import 'note_editor.dart';
import '../widgets/note_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isGrid = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditor({NoteModel? note, int? key}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NoteEditor(note: note, noteKey: key),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<NoteModel>('notesBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
            tooltip: _isGrid ? 'Switch to list' : 'Switch to grid',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: _NotesSearch(box));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<Box<NoteModel>>(
        valueListenable: box.listenable(),
        builder: (context, notesBox, _) {
          // Build entries by pairing values with their corresponding keys
          // This is more robust than iterating keys and calling get(),
          // and keeps ordering consistent between values and keyAt(index).
          final values = notesBox.values.toList().cast<NoteModel>();
          final entries = <MapEntry<dynamic, NoteModel>>[];
          for (var i = 0; i < values.length; i++) {
            final key = notesBox.keyAt(i);
            entries.add(MapEntry(key, values[i]));
          }

          // filter
          final filtered = <MapEntry<dynamic, NoteModel>>[];
          for (final entry in entries) {
            final n = entry.value;
            if (_query.isEmpty) {
              filtered.add(entry);
            } else {
              final hay = ('${n.title} ${n.content}').toLowerCase();
              if (hay.contains(_query)) filtered.add(entry);
            }
          }

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                notesBox.isEmpty ? 'No notes yet. Tap + to add one.' : 'No matching notes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          if (_isGrid) {
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final entry = filtered[idx];
                final key = entry.key as int;
                final note = entry.value;

                return _buildDismissibleNote(context, key, note);
              },
            );
          }

          // Use a builder that ensures each list item gets a fixed vertical
          // padding and the Dismissible/NoteTile has intrinsic height.
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final entry = filtered[index];
              final key = entry.key as int;
              final note = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildDismissibleNote(context, key, note),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDismissibleNote(BuildContext context, int key, NoteModel note) {
    final box = Hive.box<NoteModel>('notesBox');

    return Dismissible(
      key: ValueKey(key),
      background: Container(
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // capture note data for undo
        final removedNote = note;
        final removedKey = key;

        box.delete(removedKey);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                box.put(removedKey, removedNote);
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () async {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete note?'),
              content: const Text('This action cannot be undone.'),
              actions: [
                TextButton(onPressed: () => navigator.pop(false), child: const Text('Cancel')),
                TextButton(onPressed: () => navigator.pop(true), child: const Text('Delete')),
              ],
            ),
          );

          if (!mounted) return; // ensure it's safe to use UI after await

          if (confirm == true) {
            box.delete(key);
            messenger.showSnackBar(const SnackBar(content: Text('Note deleted')));
          }
        },
        child: NoteTile(
          note: note,
          onTap: () => _openEditor(note: note, key: key),
        ),
      ),
    );
  }
}

class _NotesSearch extends SearchDelegate<NoteModel?> {
  final Box<NoteModel> box;
  _NotesSearch(this.box);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final q = query.trim().toLowerCase();
    final results = box.values.where((n) => ('${n.title} ${n.content}').toLowerCase().contains(q)).toList();

    if (results.isEmpty) return const Center(child: Text('No results'));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final n = results[index];
        return ListTile(
          title: Text(n.title),
          subtitle: Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () => close(context, n),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.trim().toLowerCase();
    final results = q.isEmpty ? box.values.toList() : box.values.where((n) => ('${n.title} ${n.content}').toLowerCase().contains(q)).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final n = results[index];
        return ListTile(
          title: Text(n.title),
          subtitle: Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () => close(context, n),
        );
      },
    );
  }
}
