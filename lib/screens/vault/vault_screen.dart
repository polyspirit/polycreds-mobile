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
import '../search_screen.dart';
import 'credential_edit_screen.dart';
import 'group_edit_screen.dart';
import 'group_screen.dart';

enum _Filter { all, favorite, sites, servers }

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  _Filter _filter = _Filter.all;

  void _newCredential() => Navigator.of(context, rootNavigator: true)
      .push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => const CredentialEditScreen()));

  void _newGroup() => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
      fullscreenDialog: true, builder: (_) => const GroupEditScreen(type: GroupType.credential)));

  void _search() => Navigator.of(context).push(PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const SearchScreen(),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ));

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();

    Widget body;
    if (!vault.loaded && vault.loading) {
      body = const CenteredLoader();
    } else if (!vault.loaded && vault.error != null) {
      body = ErrorRetry(message: vault.error!, onRetry: vault.load);
    } else if (vault.credentials.isEmpty && vault.credentialGroups.isEmpty) {
      body = _Empty(onAdd: _newCredential, onGroup: _newGroup);
    } else {
      body = RefreshIndicator(
        color: c.accent,
        onRefresh: vault.load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, tabBarInset(context)),
          children: [
            SearchBox(hint: context.l.searchVaultHint, readOnly: true, onTap: _search),
            const SizedBox(height: 16),
            ChipsRow(children: [
              FilterChipPill(
                label: context.l.allCount(vault.credentials.length),
                selected: _filter == _Filter.all,
                onTap: () => setState(() => _filter = _Filter.all),
              ),
              FilterChipPill(
                label: context.l.favorites,
                selected: _filter == _Filter.favorite,
                onTap: () => setState(() => _filter = _Filter.favorite),
              ),
              if (vault.knowsRemote) ...[
                FilterChipPill(
                  label: context.l.sites,
                  selected: _filter == _Filter.sites,
                  onTap: () => setState(() => _filter = _Filter.sites),
                ),
                FilterChipPill(
                  label: context.l.servers,
                  selected: _filter == _Filter.servers,
                  onTap: () => setState(() => _filter = _Filter.servers),
                ),
              ],
            ]),
            ..._filter == _Filter.all ? _overview(vault) : _filtered(vault),
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
              Expanded(child: PageTitle(context.l.tabVault)),
              IconBtn(
                icon: LucideIcons.folderPlus,
                label: context.l.newGroup,
                color: c.text,
                background: c.surface,
                border: true,
                onPressed: _newGroup,
              ),
              const SizedBox(width: 8),
              IconBtn(
                icon: LucideIcons.plus,
                label: context.l.newCredential,
                color: c.onAccent,
                background: c.accent,
                onPressed: _newCredential,
              ),
            ]),
          ),
          Expanded(child: body),
        ]),
      ),
    );
  }

  List<Widget> _overview(Vault vault) {
    final favorites = vault.credentials.where((e) => e.favorite).toList();
    final groups = vault.credentialGroups;
    final ungrouped = vault.ungroupedCredentials;
    return [
      if (favorites.isNotEmpty) ...[
        const SizedBox(height: 20),
        SectionLabel(context.l.favorites),
        const SizedBox(height: 10),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _FavoriteCard(credential: favorites[i]),
          ),
        ),
      ],
      if (groups.isNotEmpty) ...[
        const SizedBox(height: 22),
        SectionLabel(context.l.groups),
        const SizedBox(height: 10),
        CardList(children: [
          for (final g in groups)
            GroupRow(
              name: g.name,
              count: vault.credentialsIn(g.id).length,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GroupScreen(groupId: g.id))),
            ),
        ]),
      ],
      if (ungrouped.isNotEmpty) ...[
        const SizedBox(height: 22),
        SectionLabel(context.l.noGroup),
        const SizedBox(height: 10),
        CardList(children: [for (final cr in ungrouped) CredentialRow(credential: cr)]),
      ],
    ];
  }

  List<Widget> _filtered(Vault vault) {
    final list = vault.credentials.where((e) => switch (_filter) {
          _Filter.favorite => e.favorite,
          _Filter.sites => !e.isRemote,
          _Filter.servers => e.isRemote,
          _Filter.all => true,
        });
    return [
      const SizedBox(height: 20),
      if (list.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            _filter == _Filter.favorite ? context.l.favoritesHint : context.l.nothingFound,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.c.text2, fontSize: 15),
          ),
        )
      else
        CardList(children: [for (final cr in list) CredentialRow(credential: cr, withGroup: true)]),
    ];
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.credential});

  final CredentialSummary credential;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final vault = context.watch<Vault>();
    final width = (MediaQuery.of(context).size.width - 50) / 2;
    final sub = credentialSubtitle(credential, vault, short: true);
    return SizedBox(
      width: width,
      child: CardBox(
        onTap: () => openCredential(context, credential.id),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CredentialTile(credential: credential),
            const Spacer(),
            Icon(Icons.star_rounded, size: 20, color: c.star),
          ]),
          const Spacer(),
          Text(credential.name,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(sub.isEmpty ? vault.groupName(credential.groupId) : sub,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.text2)),
        ]),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd, required this.onGroup});

  final VoidCallback onAdd;
  final VoidCallback onGroup;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 20, 40, 60),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(children: [
              Positioned(
                left: 0,
                top: 18,
                child: Transform.rotate(
                  angle: -0.14,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(26)),
                  child: Icon(LucideIcons.keyRound, size: 44, color: c.onAccent),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Text(context.l.emptyTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Text(
            context.l.emptyText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5, color: c.text2),
          ),
          const SizedBox(height: 26),
          AppButton(label: context.l.addCredential, icon: LucideIcons.plus, height: 52, onPressed: onAdd),
          const SizedBox(height: 10),
          AppButton(
            label: context.l.createGroup,
            icon: LucideIcons.folderPlus,
            height: 52,
            kind: ButtonKind.secondary,
            onPressed: onGroup,
          ),
        ]),
      ),
    );
  }
}
