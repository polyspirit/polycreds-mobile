import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/l10n.dart';
import '../../api/models.dart';
import '../../state/session.dart';
import '../../theme/app_colors.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';
import '../../widgets/sheets.dart';
import '../home_shell.dart';
import 'profile_edit_screen.dart';
import 'sessions_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _version = '';
  List<DeviceToken>? _devices;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((i) {
      if (mounted) setState(() => _version = i.version);
    });
    _loadDevices();
    context.read<Session>().refreshUser().catchError((_) {});
  }

  Future<void> _loadDevices() async {
    try {
      final list = await context.read<Session>().api.tokens();
      if (mounted) setState(() => _devices = list);
    } catch (_) {}
  }

  void _push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page)).then((_) => _loadDevices());

  Future<void> _logout() async {
    final session = context.read<Session>();
    await confirmDelete(
      context,
      title: context.l.logoutTitle,
      message: context.l.logoutText,
      action: context.l.logout,
      icon: LucideIcons.logOut,
      onConfirm: session.logout,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final session = context.watch<Session>();
    final user = session.user;

    Widget rowIcon(IconData i) => ItemTile(icon: i, bg: c.accentSoft, fg: c.accent, size: 32);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: EdgeInsets.fromLTRB(20, 16, 20, tabBarInset(context)), children: [
          PageTitle(context.l.tabProfile),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border),
            ),
            child: Row(children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                child: Text(initial(user?.name ?? ''),
                    style: TextStyle(color: c.onAccent, fontSize: 26, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.name ?? '',
                      overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, color: c.text2)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(LucideIcons.globe, size: 14, color: c.success),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(session.serverHost,
                          overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.text2)),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          CardList(children: [
            NavRow(
              label: context.l.personalData,
              leading: rowIcon(LucideIcons.userPen),
              minHeight: 56,
              onTap: () => _push(const ProfileEditScreen()),
            ),
            NavRow(
              label: context.l.devices,
              value: _devices != null ? '${_devices!.length}' : null,
              leading: rowIcon(LucideIcons.smartphone),
              minHeight: 56,
              onTap: () => _push(const SessionsScreen()),
            ),
            NavRow(
              label: context.l.securitySettings,
              leading: rowIcon(LucideIcons.settings),
              minHeight: 56,
              onTap: () => _push(const SettingsScreen()),
            ),
          ]),
          const SizedBox(height: 20),
          CardList(children: [
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Expanded(child: Text(context.l.version, style: const TextStyle(fontSize: 16))),
                  Text(_version, style: TextStyle(fontFamily: kMono, fontSize: 14, color: c.text2)),
                ]),
              ),
            ),
            NavRow(
              label: context.l.openWeb,
              trailing: Icon(LucideIcons.externalLink, size: 18, color: c.text3),
              onTap: () => launchUrl(Uri.parse(session.serverUrl), mode: LaunchMode.externalApplication),
            ),
          ]),
          const SizedBox(height: 20),
          AppButton(
            label: context.l.signOut,
            icon: LucideIcons.logOut,
            kind: ButtonKind.dangerOutline,
            height: 52,
            onPressed: _logout,
          ),
        ]),
      ),
    );
  }
}
