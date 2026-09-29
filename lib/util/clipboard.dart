import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../state/settings.dart';
import '../widgets/toast.dart';

Timer? _clearTimer;

/// Copies [value] and shows [title] in a toast; secrets are wiped from the
/// clipboard after the configured delay.
Future<void> copyToClipboard(
  BuildContext context,
  String value, {
  required String title,
  bool secret = true,
}) async {
  final seconds = context.read<Settings>().clipboardClearSeconds;
  await Clipboard.setData(ClipboardData(text: value));
  HapticFeedback.lightImpact();

  _clearTimer?.cancel();
  if (secret && seconds > 0) {
    _clearTimer = Timer(Duration(seconds: seconds), () async {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      if (current?.text == value) await Clipboard.setData(const ClipboardData(text: ''));
    });
  }

  if (!context.mounted) return;
  showToast(
    context,
    title: title,
    subtitle: secret && seconds > 0 ? tr.clipboardWillClear(Settings.duration(seconds)) : null,
    icon: LucideIcons.circleCheck,
  );
}

