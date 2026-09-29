import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import 'common.dart';

Future<T?> showAppSheet<T>(BuildContext context, WidgetBuilder builder) {
  final c = context.c;
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: c.surface,
    barrierColor: c.scrim,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 5, decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(3))),
          Flexible(child: builder(ctx)),
        ]),
      ),
    ),
  );
}

/// Destructive confirmation (design: "11 Подтверждение удаления").
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
  String? action,
  IconData icon = LucideIcons.trash2,
  Future<void> Function()? onConfirm,
}) async {
  final ok = await showAppSheet<bool>(
    context,
    (ctx) => _ConfirmSheet(title: title, message: message, action: action ?? ctx.l.delete, icon: icon, onConfirm: onConfirm),
  );
  return ok ?? false;
}

class _ConfirmSheet extends StatefulWidget {
  const _ConfirmSheet({required this.title, required this.message, required this.action, required this.icon, this.onConfirm});

  final String title;
  final String message;
  final String action;
  final IconData icon;
  final Future<void> Function()? onConfirm;

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _go() async {
    if (widget.onConfirm == null) return Navigator.pop(context, true);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onConfirm!();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Badge56(icon: widget.icon, danger: true, round: true),
        const SizedBox(height: 14),
        Text(widget.title,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(widget.message,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.45, color: c.text2)),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: c.danger, fontSize: 14)),
        ],
        const SizedBox(height: 22),
        AppButton(label: widget.action, kind: ButtonKind.danger, loading: _busy, onPressed: _go),
        const SizedBox(height: 10),
        Material(
          color: c.surface2,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _busy ? null : () => Navigator.pop(context, false),
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: Center(child: Text(context.l.cancel, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Simple single-choice list in a bottom sheet.
Future<T?> pickOption<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T? selected,
  IconData? icon,
}) =>
    showAppSheet<T>(context, (ctx) {
      final c = ctx.c;
      return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        Flexible(
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.only(bottom: 12), children: [
            for (final (v, label) in options)
              InkWell(
                onTap: () => Navigator.pop(ctx, v),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    if (icon != null) ...[Icon(icon, size: 20, color: c.accent), const SizedBox(width: 12)],
                    Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
                    if (v == selected) Icon(LucideIcons.check, size: 20, color: c.accent),
                  ]),
                ),
              ),
          ]),
        ),
      ]);
    });
