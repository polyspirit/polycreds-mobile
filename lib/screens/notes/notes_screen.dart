import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../api/models.dart';
import '../../state/vault.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/items.dart';
import '../home_shell.dart';
import '../vault/group_edit_screen.dart';
import 'note_edit_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _query = TextEditingController();

  /// null = all, -1 = favorites, otherwise group id.
  int? _filter;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _newNote() => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => NoteEditScreen(groupId: (_filter ?? -1) > 0 ? _filter : null),
      ));

  void _groupEdit(Group? g) => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
      fullscreenDialog: true, builder: (_) => GroupEditScreen(group: g, type: GroupType.note)));

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    final q = _query.text.trim().toLowerCase();
    final groups = vault.noteGroups;
    if (_filter != null && _filter! > 0 && vault.groupById(_filter) == null) _filter = null;

    final notes = vault.notes.where((n) {
      if (_filter == -1 && !n.favorite) return false;
      if (_filter != null && _filter! > 0 && n.groupId != _filter) return false;
      return q.isEmpty || n.name.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));

    Widget list;
    if (!vault.loaded && vault.loading) {
      list = const CenteredLoader();
    } else if (!vault.loaded && vault.error != null) {
      list = ErrorRetry(message: vault.error!, onRetry: vault.load);
    } else {
      list = RefreshIndicator(
        color: c.accent,
        onRefresh: vault.load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, tabBarInset(context)),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            SearchBox(hint: context.l.searchNotesHint, controller: _query, onChanged: (_) => setState(() {})),
            const SizedBox(height: 16),
            ChipsRow(children: [
              FilterChipPill(
                label: context.l.allCount(vault.notes.length),
                selected: _filter == null,
                onTap: () => setState(() => _filter = null),
              ),
              FilterChipPill(label: context.l.favorites, selected: _filter == -1, onTap: () => setState(() => _filter = -1)),
              for (final g in groups)
                FilterChipPill(
                  label: g.name,
                  selected: _filter == g.id,
                  onTap: () => setState(() => _filter = g.id),
                  onLongPress: () => _groupEdit(g),
                ),
              Semantics(
                button: true,
                label: context.l.newNoteGroup,
                child: Material(
                  color: c.surface,
                  shape: StadiumBorder(side: BorderSide(color: c.border)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _groupEdit(null),
                    child: SizedBox(width: 44, height: 34, child: Icon(LucideIcons.folderPlus, size: 18, color: c.text2)),
                  ),
                ),
              ),
            ]),
            if (_filter != null && _filter! > 0) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: const Offset(-10, 0),
                  child: TextLink(
                    label: context.l.editGroup,
                    fontSize: 14,
                    onTap: () => _groupEdit(vault.groupById(_filter)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (notes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(children: [
                  Icon(LucideIcons.notebookPen, size: 44, color: c.text3),
                  const SizedBox(height: 12),
                  Text(
                    vault.notes.isEmpty ? context.l.noNotes : context.l.nothingFound,
                    style: TextStyle(color: c.text2, fontSize: 16),
                  ),
                  if (vault.notes.isEmpty) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 240,
                      child: AppButton(label: context.l.newNote, icon: LucideIcons.plus, height: 50, onPressed: _newNote),
                    ),
                  ],
                ]),
              )
            else
              for (final n in notes) ...[NoteCard(note: n), const SizedBox(height: 10)],
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              Expanded(child: PageTitle(context.l.tabNotes)),
              IconBtn(
                icon: LucideIcons.plus,
                label: context.l.newNote,
                color: c.onAccent,
                background: c.accent,
                onPressed: _newNote,
              ),
            ]),
          ),
          Expanded(child: list),
        ]),
      ),
    );
  }
}
