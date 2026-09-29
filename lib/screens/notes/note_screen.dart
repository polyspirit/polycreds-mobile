import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../api/models.dart';
import '../../state/vault.dart';
import '../../theme/app_colors.dart';
import '../../util/clipboard.dart';
import '../../util/format.dart';
import '../../util/rich_text.dart';
import '../../widgets/common.dart';
import '../../widgets/note_view.dart';
import '../../widgets/sheets.dart';
import '../../widgets/toast.dart';
import 'note_edit_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key, required this.id});

  final int id;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  Note? _note;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final n = await context.read<Vault>().fetchNote(widget.id);
      if (mounted) setState(() => _note = n);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final n = await context.read<Vault>().saveNote(_note!.id, {'favorite': !_note!.favorite});
      if (mounted) setState(() => _note = n);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _edit() async {
    final n = await Navigator.of(context).push<Note>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => NoteEditScreen(note: _note)),
    );
    if (n != null && mounted) setState(() => _note = n);
  }

  Future<void> _more() async {
    final action = await pickOption<String>(
      context,
      title: _note!.name,
      selected: null,
      options: [('copy', context.l.copyText), ('delete', context.l.deleteNote)],
    );
    if (!mounted) return;
    if (action == 'copy') {
      copyToClipboard(context, notePlainText(_note!.note), title: context.l.copiedText, secret: false);
    } else if (action == 'delete') {
      final vault = context.read<Vault>();
      final ok = await confirmDelete(
        context,
        title: context.l.deleteItemTitle(_note!.name),
        message: context.l.deleteNoteText,
        onConfirm: () => vault.deleteNote(_note!.id),
      );
      if (ok && mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    final note = _note;
    final meta = note == null
        ? ''
        : [
            if (!vault.isRoot(note.groupId)) vault.groupName(note.groupId),
            if (note.updatedAt != null) context.l.noteModifiedOn(formatDate(note.updatedAt)),
          ].join(' · ');

    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(children: [
              BackLink(label: context.l.tabNotes),
              const Spacer(),
              if (note != null) ...[
                IconBtn(
                  icon: LucideIcons.ellipsis,
                  label: context.l.more,
                  color: c.accent,
                  onPressed: _more,
                ),
                Semantics(
                  toggled: note.favorite,
                  child: IconButton(
                    tooltip: note.favorite ? context.l.removeFavorite : context.l.addFavorite,
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      note.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: note.favorite ? c.star : c.accent,
                      size: 26,
                    ),
                  ),
                ),
                TextLink(label: context.l.edit, bold: true, onTap: _edit),
              ],
            ]),
          ),
          Expanded(
            child: note == null
                ? (_error != null ? ErrorRetry(message: _error!, onRetry: _load) : const CenteredLoader())
                : ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 40), children: [
                    Text(note.name,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.2)),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(LucideIcons.folder, size: 15, color: c.text2),
                        const SizedBox(width: 6),
                        Expanded(child: Text(meta, style: TextStyle(fontSize: 14, color: c.text2))),
                      ]),
                    ],
                    const SizedBox(height: 16),
                    if (notePlainText(note.note).isEmpty)
                      Text(context.l.emptyNote, style: TextStyle(color: c.text3, fontSize: 17))
                    else
                      NoteView(raw: note.note),
                  ]),
          ),
        ]),
      ),
    );
  }
}
