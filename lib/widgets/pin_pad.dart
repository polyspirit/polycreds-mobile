import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.count, required this.filled, this.error = false});

  final int count;
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      label: context.l.digitsEntered(filled),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 18),
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: !error && i < filled ? c.accent : Colors.transparent,
              border: Border.all(color: error ? c.danger : (i < filled ? c.accent : c.text3), width: 2),
            ),
          ),
        ],
      ]),
    );
  }
}

/// Numeric keypad 3×4. [action] fills the empty bottom-left cell when set.
class PinPad extends StatelessWidget {
  const PinPad({super.key, required this.onDigit, required this.onDelete, this.action});

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget key(String d) => Material(
          color: c.surface,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onDigit(d);
            },
            child: Center(child: Text(d, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500, color: c.text))),
          ),
        );

    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return SizedBox(
      width: 300,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (final r in rows) ...[
          Row(children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 28),
              Expanded(child: SizedBox(height: 72, child: key(r[i]))),
            ],
          ]),
          const SizedBox(height: 14),
        ],
        Row(children: [
          Expanded(child: SizedBox(height: 72, child: action ?? const SizedBox())),
          const SizedBox(width: 28),
          Expanded(child: SizedBox(height: 72, child: key('0'))),
          const SizedBox(width: 28),
          Expanded(
            child: SizedBox(
              height: 72,
              child: Semantics(
                button: true,
                label: context.l.erase,
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: onDelete,
                  child: Icon(LucideIcons.delete, size: 28, color: c.text),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
