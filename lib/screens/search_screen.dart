import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../api/models.dart';
import '../state/vault.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/items.dart';
import 'home_shell.dart';
import 'vault/group_screen.dart';

enum _Scope { all, credentials, notes, groups }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  _Scope _scope = _Scope.all;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _match(String? s, String q) => s != null && s.toLowerCase().contains(q);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    final q = _query.text.trim().toLowerCase();

    final creds = q.isEmpty
        ? <CredentialSummary>[]
        : vault.credentials.where((e) => _match(e.name, q) || _match(e.login, q) || _match(e.url, q) || _match(e.remote?.host, q)).toList();
    final notes = q.isEmpty ? <NoteSummary>[] : vault.notes.where((e) => _match(e.name, q)).toList();
    final groups = q.isEmpty ? <Group>[] : vault.groups.where((e) => _match(e.name, q)).toList();
    final total = creds.length + notes.length + groups.length;

    bool show(_Scope s) => _scope == _Scope.all || _scope == s;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 10, 0),
            child: Row(children: [
              Expanded(
                child: SearchBox(
                  hint: context.l.search,
                  controller: _query,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              TextLink(label: context.l.cancel, fontSize: 16, onTap: () => Navigator.of(context).pop()),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, tabBarInset(context)),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                if (q.isNotEmpty) ...[
                  ChipsRow(children: [
                    FilterChipPill(
                        label: context.l.allCount(total), selected: _scope == _Scope.all, onTap: () => setState(() => _scope = _Scope.all)),
                    FilterChipPill(
                        label: context.l.credentialsN(creds.length),
                        selected: _scope == _Scope.credentials,
                        onTap: () => setState(() => _scope = _Scope.credentials)),
                    FilterChipPill(
                        label: context.l.notesN(notes.length),
                        selected: _scope == _Scope.notes,
                        onTap: () => setState(() => _scope = _Scope.notes)),
                    FilterChipPill(
                        label: context.l.groupsN(groups.length),
                        selected: _scope == _Scope.groups,
                        onTap: () => setState(() => _scope = _Scope.groups)),
                  ]),
                  if (total == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(children: [
                        Icon(LucideIcons.searchX, size: 40, color: c.text3),
                        const SizedBox(height: 12),
                        Text(context.l.nothingFound, style: TextStyle(color: c.text2, fontSize: 16)),
                      ]),
                    ),
                  if (show(_Scope.credentials) && creds.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SectionLabel(context.l.credentials),
                    const SizedBox(height: 10),
                    CardList(children: [
                      for (final cr in creds) CredentialRow(credential: cr, withGroup: true, highlight: _query.text.trim()),
                    ]),
                  ],
                  if (show(_Scope.notes) && notes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SectionLabel(context.l.notes),
                    const SizedBox(height: 10),
                    for (final n in notes) ...[
                      NoteCard(note: n, highlight: _query.text.trim()),
                      const SizedBox(height: 10),
                    ],
                  ],
                  if (show(_Scope.groups) && groups.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SectionLabel(context.l.groups),
                    const SizedBox(height: 10),
                    CardList(children: [
                      for (final g in groups)
                        GroupRow(
                          name: g.name,
                          highlight: _query.text.trim(),
                          icon: g.type == GroupType.note ? LucideIcons.folderOpen : LucideIcons.folder,
                          count: g.type == GroupType.note ? vault.notesIn(g.id).length : vault.credentialsIn(g.id).length,
                          onTap: g.type == GroupType.credential
                              ? () => Navigator.of(context)
                                  .push(MaterialPageRoute<void>(builder: (_) => GroupScreen(groupId: g.id)))
                              : null,
                        ),
                    ]),
                  ],
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(context.l.searchHint,
                        textAlign: TextAlign.center, style: TextStyle(color: c.text2, fontSize: 15)),
                  ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
