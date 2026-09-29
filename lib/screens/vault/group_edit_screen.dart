import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../state/vault.dart';
import '../../theme/app_colors.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';
import '../../widgets/sheets.dart';

class GroupEditScreen extends StatefulWidget {
  const GroupEditScreen({super.key, this.group, required this.type});

  final Group? group;
  final GroupType type;

  @override
  State<GroupEditScreen> createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends State<GroupEditScreen> {
  late final _name = TextEditingController(text: widget.group?.name);
  late GroupType _type = widget.group?.type ?? widget.type;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l.enterName);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<Vault>().saveGroup(widget.group?.id, name, _type);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.field('name') ?? e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final g = widget.group!;
    final vault = context.read<Vault>();
    final count = g.type == GroupType.note ? vault.notesIn(g.id).length : vault.credentialsIn(g.id).length;
    final what = g.type == GroupType.note ? notesCount(count) : credentialsCount(count);
    final ok = await confirmDelete(
      context,
      title: context.l.deleteGroupTitle(g.name),
      message: count == 0
          ? context.l.deleteEmptyGroupText
          : context.l.deleteGroupText(what),
      action: context.l.deleteGroup,
      onConfirm: () => vault.deleteGroup(g.id),
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    final g = widget.group;
    final count = g == null
        ? 0
        : (g.type == GroupType.note ? vault.notesIn(g.id).length : vault.credentialsIn(g.id).length);

    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: ModalBar(
              title: g == null ? context.l.newGroup : context.l.groupTitle,
              doneLabel: context.l.done,
              saving: _saving,
              onDone: _save,
            ),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 24), children: [
              AppField(
                label: context.l.name,
                controller: _name,
                autofocus: g == null,
                height: 52,
                fontSize: 17,
                error: _error,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 20),
              Text(context.l.whatStored,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.text2)),
              const SizedBox(height: 8),
              _TypeOption(
                selected: _type == GroupType.credential,
                icon: LucideIcons.keyRound,
                title: context.l.credentials,
                subtitle: context.l.credentialsDesc,
                onTap: () => setState(() => _type = GroupType.credential),
              ),
              const SizedBox(height: 8),
              _TypeOption(
                selected: _type == GroupType.note,
                icon: LucideIcons.fileText,
                title: context.l.notes,
                subtitle: context.l.notesDesc,
                onTap: () => setState(() => _type = GroupType.note),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(14)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(LucideIcons.info, size: 18, color: c.text2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${g != null ? context.l.groupContains(g.type == GroupType.note ? notesCount(count) : credentialsCount(count)) : ''}'
                      '${context.l.groupTypeHint}',
                      style: TextStyle(fontSize: 14, height: 1.45, color: c.text2),
                    ),
                  ),
                ]),
              ),
              if (g != null) ...[
                const SizedBox(height: 32),
                AppButton(
                  label: context.l.deleteGroup,
                  icon: LucideIcons.trash2,
                  kind: ButtonKind.dangerOutline,
                  height: 52,
                  onPressed: _delete,
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? c.accent : c.border, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: selected ? 15 : 16, vertical: selected ? 13 : 14),
            child: Row(children: [
              ItemTile(
                icon: icon,
                size: 40,
                bg: selected ? c.accentSoft : c.surface2,
                fg: selected ? c.accent : c.text2,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: c.text2)),
                ]),
              ),
              if (selected) Icon(LucideIcons.circleCheck, size: 22, color: c.accent),
            ]),
          ),
        ),
      ),
    );
  }
}
