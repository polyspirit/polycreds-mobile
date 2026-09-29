import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../state/vault.dart';
import '../theme/app_colors.dart';
import 'generator_screen.dart';
import 'notes/notes_screen.dart';
import 'profile/profile_screen.dart';
import 'vault/vault_screen.dart';

/// Bottom tabs; each tab keeps its own navigation stack (the tab bar stays visible on pushed screens).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _keys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  static const _icons = [LucideIcons.keyRound, LucideIcons.fileText, LucideIcons.dices, LucideIcons.user];

  @override
  void initState() {
    super.initState();
    final vault = context.read<Vault>();
    if (!vault.loaded && !vault.loading) vault.load();
  }

  Widget _root(int i) => switch (i) {
        0 => const VaultScreen(),
        1 => const NotesScreen(),
        2 => const GeneratorScreen(),
        _ => const ProfileScreen(),
      };

  void _select(int i) {
    if (i == _index) {
      _keys[i].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _index = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l;
    final tabs = [
      (_icons[0], l.tabVault),
      (_icons[1], l.tabNotes),
      (_icons[2], l.tabGenerator),
      (_icons[3], l.tabProfile),
    ];
    return NavigatorPopHandler(
      onPopWithResult: (_) => _keys[_index].currentState?.maybePop(),
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < 4; i++)
              HeroControllerScope.none(
                child: Navigator(
                  key: _keys[i],
                  onGenerateRoute: (s) => MaterialPageRoute(builder: (_) => _root(i), settings: s),
                ),
              ),
          ],
        ),
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(color: c.tab, border: Border(top: BorderSide(color: c.border))),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Row(children: [
                    for (var i = 0; i < tabs.length; i++)
                      Expanded(
                        child: Semantics(
                          selected: i == _index,
                          button: true,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _select(i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Icon(tabs[i].$1, size: 24, color: i == _index ? c.accent : c.text2),
                                const SizedBox(height: 3),
                                Text(
                                  tabs[i].$2,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: i == _index ? c.accent : c.text2,
                                    fontWeight: i == _index ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom padding for scrollable tab content. With `extendBody` the tab bar height
/// is already part of MediaQuery padding.
double tabBarInset(BuildContext context) => MediaQuery.of(context).padding.bottom + 20;
