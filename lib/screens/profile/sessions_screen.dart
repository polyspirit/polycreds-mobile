import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../api/models.dart';
import '../../state/session.dart';
import '../../theme/app_colors.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';
import '../../widgets/sheets.dart';
import '../../widgets/toast.dart';
import '../home_shell.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  List<DeviceToken>? _tokens;
  String? _error;
  final _busy = <int>{};
  bool _busyAll = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final list = await context.read<Session>().api.tokens();
      if (mounted) setState(() => _tokens = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _terminate(DeviceToken t) async {
    setState(() => _busy.add(t.id));
    try {
      await context.read<Session>().api.deleteToken(t.id);
      if (mounted) setState(() => _tokens!.removeWhere((e) => e.id == t.id));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy.remove(t.id));
    }
  }

  Future<void> _terminateOthers() async {
    final api = context.read<Session>().api;
    final ok = await confirmDelete(
      context,
      title: context.l.terminateOthersTitle,
      message: context.l.terminateOthersText,
      action: context.l.terminate,
      icon: LucideIcons.logOut,
    );
    if (!ok || !mounted) return;
    setState(() => _busyAll = true);
    try {
      final count = await api.deleteOtherTokens();
      if (!mounted) return;
      setState(() => _tokens!.removeWhere((e) => !e.isCurrent));
      showToast(context, title: context.l.terminatedN(count), icon: LucideIcons.circleCheck);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busyAll = false);
    }
  }

  IconData _icon(String name) {
    final n = name.toLowerCase();
    if (n.contains('ipad') || n.contains('tab')) return LucideIcons.tablet;
    if (n.contains('iphone') || n.contains('android') || n.contains('pixel') || n.contains('polycreds')) {
      return LucideIcons.smartphone;
    }
    return LucideIcons.monitor;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final tokens = _tokens;
    final current = tokens?.where((t) => t.isCurrent).firstOrNull;
    final others = tokens?.where((t) => !t.isCurrent).toList() ?? [];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(children: [BackLink(label: context.l.tabProfile)]),
          ),
          Expanded(
            child: tokens == null
                ? (_error != null ? ErrorRetry(message: _error!, onRetry: _load) : const CenteredLoader())
                : RefreshIndicator(
                    color: c.accent,
                    onRefresh: _load,
                    child: ListView(padding: EdgeInsets.fromLTRB(20, 16, 20, tabBarInset(context)), children: [
                      PageTitle(context.l.devices, size: 28),
                      if (current != null) ...[
                        const SizedBox(height: 14),
                        SectionLabel(context.l.thisDevice),
                        const SizedBox(height: 14),
                        CardList(borderColor: c.success, borderWidth: 2, children: [
                          _DeviceRow(token: current, icon: _icon(current.deviceName), current: true),
                        ]),
                      ],
                      const SizedBox(height: 20),
                      SectionLabel(context.l.otherSessions(others.length)),
                      const SizedBox(height: 14),
                      if (others.isEmpty)
                        Text(context.l.noOtherSessions, style: TextStyle(fontSize: 15, color: c.text2))
                      else
                        CardList(children: [
                          for (final t in others)
                            _DeviceRow(
                              token: t,
                              icon: _icon(t.deviceName),
                              busy: _busy.contains(t.id),
                              onTerminate: () => _terminate(t),
                            ),
                        ]),
                      if (others.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        AppButton(
                          label: context.l.terminateAll,
                          kind: ButtonKind.dangerSoft,
                          height: 52,
                          loading: _busyAll,
                          onPressed: _terminateOthers,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          context.l.terminateOthersText,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, height: 1.45, color: c.text2),
                        ),
                      ],
                    ]),
                  ),
          ),
        ]),
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.token, required this.icon, this.current = false, this.busy = false, this.onTerminate});

  final DeviceToken token;
  final IconData icon;
  final bool current;
  final bool busy;
  final VoidCallback? onTerminate;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(children: [
        ItemTile(
          icon: icon,
          size: 44,
          bg: current ? c.successSoft : c.surface2,
          fg: current ? c.success : c.text2,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(token.deviceName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(current ? context.l.activeNow : relativeTime(token.lastUsedAt),
                style: TextStyle(fontSize: 14, color: c.text2)),
            if (token.ip != null) ...[
              const SizedBox(height: 3),
              Text('IP ${token.ip}', style: TextStyle(fontFamily: kMono, fontSize: 13, color: c.text2)),
            ] else if (token.createdAt != null) ...[
              const SizedBox(height: 3),
              Text(context.l.signedInOn(formatDate(token.createdAt, withYear: true)), style: TextStyle(fontSize: 13, color: c.text2)),
            ],
          ]),
        ),
        if (onTerminate != null)
          busy
              ? const SizedBox(width: 36, height: 36, child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)))
              : Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: c.border)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTerminate,
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      child: Text(context.l.terminate,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.danger)),
                    ),
                  ),
                ),
      ]),
    );
  }
}
