import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../api/models.dart';
import '../screens/notes/note_screen.dart';
import '../screens/vault/credential_screen.dart';
import '../state/vault.dart';
import '../theme/app_colors.dart';
import '../util/clipboard.dart';
import '../util/format.dart';
import 'common.dart';
import 'toast.dart';

Future<void> openCredential(BuildContext context, int id) => Navigator.of(context, rootNavigator: true)
    .push(MaterialPageRoute<void>(builder: (_) => CredentialScreen(id: id)));

Future<void> openNote(BuildContext context, int id) =>
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(builder: (_) => NoteScreen(id: id)));

Future<void> copyCredentialPassword(BuildContext context, int id) async {
  try {
    final cred = await context.read<Vault>().fetchCredential(id);
    if (context.mounted) await copyToClipboard(context, cred.password, title: context.l.copiedPassword);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

class CredentialTile extends StatelessWidget {
  const CredentialTile({super.key, required this.credential, this.size = 36});

  final CredentialSummary credential;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return credential.isRemote
        ? ItemTile(icon: LucideIcons.server, bg: c.successSoft, fg: c.success, size: size)
        : ItemTile(letter: initial(credential.name), bg: c.accentSoft, fg: c.accent, size: size);
  }
}

/// Server: "SSH · root@10.0.0.12" ([short]: "SSH · root"). Website: login, or URL
/// when the server does not send logins in lists.
String credentialSubtitle(CredentialSummary cr, Vault vault, {bool withGroup = false, bool short = false}) {
  final parts = <String>[];
  if (withGroup) parts.add(vault.groupName(cr.groupId));
  final login = cr.login ?? '';
  final r = cr.remote;
  if (r != null) {
    final target = short ? login : (login.isEmpty ? r.host : '$login@${r.host}');
    parts.add([r.protocol.toUpperCase(), if (target.isNotEmpty) target].join(' · '));
  } else if (login.isNotEmpty) {
    parts.add(login);
  } else if ((cr.url ?? '').isNotEmpty) {
    parts.add(displayUrl(cr.url!));
  }
  return parts.join(' · ');
}

/// Row in credential lists: tile, name (+star), subtitle, copy-password button.
class CredentialRow extends StatelessWidget {
  const CredentialRow({super.key, required this.credential, this.withGroup = false, this.highlight});

  final CredentialSummary credential;
  final bool withGroup;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    final sub = credentialSubtitle(credential, vault, withGroup: withGroup);
    return InkWell(
      onTap: () => openCredential(context, credential.id),
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 6),
          child: Row(children: [
            CredentialTile(credential: credential),
            const SizedBox(width: 12),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: HighlightText(
                      credential.name,
                      query: highlight,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (credential.favorite) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.star_rounded, size: 16, color: c.star),
                  ],
                ]),
                if (sub.isNotEmpty)
                  Text(sub,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.text2)),
              ]),
            ),
            IconBtn(
              icon: LucideIcons.copy,
              label: context.l.copyPassword,
              size: 20,
              onPressed: () => copyCredentialPassword(context, credential.id),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Group row: folder icon, name, count, chevron.
class GroupRow extends StatelessWidget {
  const GroupRow({super.key, required this.name, required this.count, this.onTap, this.highlight, this.icon});

  final String name;
  final int count;
  final VoidCallback? onTap;
  final String? highlight;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            Icon(icon ?? LucideIcons.folder, size: 22, color: c.accent),
            const SizedBox(width: 12),
            Expanded(child: HighlightText(name, query: highlight, style: const TextStyle(fontSize: 16))),
            Text('$count', style: TextStyle(fontSize: 14, color: c.text2)),
            const SizedBox(width: 12),
            Icon(LucideIcons.chevronRight, size: 18, color: c.text3),
          ]),
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, this.highlight});

  final NoteSummary note;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    final meta = [
      if (!vault.isRoot(note.groupId)) vault.groupName(note.groupId),
      if (note.updatedAt != null) formatDate(note.updatedAt),
    ].join(' · ');
    return CardBox(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => openNote(context, note.id),
      child: Row(children: [
        ItemTile(icon: LucideIcons.fileText, bg: c.surface2, fg: c.text2),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: HighlightText(note.name,
                    query: highlight, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              if (note.favorite) Icon(Icons.star_rounded, size: 18, color: c.star),
            ]),
            if (meta.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(meta, style: TextStyle(fontSize: 12.5, color: c.text3)),
            ],
          ]),
        ),
      ]),
    );
  }
}

/// Text with the search match in accent bold.
class HighlightText extends StatelessWidget {
  const HighlightText(this.text, {super.key, this.query, required this.style});

  final String text;
  final String? query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final q = query?.trim() ?? '';
    final i = q.isEmpty ? -1 : text.toLowerCase().indexOf(q.toLowerCase());
    if (i < 0) return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
    final c = context.c;
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: text.substring(0, i)),
        TextSpan(
          text: text.substring(i, i + q.length),
          style: TextStyle(color: c.accent, fontWeight: FontWeight.w700),
        ),
        TextSpan(text: text.substring(i + q.length)),
      ]),
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
