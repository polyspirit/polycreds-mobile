import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../state/vault.dart';
import '../../theme/app_colors.dart';
import '../../util/password.dart';
import '../../util/rich_text.dart';
import '../../widgets/common.dart';
import '../../widgets/note_view.dart';
import '../../widgets/sheets.dart';
import '../generator_screen.dart';

const _protocols = {
  'ssh': 22,
  'sftp': 22,
  'ftp': 21,
  'ftps': 990,
  'rdp': 3389,
  'vnc': 5900,
  'telnet': 23,
  'mysql': 3306,
  'postgres': 5432,
};

class CredentialEditScreen extends StatefulWidget {
  const CredentialEditScreen({super.key, this.credential, this.groupId});

  /// Null for a new credential.
  final Credential? credential;

  /// Preselected group for a new credential.
  final int? groupId;

  @override
  State<CredentialEditScreen> createState() => _CredentialEditScreenState();
}

class _CredentialEditScreenState extends State<CredentialEditScreen> {
  late final Credential? _orig = widget.credential;
  late bool _remote = _orig?.remote != null;
  late int? _groupId = _orig?.groupId ?? widget.groupId;
  late bool _favorite = _orig?.favorite ?? false;
  late String _protocol = _orig?.remote?.protocol ?? 'ssh';

  late final _name = TextEditingController(text: _orig?.name);
  late final _login = TextEditingController(text: _orig?.login);
  late final _password = TextEditingController(text: _orig?.password);
  late final _url = TextEditingController(text: _orig?.url);
  late final _host = TextEditingController(text: _orig?.remote?.host);
  late final _port = TextEditingController(text: '${_orig?.remote?.port ?? 22}');
  late final _note = QuillController(
    document: parseNote(_orig?.note),
    selection: const TextSelection.collapsed(offset: 0),
  );
  final _noteFocus = FocusNode();
  final _noteScroll = ScrollController();

