import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../util/clipboard.dart';
import '../util/password.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import 'home_shell.dart';
import 'vault/credential_screen.dart';

/// Options survive tab switches and are shared with the generator sheet.
class _GenOptions {
  static int length = 20;
  static Set<CharSet> sets = {CharSet.digits, CharSet.lower, CharSet.upper, CharSet.symbols};
}

class GeneratorScreen extends StatelessWidget {
  const GeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, tabBarInset(context)),
            children: [PageTitle(context.l.tabGenerator), const SizedBox(height: 18), const GeneratorPanel()],
          ),
        ),
      );
}

/// Opens the generator in a sheet; resolves to the chosen password.
Future<String?> pickGeneratedPassword(BuildContext context) => showAppSheet<String>(
      context,
      (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: GeneratorPanel(onUse: (p) => Navigator.pop(ctx, p)),
      ),
    );

class GeneratorPanel extends StatefulWidget {
  const GeneratorPanel({super.key, this.onUse});

  /// When set, the main button returns the password instead of copying it.
  final ValueChanged<String>? onUse;

  @override
  State<GeneratorPanel> createState() => _GeneratorPanelState();
}

class _GeneratorPanelState extends State<GeneratorPanel> {
  late String _password = generatePassword(_GenOptions.length, _GenOptions.sets);

  void _regenerate() => setState(() => _password = generatePassword(_GenOptions.length, _GenOptions.sets));

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final strength = passwordStrength(_password);
    final bits = passwordBits(_password).round();
    final color = switch (strength) {
      Strength.weak => c.danger,
      Strength.fair => c.star,
      _ => c.success,
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Center(
              child: Semantics(
                label: context.l.generatedPassword,
                child: ColoredPassword(_password, fontSize: 24, align: TextAlign.center, weight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 16),
          StrengthBar(bars: strength.bars, color: color, height: 5, label: context.l.strengthBits(strength.label, bits)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: _PanelButton(
                label: context.l.refresh,
                icon: LucideIcons.refreshCw,
                bg: c.surface2,
                fg: c.text,
                onTap: _regenerate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PanelButton(
                label: widget.onUse != null ? context.l.use : context.l.copy,
                icon: widget.onUse != null ? LucideIcons.check : LucideIcons.copy,
                bg: c.accent,
                fg: c.onAccent,
                onTap: () => widget.onUse != null
                    ? widget.onUse!(_password)
                    : copyToClipboard(context, _password, title: context.l.copiedPassword),
              ),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(context.l.length, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            Container(
              constraints: const BoxConstraints(minWidth: 44),
              height: 30,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(8)),
              child: Text('${_GenOptions.length}',
                  style: TextStyle(fontFamily: kMono, fontSize: 15, fontWeight: FontWeight.w600, color: c.accent)),
            ),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: c.accent,
              inactiveTrackColor: c.surface2,
              thumbColor: c.accent,
              overlayColor: c.accent.withValues(alpha: 0.12),
              trackHeight: 4,
            ),
            child: Slider(
              value: _GenOptions.length.toDouble(),
              min: 4,
              max: 64,
              divisions: 60,
              label: '${_GenOptions.length}',
              onChanged: (v) {
                _GenOptions.length = v.round();
                _regenerate();
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('4', style: TextStyle(fontSize: 12, color: c.text2)),
            Text('64', style: TextStyle(fontSize: 12, color: c.text2)),
          ]),
        ]),
      ),
      const SizedBox(height: 18),
      CardList(children: [
        for (final s in CharSet.values)
          SizedBox(
            height: 54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(child: Text(s.label, style: const TextStyle(fontSize: 16))),
                Text(s.sample, style: TextStyle(fontFamily: kMono, fontSize: 14, color: c.text2)),
                const SizedBox(width: 12),
                AppSwitch(
                  value: _GenOptions.sets.contains(s),
                  onChanged: (on) {
                    if (!on && _GenOptions.sets.length == 1) return; // keep at least one set
                    on ? _GenOptions.sets.add(s) : _GenOptions.sets.remove(s);
                    _regenerate();
                  },
                ),
              ]),
            ),
          ),
      ]),
    ]);
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({required this.label, required this.icon, required this.bg, required this.fg, required this.onTap});

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 50,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ),
      );
}

class StrengthBar extends StatelessWidget {
  const StrengthBar({super.key, required this.bars, required this.color, required this.label, this.height = 4});

  final int bars;
  final Color color;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(children: [
      Expanded(
        child: Row(children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: height,
                decoration: BoxDecoration(
                  color: i < bars ? color : c.surface2,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ],
        ]),
      ),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    ]);
  }
}
