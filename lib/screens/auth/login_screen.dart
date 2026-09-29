import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../api/api_client.dart';
import '../../state/session.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _email = TextEditingController(text: context.read<Settings>().lastEmail);
  final _password = TextEditingController();
  bool _busy = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    setState(() {
      _emailError = email.contains('@') ? null : context.l.enterEmail;
      _passwordError = _password.text.isEmpty ? context.l.enterPassword : null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _busy = true);
    final session = context.read<Session>();
    context.read<Settings>().lastEmail = email;
    try {
      await session.login(email, _password.text);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _emailError = e.field('email') ?? (e.fieldErrors.isEmpty ? e.message : null);
        _passwordError = e.field('password');
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final session = context.watch<Session>();
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 32),
              child: IntrinsicHeight(
                child: AutofillGroup(
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
                          onPressed: session.changeServer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset('assets/images/logo.png', width: 40, height: 48, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 16),
                    PageTitle(context.l.loginTitle),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: c.surface2,
                        shape: const StadiumBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: session.changeServer,
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(LucideIcons.globe, size: 16, color: c.success),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(session.serverHost,
                                    overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                              ),
                              const SizedBox(width: 8),
                              Text(context.l.change,
                                  style: TextStyle(fontSize: 14, color: c.accent, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppField(
                      label: 'E-mail',
                      controller: _email,
                      height: 52,
                      fontSize: 17,
                      error: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email, AutofillHints.username],
                    ),
                    const SizedBox(height: 16),
                    AppField(
                      label: context.l.password,
                      controller: _password,
                      obscure: true,
                      height: 52,
                      fontSize: 17,
                      error: _passwordError,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      autofillHints: const [AutofillHints.password],
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    AppButton(label: context.l.signIn, loading: _busy, onPressed: _submit),
                    const SizedBox(height: 14),
                    Text(
                      context.l.loginFooter,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, height: 1.45, color: c.text2),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
