import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/l10n.dart';
import '../../api/models.dart';
import '../../state/vault.dart';
import '../../theme/app_colors.dart';
import '../../util/clipboard.dart';
import '../../util/format.dart';
import '../../util/rich_text.dart';
import '../../widgets/common.dart';
import '../../widgets/items.dart';
import '../../widgets/note_view.dart';
import '../../widgets/sheets.dart';
import '../../widgets/toast.dart';
import 'credential_edit_screen.dart';

class CredentialScreen extends StatefulWidget {
  const CredentialScreen({super.key, required this.id});

  final int id;

  @override
  State<CredentialScreen> createState() => _CredentialScreenState();
}

class _CredentialScreenState extends State<CredentialScreen> {
  Credential? _cred;
  String? _error;
  bool _showPassword = false;
  bool _favBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final cred = await context.read<Vault>().fetchCredential(widget.id);
      if (mounted) setState(() => _cred = cred);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _toggleFavorite() async {
    final cred = _cred!;
    setState(() => _favBusy = true);
    try {
      final updated = await context.read<Vault>().saveCredential(cred.id, {'favorite': !cred.favorite});
      if (mounted) setState(() => _cred = updated);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _favBusy = false);
    }
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<Credential>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => CredentialEditScreen(credential: _cred)),
    );
    if (updated != null && mounted) setState(() => _cred = updated);
  }

  Future<void> _delete() async {
    final cred = _cred!;
    final vault = context.read<Vault>();
    final ok = await confirmDelete(
      context,
      title: context.l.deleteItemTitle(cred.name),
      message: context.l.deleteCredentialText,
      onConfirm: () => vault.deleteCredential(cred.id),
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    final cred = _cred;
    final summary = vault.credentials.where((e) => e.id == widget.id).firstOrNull;
    final groupId = cred?.groupId ?? summary?.groupId;
    final backLabel = vault.isRoot(groupId) ? context.l.tabVault : vault.groupName(groupId);

    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(children: [
              BackLink(label: backLabel),
              const Spacer(),
              if (cred != null) TextLink(label: context.l.edit, bold: true, onTap: _edit),
            ]),
          ),
          Expanded(
            child: cred == null
                ? (_error != null ? ErrorRetry(message: _error!, onRetry: _load) : const CenteredLoader())
                : ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 32), children: [
                    _header(cred, vault),
                    const SizedBox(height: 18),
                    cred.remote != null ? _remoteFields(cred) : _siteFields(cred),
                    if (cred.remote != null) ...[
                      const SizedBox(height: 18),
                      SectionLabel(context.l.connectionCommand),
                      const SizedBox(height: 8),
                      _command(cred),
                    ],
                    if (notePlainText(cred.note).isNotEmpty) ...[
                      const SizedBox(height: 18),
                      SectionLabel(context.l.note),
                      const SizedBox(height: 8),
                      CardBox(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: NoteView(raw: cred.note, fontSize: 16),
                      ),
                    ],
                    if (cred.updatedAt != null) ...[
                      const SizedBox(height: 18),
                      Text(
                          cred.createdAt != null
                              ? context.l.createdModified(
                                  formatDate(cred.createdAt, withYear: true), formatDate(cred.updatedAt, withYear: true))
                              : context.l.modifiedOn(formatDate(cred.updatedAt, withYear: true)),
                          textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.text2)),
                    ],
                    const SizedBox(height: 18),
                    AppButton(
                      label: context.l.deleteCredential,
                      icon: LucideIcons.trash2,
                      kind: ButtonKind.dangerOutline,
                      height: 50,
                      onPressed: _delete,
                    ),
                  ]),
          ),
        ]),
      ),
    );
  }

  Widget _header(Credential cred, Vault vault) {
    final c = context.c;
    return Row(children: [
      CredentialTile(credential: cred, size: 60),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cred.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 4),
          Row(children: [
            if (cred.remote != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: c.successSoft, borderRadius: BorderRadius.circular(6)),
                child: Text(cred.remote!.protocol.toUpperCase(),
                    style: TextStyle(fontFamily: kMono, fontSize: 12, fontWeight: FontWeight.w600, color: c.success)),
              ),
              const SizedBox(width: 8),
            ] else ...[
              Icon(LucideIcons.folder, size: 15, color: c.text2),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(vault.groupName(cred.groupId),
                  overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: c.text2)),
            ),
          ]),
        ]),
      ),
      _favBusy
          ? const SizedBox(width: 44, height: 44, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
          : Semantics(
              toggled: cred.favorite,
              child: Material(
                color: c.surface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _toggleFavorite,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      cred.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 26,
                      color: cred.favorite ? c.star : c.text2,
                      semanticLabel: cred.favorite ? context.l.removeFavorite : context.l.addFavorite,
                    ),
                  ),
                ),
              ),
            ),
    ]);
  }

  Widget _passwordRow(Credential cred) {
    final c = context.c;
    return _FieldRow(
      label: context.l.password,
      value: _showPassword
          ? ColoredPassword(cred.password, fontSize: 16)
          : Text('•' * cred.password.length.clamp(8, 16),
              style: const TextStyle(fontFamily: kMono, fontSize: 17, letterSpacing: 2)),
      actions: [
        IconBtn(
          icon: _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
          label: _showPassword ? context.l.hidePassword : context.l.showPassword,
          onPressed: () => setState(() => _showPassword = !_showPassword),
        ),
        IconBtn(
          icon: LucideIcons.copy,
          label: context.l.copyPassword,
          size: 20,
          color: c.accent,
          onPressed: () => copyToClipboard(context, cred.password, title: context.l.copiedPassword),
        ),
      ],
    );
  }

  Widget _copyRow(
    String label,
    String value, {
    required String copyLabel,
    required String copiedTitle,
    bool mono = false,
    bool secret = false,
  }) =>
      _FieldRow(
        label: label,
        value: SelectableText(value, style: TextStyle(fontSize: mono ? 16 : 17, fontFamily: mono ? kMono : kFont)),
        actions: [
          IconBtn(
            icon: LucideIcons.copy,
            label: copyLabel,
            size: 20,
            color: context.c.accent,
            onPressed: () => copyToClipboard(context, value, title: copiedTitle, secret: secret),
          ),
        ],
      );

  Widget _siteFields(Credential cred) {
    final c = context.c;
    final url = cred.url ?? '';
    return CardList(children: [
      _copyRow(context.l.login, cred.login,
          copyLabel: context.l.copyLogin, copiedTitle: context.l.copiedLogin, secret: true),
      _passwordRow(cred),
      if (url.isNotEmpty)
        _FieldRow(
          label: context.l.link,
          value: Text(displayUrl(url), style: TextStyle(fontSize: 17, color: c.accent)),
          onTap: () => _open(url),
          actions: [
            IconBtn(icon: LucideIcons.externalLink, label: context.l.openLink, size: 20, color: c.accent, onPressed: () => _open(url)),
          ],
        ),
    ]);
  }

  Widget _remoteFields(Credential cred) {
    final c = context.c;
    final r = cred.remote!;
    Widget cell(String label, String value) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 13, color: c.text2)),
              Text(value, style: const TextStyle(fontFamily: kMono, fontSize: 16)),
            ]),
          ),
        );
    return CardList(children: [
      _copyRow(context.l.host, r.host, copyLabel: context.l.copyHost, copiedTitle: context.l.copiedHost, mono: true),
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          cell(context.l.port, '${r.port}'),
          VerticalDivider(width: 1, thickness: 1, color: c.border),
          cell(context.l.protocol, r.protocol),
        ]),
      ),
      _copyRow(context.l.login, cred.login,
          copyLabel: context.l.copyLogin, copiedTitle: context.l.copiedLogin, secret: true),
      _passwordRow(cred),
      if ((cred.url ?? '').isNotEmpty)
        _FieldRow(
          label: context.l.link,
          value: Text(displayUrl(cred.url!), style: TextStyle(fontSize: 17, color: c.accent)),
          onTap: () => _open(cred.url!),
          actions: [
            IconBtn(
                icon: LucideIcons.externalLink, label: context.l.openLink, size: 20, color: c.accent, onPressed: () => _open(cred.url!)),
          ],
        ),
    ]);
  }

  Widget _command(Credential cred) {
    final c = context.c;
    final cmd = connectionCommand(cred);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Expanded(child: SelectableText(cmd, style: const TextStyle(fontFamily: kMono, fontSize: 14))),
        const SizedBox(width: 8),
        Material(
          color: c.accent,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => copyToClipboard(context, cmd, title: context.l.copiedCommand, secret: false),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: Text(context.l.copy, style: TextStyle(color: c.onAccent, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _open(String url) async {
    final uri = launchableUrl(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) showToast(context, title: context.l.cantOpenLink, icon: LucideIcons.circleAlert);
    }
  }
}

String connectionCommand(Credential cred) {
  final r = cred.remote!;
  final user = cred.login;
  return switch (r.protocol.toLowerCase()) {
    'ssh' => 'ssh $user@${r.host} -p ${r.port}',
    'sftp' => 'sftp -P ${r.port} $user@${r.host}',
    'ftp' || 'ftps' => '${r.protocol.toLowerCase()}://$user@${r.host}:${r.port}',
    'mysql' => 'mysql -h ${r.host} -P ${r.port} -u $user -p',
    'postgres' || 'postgresql' => 'psql -h ${r.host} -p ${r.port} -U $user',
    _ => '${r.protocol.toLowerCase()}://$user@${r.host}:${r.port}',
  };
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value, this.actions = const [], this.onTap});

  final String label;
  final Widget value;
  final List<Widget> actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 6, top: 8, bottom: 8),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontSize: 13, color: c.text2)),
                value,
              ]),
            ),
            ...actions,
          ]),
        ),
      ),
    );
  }
}

/// Password with digits and symbols tinted, as in the design.
class ColoredPassword extends StatelessWidget {
  const ColoredPassword(this.password, {super.key, this.fontSize = 16, this.align = TextAlign.start, this.weight});

  final String password;
  final double fontSize;
  final TextAlign align;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final digit = RegExp('[0-9]');
    final letter = RegExp('[A-Za-zА-Яа-яЁё]');
    return SelectableText.rich(
      TextSpan(children: [
        for (final ch in password.characters)
          TextSpan(
            text: ch,
            style: TextStyle(color: digit.hasMatch(ch) ? c.accent : (letter.hasMatch(ch) ? c.text : c.star)),
          ),
      ]),
      textAlign: align,
      style: TextStyle(fontFamily: kMono, fontSize: fontSize, fontWeight: weight, height: 1.35),
    );
  }
}
