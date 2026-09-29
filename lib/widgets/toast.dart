import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

OverlayEntry? _current;
Timer? _timer;

/// Dark pill at the bottom of the screen (see design: "Пароль скопирован").
void showToast(BuildContext context, {required String title, String? subtitle, IconData? icon}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _timer?.cancel();
  _current?.remove();

  final entry = OverlayEntry(builder: (ctx) => _Toast(title: title, subtitle: subtitle, icon: icon));
  _current = entry;
  overlay.insert(entry);
  _timer = Timer(const Duration(milliseconds: 2600), () {
    if (_current == entry) {
      entry.remove();
      _current = null;
    }
  });
}

void showError(BuildContext context, Object error) =>
    showToast(context, title: error.toString(), icon: LucideIcons.circleAlert);

class _Toast extends StatelessWidget {
  const _Toast({required this.title, this.subtitle, this.icon});

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final bottom = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24;
    return Positioned(
      left: 20,
      right: 20,
      bottom: bottom,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
        ),
        child: Material(
          color: Colors.transparent,
          child: Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: c.text, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22, color: c.bg),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: TextStyle(color: c.bg, fontSize: 15, fontWeight: FontWeight.w600)),
                        if (subtitle != null)
                          Text(subtitle!, style: TextStyle(color: c.bg.withValues(alpha: 0.8), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
