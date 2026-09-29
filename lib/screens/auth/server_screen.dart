import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../api/api_client.dart';
import '../../state/session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  late final Session _session = context.read<Session>();
  late bool _custom = _session.serverUrl != kDefaultServer;
  late final _url = TextEditingController(text: _custom ? _session.serverUrl : 'https://');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final url = _custom ? _url.text.trim() : kDefaultServer;
    if (_custom && (url.isEmpty || url == 'https://' || Uri.tryParse(ApiClient.normalizeServerUrl(url))?.host.isEmpty != false)) {
      setState(() => _error = context.l.enterServer);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _session.chooseServer(url);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 64),
              child: IntrinsicHeight(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/images/logo.png', width: 66, height: 80, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 18),
                  const Text('PolyCreds',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.6)),
                  const SizedBox(height: 8),
                  Text(
                    context.l.appTagline,
                    style: TextStyle(fontSize: 17, height: 1.45, color: c.text2),
                  ),
                  const SizedBox(height: 28),
                  SectionLabel(context.l.serverSection),
                  const SizedBox(height: 10),
                  _Option(
                    selected: !_custom,
                    onTap: () => setState(() {
                      _custom = false;
                      _error = null;
                    }),
                    title: Uri.parse(kDefaultServer).host,
                    subtitle: context.l.cloudDefault,
                    trailing: Icon(LucideIcons.cloud, size: 22, color: c.accent),
                  ),
                  const SizedBox(height: 10),
                  _Option(
                    selected: _custom,
                    onTap: () => setState(() {
                      _custom = true;
                      _error = null;
                    }),
                    title: context.l.ownServer,
                    subtitle: context.l.selfHosted,
                    extra: Padding(
                      padding: const EdgeInsets.only(left: 36, top: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(context.l.serverAddress, style: TextStyle(fontSize: 13, color: c.text2)),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: c.surface2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _error != null && _custom ? c.danger : c.border),
                          ),
                          child: TextField(
                            controller: _url,
                            onTap: () => setState(() => _custom = true),
                            keyboardType: TextInputType.url,
                            autocorrect: false,
                            enableSuggestions: false,
                            textInputAction: TextInputAction.go,
                            onSubmitted: (_) => _continue(),
                            style: TextStyle(fontFamily: kMono, fontSize: 15, color: _custom ? c.text : c.text3),
                            decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      Icon(LucideIcons.circleAlert, size: 16, color: c.danger),
                      const SizedBox(width: 6),
                      Expanded(child: Text(_error!, style: TextStyle(color: c.danger, fontSize: 14))),
                    ]),
                  ],
                  const Spacer(),
                  const SizedBox(height: 24),
                  AppButton(label: context.l.continueAction, loading: _busy, onPressed: _continue),
                  const SizedBox(height: 14),
                  Text(context.l.serverChangeLater,
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: c.text2)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.onTap,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.extra,
  });

  final bool selected;
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? c.accent : c.border, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(selected ? 15 : 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? c.accent : c.text3, width: selected ? 7 : 2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 14, color: c.text2)),
                  ]),
                ),
                ?trailing,
              ]),
              ?extra,
            ]),
          ),
        ),
      ),
    );
  }
}
