import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../api/api_client.dart';
import '../../state/session.dart';
import '../../widgets/common.dart';
import '../../widgets/toast.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final Session _session = context.read<Session>();
  late final _name = TextEditingController(text: _session.user?.name);
  late final _email = TextEditingController(text: _session.user?.email);
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _current = TextEditingController();
  Map<String, String> _errors = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_email, _password, _confirm]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _current]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _needsCurrent =>
      _password.text.isNotEmpty || _email.text.trim() != (_session.user?.email ?? '');

  String? get _mismatch =>
      _confirm.text.isNotEmpty && _confirm.text != _password.text ? context.l.passwordsMismatch : null;

  Future<void> _save() async {
    final errors = <String, String>{};
    final name = _name.text.trim();
    final email = _email.text.trim();
    if (name.length < 2) errors['name'] = context.l.min2Chars;
    if (!email.contains('@')) errors['email'] = context.l.enterEmail;
    if (_password.text.isNotEmpty && _password.text.length < 6) errors['password'] = context.l.min6Chars;
    if (_password.text.isNotEmpty && _confirm.text != _password.text) errors['password_confirmation'] = context.l.passwordsMismatch;
    if (_needsCurrent && _current.text.isEmpty) errors['current_password'] = context.l.enterCurrentPassword;
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    final user = _session.user!;
    final data = <String, dynamic>{
      if (name != user.name) 'name': name,
      if (email != user.email) 'email': email,
      if (_password.text.isNotEmpty) ...{'password': _password.text, 'password_confirmation': _confirm.text},
      if (_needsCurrent) 'current_password': _current.text,
    };
    if (data.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    try {
      _session.setUser(await _session.api.updateMe(data));
      if (!mounted) return;
      showToast(context, title: context.l.dataSaved, icon: LucideIcons.circleCheck);
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errors = e.fieldErrors.map((k, v) => MapEntry(k, v.first)));
      if (e.fieldErrors.isEmpty) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Row(children: [BackLink(label: context.l.tabProfile)]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
              PageTitle(context.l.personalData, size: 28),
              const SizedBox(height: 16),
              AppField(label: context.l.userName, controller: _name, error: _errors['name'], textInputAction: TextInputAction.next),
              const SizedBox(height: 16),
              AppField(
                label: 'E-mail',
                controller: _email,
                error: _errors['email'],
                helper: context.l.emailHelper,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),
              SectionLabel(context.l.changePassword),
              const SizedBox(height: 16),
              AppField(
                label: context.l.newPassword,
                controller: _password,
                obscure: true,
                error: _errors['password'],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppField(
                label: context.l.repeatPassword,
                controller: _confirm,
                obscure: true,
                error: _errors['password_confirmation'] ?? _mismatch,
                textInputAction: TextInputAction.next,
              ),
              if (_needsCurrent) ...[
                const SizedBox(height: 24),
                AppField(
                  label: context.l.currentPassword,
                  controller: _current,
                  obscure: true,
                  error: _errors['current_password'],
                  helper: context.l.currentPasswordHelper,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                ),
              ],
              const SizedBox(height: 32),
              AppButton(label: context.l.save, loading: _saving, onPressed: _save),
            ]),
          ),
        ]),
      ),
    );
  }
}
