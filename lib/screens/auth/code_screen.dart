import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../api/api_client.dart';
import '../../state/session.dart';
import '../../theme/app_colors.dart';
import '../../util/format.dart';
import '../../widgets/common.dart';
import '../../widgets/toast.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  static const _length = 6;
  static const _resendDelay = 60;

  final _code = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _left = _resendDelay;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focus.addListener(() => setState(() {}));
    _code.addListener(() {
      setState(() {});
      if (_code.text.length == _length && !_busy) _submit();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _left = _resendDelay;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) t.cancel();
      setState(() => _left--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_code.text.length != _length) {
      setState(() => _error = context.l.enter6Digits);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<Session>().verify2FA(_code.text);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.field('code') ?? e.message);
      _code.clear();
      if (e.isUnauthorized) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      await context.read<Session>().resend2FA();
      setState(_startTimer);
      if (mounted) showToast(context, title: context.l.codeResent, icon: LucideIcons.mail);
    } on ApiException catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final session = context.read<Session>();
    final text = _code.text;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 32),
              child: IntrinsicHeight(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: const Offset(-10, 0),
                      child: IconBtn(
                        icon: LucideIcons.chevronLeft,
                        label: context.l.back,
                        color: c.accent,
                        size: 26,
                        onPressed: session.cancel2FA,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Align(alignment: Alignment.centerLeft, child: Badge56(icon: LucideIcons.mail)),
                  const SizedBox(height: 14),
                  PageTitle(context.l.codeTitle, size: 30),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: context.l.codeSentPrefix),
                      TextSpan(
                        text: maskEmail(session.pendingEmail),
                        style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: context.l.codeSentSuffix),
                    ]),
                    style: TextStyle(fontSize: 17, height: 1.45, color: c.text2),
                  ),
                  const SizedBox(height: 28),
                  Stack(children: [
                    // Invisible field receives keyboard input and OTP autofill.
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _code,
                          focusNode: _focus,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(_length),
                          ],
                          showCursor: false,
                          enableInteractiveSelection: false,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _focus.requestFocus(),
                      child: Row(children: [
                        for (var i = 0; i < _length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: c.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _error != null
                                      ? c.danger
                                      : (i == text.length && _focus.hasFocus ? c.accent : c.border),
                                  width: i == text.length && _focus.hasFocus ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                i < text.length ? text[i] : '',
                                style: const TextStyle(fontFamily: kMono, fontSize: 26, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ]),
                    ),
                  ]),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: TextStyle(color: c.danger, fontSize: 14)),
                  ],
                  const SizedBox(height: 28),
                  if (_left > 0)
                    Row(children: [
                      Icon(LucideIcons.clock, size: 18, color: c.text2),
                      const SizedBox(width: 8),
                      Text(context.l.resendIn, style: TextStyle(fontSize: 15, color: c.text2)),
                      Text('${_left ~/ 60}:${(_left % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(fontFamily: kMono, fontSize: 15, color: c.text)),
                    ])
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: const Offset(-10, 0),
                        child: TextLink(label: context.l.resendCode, bold: true, fontSize: 15, onTap: _resend),
                      ),
                    ),
                  const Spacer(),
                  const SizedBox(height: 24),
                  AppButton(label: context.l.confirm, loading: _busy, onPressed: _submit),
                  const SizedBox(height: 14),
                  Text(
                    context.l.codeFooter,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.45, color: c.text2),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
