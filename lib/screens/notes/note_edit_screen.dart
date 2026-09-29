import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../state/vault.dart';
import '../../theme/app_colors.dart';
import '../../util/rich_text.dart';
import '../../widgets/common.dart';
import '../../widgets/note_view.dart';
import '../../widgets/sheets.dart';
import '../../widgets/toast.dart';

class NoteEditScreen extends StatefulWidget {
  const NoteEditScreen({super.key, this.note, this.groupId});

  final Note? note;
  final int? groupId;

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final _title = TextEditingController(text: widget.note?.name);
  late final _controller = QuillController(
    document: parseNote(widget.note?.note),
    selection: const TextSelection.collapsed(offset: 0),
  );
  final _focus = FocusNode();
  final _scroll = ScrollController();
  late int? _groupId = widget.note?.groupId ?? widget.groupId;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _controller.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final vault = context.read<Vault>();
    var name = _title.text.trim();
    if (name.isEmpty) {
      // Use the first line of text as a title, like most note apps.
      name = _controller.document.toPlainText().trim().split('\n').first;
      if (name.length > 60) name = '${name.substring(0, 60)}…';
    }
    if (name.isEmpty) {
      showToast(context, title: context.l.enterNoteTitle, icon: LucideIcons.circleAlert);
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await vault.saveNote(widget.note?.id, {
        'name': name,
        'note': serializeNote(_controller.document),
        'group_id': _groupId ?? vault.rootGroupId,
      }..removeWhere((k, v) => k == 'group_id' && v == null));
      if (mounted) Navigator.of(context).pop(saved);
    } on ApiException catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickGroup() async {
    final vault = context.read<Vault>();
    final root = vault.rootGroupId ?? -1;
    final picked = await pickOption<int>(
      context,
      title: context.l.group,
      icon: LucideIcons.folder,
      selected: vault.isRoot(_groupId) ? root : _groupId,
      options: [(root, context.l.noGroup), for (final g in vault.noteGroups) (g.id, g.name)],
    );
    if (picked != null) setState(() => _groupId = picked == root ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: ModalBar(
              title: '',
              doneLabel: context.l.done,
              saving: _saving,
              onDone: _save,
              center: Material(
                color: c.surface2,
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _pickGroup,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.folder, size: 16, color: c.text),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(vault.groupName(_groupId),
                            overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 4),
                      Icon(LucideIcons.chevronDown, size: 16, color: c.text2),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: TextField(
              controller: _title,
              autofocus: widget.note == null,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _focus.requestFocus(),
              maxLength: 127,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: c.text),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
                hintText: context.l.name,
                hintStyle: TextStyle(color: c.text3),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _focus.requestFocus(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NoteEditorField(
                  controller: _controller,
                  focusNode: _focus,
                  scrollController: _scroll,
                  placeholder: context.l.noteBodyHint,
                ),
              ),
            ),
          ),
          _FormatBar(controller: _controller),
        ]),
      ),
    );
  }
}

class _FormatBar extends StatelessWidget {
  const _FormatBar({required this.controller});

  final QuillController controller;

  bool _has(Attribute a) {
    final attrs = controller.getSelectionStyle().attributes;
    final v = attrs[a.key];
    if (v == null) return false;
    return a.value == null || a.value == true || v.value == a.value;
  }

  void _toggle(Attribute a) =>
      controller.formatSelection(_has(a) ? Attribute.clone(a, null) : a);

  Future<void> _link(BuildContext context) async {
    final current = controller.getSelectionStyle().attributes[Attribute.link.key]?.value as String?;
    final input = TextEditingController(text: current ?? 'https://');
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.c.surface,
        title: Text(ctx.l.link),
        content: TextField(
          controller: input,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'https://'),
        ),
        actions: [
          if (current != null) TextButton(onPressed: () => Navigator.pop(ctx, ''), child: Text(ctx.l.removeLink)),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.l.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, input.text.trim()), child: Text(ctx.l.done)),
        ],
      ),
    );
    input.dispose();
    if (url == null) return;
    controller.formatSelection(url.isEmpty ? Attribute.clone(Attribute.link, null) : LinkAttribute(url));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        Widget btn(String label, Attribute a, Widget child) {
          final on = _has(a);
          return Semantics(
            button: true,
            toggled: on,
            label: label,
            excludeSemantics: true,
            child: Material(
              color: on ? c.accentSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _toggle(a),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(color: on ? c.accent : c.text, size: 22),
                      child: DefaultTextStyle(style: TextStyle(color: on ? c.accent : c.text, fontSize: 18), child: child),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final linkOn = _has(Attribute.link);
        return Container(
          decoration: BoxDecoration(color: c.bg, border: Border(top: BorderSide(color: c.border))),
          padding: EdgeInsets.fromLTRB(6, 8, 6, 8 + MediaQuery.of(context).padding.bottom),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            btn(context.l.fmtBold, Attribute.bold, const Text('B', style: TextStyle(fontWeight: FontWeight.w800))),
            btn(context.l.fmtItalic, Attribute.italic,
                const Text('I', style: TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic, fontSize: 19))),
            btn(context.l.fmtUnderline, Attribute.underline,
                const Text('U', style: TextStyle(decoration: TextDecoration.underline))),
            btn(context.l.fmtHeading, Attribute.h2, const Text('H', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
            btn(context.l.fmtBulletList, Attribute.ul, const Icon(LucideIcons.list)),
            btn(context.l.fmtNumberedList, Attribute.ol, const Icon(LucideIcons.listOrdered)),
            btn(context.l.fmtCode, Attribute.codeBlock, const Icon(LucideIcons.code)),
            Semantics(
              button: true,
              toggled: linkOn,
              label: context.l.link,
              excludeSemantics: true,
              child: Material(
                color: linkOn ? c.accentSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _link(context),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(LucideIcons.link, size: 22, color: linkOn ? c.accent : c.text),
                  ),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}