  bool _saving = false;
  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
    _noteFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_name, _login, _password, _url, _host, _port]) {
      c.dispose();
    }
    _note.dispose();
    _noteFocus.dispose();
    _noteScroll.dispose();
    super.dispose();
  }

  Map<String, String> _validate() {
    final e = <String, String>{};
    if (_name.text.trim().isEmpty) e['name'] = context.l.enterName;
    if (_login.text.isEmpty) e['login'] = context.l.enterLogin;
    if (_password.text.isEmpty) e['password'] = context.l.enterPassword;
    if (_remote) {
      if (_host.text.trim().isEmpty) e['remote.host'] = context.l.enterHost;
      final port = int.tryParse(_port.text);
      if (port == null || port < 1 || port > 65535) e['remote.port'] = context.l.portRange;
    }
    return e;
  }

  Future<void> _save() async {
    final errors = _validate();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    final vault = context.read<Vault>();
    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'login': _login.text,
      'password': _password.text,
      'url': _url.text.trim().isEmpty ? null : _url.text.trim(),
      'note': isNoteEmpty(_note.document) ? null : serializeNote(_note.document),
      'favorite': _favorite,
      'group_id': _groupId ?? vault.rootGroupId,
      if (_remote)
        'remote': {'host': _host.text.trim(), 'port': int.parse(_port.text), 'protocol': _protocol}
      else if (_orig?.remote != null)
        'remote': null,
    };
    if (data['group_id'] == null) data.remove('group_id');

    setState(() => _saving = true);
    try {
      final saved = await vault.saveCredential(_orig?.id, data);
      if (mounted) Navigator.of(context).pop(saved);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errors = e.fieldErrors.map((k, v) => MapEntry(k, v.first)));
      if (e.fieldErrors.isEmpty) setState(() => _errors = {'_': e.message});
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
      options: [(root, context.l.noGroup), for (final g in vault.credentialGroups) (g.id, g.name)],
    );
    if (picked != null) setState(() => _groupId = picked == root ? null : picked);
  }

  Future<void> _pickProtocol() async {
    final picked = await pickOption<String>(
      context,
      title: context.l.protocol,
      selected: _protocol,
      options: [for (final p in _protocols.keys) (p, p.toUpperCase())],
    );
    if (picked == null) return;
    setState(() {
      // Keep a custom port, replace only the default one of the previous protocol.
      if (int.tryParse(_port.text) == _protocols[_protocol]) _port.text = '${_protocols[picked]}';
      _protocol = picked;
    });
  }

  Future<void> _generate() async {
    final p = await pickGeneratedPassword(context);
    if (p != null) _password.text = p;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    final strength = passwordStrength(_password.text);
    final strengthColor = switch (strength) {
      Strength.weak => c.danger,
      Strength.fair => c.star,
      _ => c.success,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: ModalBar(
              title: _orig == null ? context.l.newCredential : context.l.editCredential,
              saving: _saving,
              onDone: _save,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Segmented<bool>(
                  value: _remote,
                  onChanged: (v) => setState(() => _remote = v),
                  options: [
                    (false, context.l.siteTab, LucideIcons.globe),
                    (true, context.l.serverTab, LucideIcons.server),
                  ],
                ),
                if (_errors['_'] != null) ...[
                  const SizedBox(height: 12),
                  Text(_errors['_']!, style: TextStyle(color: c.danger, fontSize: 14)),
                ],
                const SizedBox(height: 14),
                _PickerField(
                  label: context.l.group,
                  icon: LucideIcons.folder,
                  value: vault.groupName(_groupId),
                  onTap: _pickGroup,
                ),
                const SizedBox(height: 14),
                AppField(
                  label: context.l.name,
                  controller: _name,
                  error: _errors['name'],
                  textInputAction: TextInputAction.next,
                ),
                if (_remote) ...[
                  const SizedBox(height: 14),
                  AppField(
                    label: context.l.host,
                    controller: _host,
                    mono: true,
                    hint: '10.0.0.12',
                    keyboardType: TextInputType.url,
                    error: _errors['remote.host'],
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      width: 120,
                      child: AppField(
                        label: context.l.port,
                        controller: _port,
                        mono: true,
                        keyboardType: TextInputType.number,
                        error: _errors['remote.port'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerField(label: context.l.protocol, value: _protocol.toUpperCase(), mono: true, onTap: _pickProtocol),
                    ),
                  ]),
                ],
                const SizedBox(height: 14),
                AppField(
                  label: context.l.login,
                  controller: _login,
                  error: _errors['login'],
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppField(
                  label: context.l.password,
                  controller: _password,
                  mono: true,
                  error: _errors['password'],
                  inputFormatters: [LengthLimitingTextInputFormatter(127)],
                  trailing: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Material(
                      color: c.accentSoft,
                      borderRadius: BorderRadius.circular(10),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _generate,
                        child: Tooltip(
                          message: context.l.generatePassword,
                          child: SizedBox(width: 40, height: 40, child: Icon(LucideIcons.wandSparkles, size: 20, color: c.accent)),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_password.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  StrengthBar(bars: strength.bars, color: strengthColor, label: strength.label),
                ],
                const SizedBox(height: 14),
                AppField(
                  label: context.l.link,
                  controller: _url,
                  hint: 'https://',
                  keyboardType: TextInputType.url,
                  error: _errors['url'],
                ),
                const SizedBox(height: 14),
                Text(context.l.note, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.text2)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _noteFocus.requestFocus(),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 64),
                    padding: EdgeInsets.all(_noteFocus.hasFocus ? 11 : 12).copyWith(
                      left: _noteFocus.hasFocus ? 13 : 14,
                      right: _noteFocus.hasFocus ? 13 : 14,
                    ),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _noteFocus.hasFocus ? c.accent : c.border, width: _noteFocus.hasFocus ? 2 : 1),
                    ),
                    child: NoteEditorField(
                      controller: _note,
                      focusNode: _noteFocus,
                      scrollController: _noteScroll,
                      scrollable: false,
                      fontSize: 16,
                      placeholder: context.l.credentialNoteHint,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 44,
                  child: Row(children: [
                    Icon(_favorite ? Icons.star_rounded : Icons.star_outline_rounded, size: 22, color: c.star),
                    const SizedBox(width: 8),
                    Expanded(child: Text(context.l.addFavorite, style: const TextStyle(fontSize: 16))),
                    AppSwitch(value: _favorite, onChanged: (v) => setState(() => _favorite = v)),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({required this.label, required this.value, required this.onTap, this.icon, this.mono = false});

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.text2)),
      const SizedBox(height: 6),
      Material(
        color: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: c.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.only(left: 14, right: 12),
            child: Row(children: [
              if (icon != null) ...[Icon(icon, size: 20, color: c.accent), const SizedBox(width: 10)],
              Expanded(
                child: Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: mono ? 15 : 16, fontFamily: mono ? kMono : kFont)),
              ),
              Icon(LucideIcons.chevronsUpDown, size: 18, color: c.text3),
            ]),
          ),
        ),
      ),
    ]);
  }
}
