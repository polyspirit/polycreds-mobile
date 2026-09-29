import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/pin_pad.dart';

/// PIN setup in two steps: enter and confirm. Used after login and from settings.
class PinCreateScreen extends StatefulWidget {
  const PinCreateScreen({super.key, this.changing = false});

  final bool changing;

  @override
  State<PinCreateScreen> createState() => _PinCreateScreenState();
}

class _PinCreateScreenState extends State<PinCreateScreen> {
  static const _min = 4;
  static const _max = 6;

  String _first = '';
  String _pin = '';
  bool _confirming = false;
  String? _error;

  void _digit(String d) {
    if (_pin.length >= _max) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_confirming && _pin.length == _first.length) {
      _confirm();
    } else if (!_confirming && _pin.length == _max) {
      _next();
    }
  }

  void _delete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _next() {
    if (_pin.length < _min) return;
    setState(() {
      _first = _pin;
      _pin = '';
      _confirming = true;
    });
  }

  Future<void> _confirm() async {
    if (_pin != _first) {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = context.l.pinMismatch;
        _pin = '';
        _first = '';
        _confirming = false;
      });
      return;
    }
    await context.read<Session>().setPin(_pin);
    if (widget.changing && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final canNext = !_confirming && _pin.length >= _min;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(children: [
            SizedBox(
              height: 44,
              child: Row(children: [
                if (widget.changing)
                  Transform.translate(
                    offset: const Offset(-10, 0),
                    child: TextLink(label: context.l.cancel, onTap: () => Navigator.of(context).pop()),
                  ),
                Text(context.l.stepOf(_confirming ? 2 : 1), style: TextStyle(fontSize: 15, color: c.text2)),
                const Spacer(),
                for (var i = 0; i < 2; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Container(
                    width: 28,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i == 0 || _confirming ? c.accent : c.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  const SizedBox(height: 32),
                  const Badge56(icon: LucideIcons.lockKeyhole),
                  const SizedBox(height: 16),
                  Text(_confirming ? context.l.repeatPin : context.l.createPin,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      _confirming
                          ? context.l.pinRepeatHint
                          : context.l.pinCreateHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, height: 1.45, color: c.text2),
                    ),
                  ),
                  const SizedBox(height: 36),
                  PinDots(count: _confirming ? _first.length : _max, filled: _pin.length),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 20,
                    child: Text(_error ?? '', style: TextStyle(fontSize: 14, color: c.danger)),
                  ),
                ]),
              ),
            ),
            PinPad(
              onDigit: _digit,
              onDelete: _delete,
              action: canNext
                  ? Semantics(
                      button: true,
                      label: context.l.next,
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: _next,
                        child: Icon(LucideIcons.arrowRight, size: 28, color: c.accent),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 22),
            Text(context.l.pinDigitsHint, style: TextStyle(fontSize: 14, color: c.text2)),
          ]),
        ),
      ),
    );
  }
}

class PinUnlockScreen extends StatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  String _pin = '';
  bool _error = false;
  bool _checking = false;

  Future<void> _digit(String d) async {
    final session = context.read<Session>();
    if (_checking || _pin.length >= session.pinLength) return;
    setState(() {
      _pin += d;
      _error = false;
    });
    if (_pin.length == session.pinLength) {
      _checking = true;
      final ok = await session.unlock(_pin);
      _checking = false;
      if (!ok && mounted) {
        HapticFeedback.heavyImpact();
        setState(() {
          _pin = '';
          _error = true;
        });
      }
    }
  }

  void _delete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final session = context.watch<Session>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  const SizedBox(height: 60),
                  Image.asset('assets/images/logo.png', width: 58, height: 70, fit: BoxFit.contain),
                  const SizedBox(height: 18),
                  Text(context.l.enterPin, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(session.user?.email ?? '', style: TextStyle(fontSize: 15, color: c.text2)),
                  const SizedBox(height: 30),
                  PinDots(count: session.pinLength, filled: _pin.length, error: _error),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 20,
                    child: Text(
                      _error ? context.l.wrongPin(session.pinAttemptsLeft) : '',
                      style: TextStyle(fontSize: 14, color: c.danger),
                    ),
                  ),
                ]),
              ),
            ),
            PinPad(onDigit: _digit, onDelete: _delete),
            const SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextLink(label: context.l.signInWithPassword, bold: true, fontSize: 15, onTap: session.logout),
              const SizedBox(width: 14),
              TextLink(label: context.l.signOut, fontSize: 15, color: c.text2, onTap: session.changeServer),
            ]),
          ]),
        ),
      ),
    );
  }
}
