import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/vault.dart';
import '../../theme/app_colors.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';
import '../../widgets/items.dart';
import '../home_shell.dart';
import 'credential_edit_screen.dart';
import 'group_edit_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  bool _byDate = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    final group = vault.groupById(widget.groupId);
    if (group == null) {
      // Deleted meanwhile.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold();
    }
    final items = vault.credentialsIn(group.id);
    if (_byDate) {
      items.sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(children: [
              BackLink(label: context.l.tabVault),
              const Spacer(),
              IconBtn(
                icon: LucideIcons.pencil,
                label: context.l.editGroup,
                color: c.accent,
                onPressed: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
                    fullscreenDialog: true, builder: (_) => GroupEditScreen(group: group, type: group.type))),
              ),
              IconBtn(
                icon: LucideIcons.plus,
                label: context.l.newCredentialInGroup,
                color: c.accent,
                onPressed: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
                    fullscreenDialog: true, builder: (_) => CredentialEditScreen(groupId: group.id))),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  PageTitle(group.name),
                  const SizedBox(height: 2),
                  Text(credentialsCount(items.length), style: TextStyle(fontSize: 15, color: c.text2)),
                ]),
              ),
              Material(
                color: c.surface,
                shape: StadiumBorder(side: BorderSide(color: c.border)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => setState(() => _byDate = !_byDate),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.arrowUpDown, size: 16, color: c.text),
                      const SizedBox(width: 6),
                      Text(_byDate ? context.l.byDate : context.l.byName, style: const TextStyle(fontSize: 14)),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
          Expanded(
            child: RefreshIndicator(
              color: c.accent,
              onRefresh: vault.load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, tabBarInset(context)),
                children: [
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Text(context.l.groupNoCredentials,
                          textAlign: TextAlign.center, style: TextStyle(color: c.text2, fontSize: 15)),
                    )
                  else
                    CardList(children: [for (final cr in items) CredentialRow(credential: cr)]),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
