import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../home_shell.dart';

/// Value shown in the settings row: "Как в системе", "Русский", "English".
String languageName(BuildContext context, String code) => switch (code) {
      'ru' => 'Русский',
      'en' => 'English',
      _ => context.l.languageSystem,
    };

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l;
    final settings = context.watch<Settings>();
    final system = resolveSystemLocale(PlatformDispatcher.instance.locales).languageCode;
    final options = [
      ('system', l.auto, l.languageSystem, l.languageNow(system == 'ru' ? l.languageRussianInline : l.languageEnglishInline)),
      ('ru', 'RU', 'Русский', 'Russian'),
      ('en', 'EN', 'English', 'Английский'),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(children: [BackLink(label: l.settings)]),
          ),
          Expanded(
            child: ListView(padding: EdgeInsets.fromLTRB(20, 16, 20, tabBarInset(context)), children: [
              PageTitle(l.language, size: 28),
              const SizedBox(height: 14),
              Semantics(
                label: l.languageGroup,
                child: CardList(children: [
                  for (final (code, tile, name, sub) in options)
                    _LanguageRow(
                      tile: tile,
                      name: name,
                      sub: sub,
                      selected: settings.language == code,
                      onTap: () => settings.language = code,
                    ),
                ]),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(l.languageNote, style: TextStyle(fontSize: 13, height: 1.45, color: c.text2)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.tile,
    required this.name,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final String tile;
  final String name;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? c.accentSoft : c.surface2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tile,
                  style: TextStyle(
                    fontFamily: kMono,
                    fontSize: tile.length > 2 ? 10.5 : 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? c.accent : c.text2,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: TextStyle(fontSize: 16, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                  const SizedBox(height: 2),
                  Text(sub, style: TextStyle(fontSize: 14, color: c.text2)),
                ]),
              ),
              if (selected) Icon(LucideIcons.check, size: 22, color: c.accent),
            ]),
          ),
        ),
      ),
    );
  }
}
