import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/session.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/sheets.dart';
import '../auth/pin_screens.dart';
import '../home_shell.dart';
import 'language_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _changeServer(BuildContext context) async {
    final session = context.read<Session>();
    await confirmDelete(
      context,
      title: context.l.changeServerTitle,
      message: context.l.changeServerText,
      action: context.l.changeServer,
      icon: LucideIcons.server,
      onConfirm: session.changeServer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final settings = context.watch<Settings>();
    final session = context.watch<Session>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(children: [BackLink(label: context.l.tabProfile)]),
          ),
          Expanded(
            child: ListView(padding: EdgeInsets.fromLTRB(20, 16, 20, tabBarInset(context)), children: [
              PageTitle(context.l.settings, size: 28),
              const SizedBox(height: 14),
              SectionLabel(context.l.security),
              const SizedBox(height: 14),
              CardList(children: [
                NavRow(
                  label: context.l.changePin,
                  onTap: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
                      fullscreenDialog: true, builder: (_) => const PinCreateScreen(changing: true))),
                ),
                NavRow(
                  label: context.l.autoLock,
                  value: Settings.autoLockLabel(settings.autoLockSeconds),
                  onTap: () async {
                    final v = await pickOption<int>(
                      context,
                      title: context.l.autoLock,
                      selected: settings.autoLockSeconds,
                      options: [for (final s in Settings.autoLockOptions) (s, Settings.autoLockLabel(s))],
                    );
                    if (v != null) settings.autoLockSeconds = v;
                  },
                ),
                NavRow(
                  label: context.l.clipboardClear,
                  value: Settings.clipboardLabel(settings.clipboardClearSeconds),
                  onTap: () async {
                    final v = await pickOption<int>(
                      context,
                      title: context.l.clipboardClear,
                      selected: settings.clipboardClearSeconds,
                      options: [for (final s in Settings.clipboardOptions) (s, Settings.clipboardLabel(s))],
                    );
                    if (v != null) settings.clipboardClearSeconds = v;
                  },
                ),
              ]),
              const SizedBox(height: 14),
              SectionLabel(context.l.appearance),
              const SizedBox(height: 14),
              CardList(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(context.l.theme, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Segmented<ThemeMode>(
                      value: settings.themeMode,
                      onChanged: (v) => settings.themeMode = v,
                      options: [
                        (ThemeMode.system, context.l.themeSystem, null),
                        (ThemeMode.light, context.l.themeLight, null),
                        (ThemeMode.dark, context.l.themeDark, null),
                      ],
                    ),
                  ]),
                ),
                NavRow(
                  label: context.l.language,
                  value: languageName(context, settings.language),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LanguageScreen())),
                ),
              ]),
              const SizedBox(height: 14),
              SectionLabel(context.l.serverSection),
              const SizedBox(height: 14),
              Material(
                color: c.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: c.border)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _changeServer(context),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 56),
                    padding: const EdgeInsets.only(left: 16, right: 14),
                    child: Row(children: [
                      Icon(LucideIcons.globe, size: 20, color: c.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(session.serverHost,
                            overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: kMono, fontSize: 14)),
                      ),
                      Text(context.l.change, style: TextStyle(fontSize: 15, color: c.accent, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(context.l.serverChangeNote,
                  style: TextStyle(fontSize: 13, color: c.text2)),
            ]),
          ),
        ]),
      ),
    );
  }
}
