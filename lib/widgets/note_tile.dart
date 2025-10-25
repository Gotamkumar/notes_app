import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'package:intl/intl.dart';

class NoteTile extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;

  const NoteTile({super.key, required this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd().add_jm();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              // Content snippet: use a fixed max height so it behaves well in lists and grids.
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                child: Text(
                  note.content.isEmpty ? 'No additional content' : note.content,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    df.format(note.lastModified),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
