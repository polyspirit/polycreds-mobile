import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import 'l10n/l10n.dart';
import 'screens/auth/code_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/pin_screens.dart';
import 'screens/auth/server_screen.dart';
import 'screens/home_shell.dart';
import 'state/session.dart';
import 'state/settings.dart';
import 'state/vault.dart';
import 'theme/app_colors.dart';

class PolyCredsApp extends StatelessWidget {
  const PolyCredsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.select<Settings, ThemeMode>((s) => s.themeMode);
    final locale = context.select<Settings, Locale?>((s) => s.locale);
    return MaterialApp(
      title: 'PolyCreds',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(AppColors.light, Brightness.light),
      darkTheme: buildTheme(AppColors.dark, Brightness.dark),
      themeMode: mode,
      locale: locale,
      supportedLocales: L10n.supportedLocales,
      localeListResolutionCallback: (device, _) => locale ?? resolveSystemLocale(device),
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      builder: (context, child) {
        setCurrentLocale(Localizations.localeOf(context));
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: child!,
        );
      },
      home: const _Gate(),
    );
  }
}

/// Picks the screen for the current session stage and handles auto-lock.
class _Gate extends StatefulWidget {
  const _Gate();

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> with WidgetsBindingObserver {
  DateTime? _pausedAt;
  SessionStage? _lastStage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = context.read<Session>();
    final timeout = context.read<Settings>().autoLockSeconds;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _pausedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final at = _pausedAt;
      _pausedAt = null;
      if (at != null && timeout >= 0 && DateTime.now().difference(at).inSeconds >= timeout) {
        session.lock();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = context.select<Session, SessionStage>((s) => s.stage);
    if (stage != _lastStage) {
      final signedOut = stage == SessionStage.server || stage == SessionStage.login;
      if (signedOut) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.read<Vault>().clear();
          // Drop screens pushed on the root navigator (details, editors).
          Navigator.of(context).popUntil((r) => r.isFirst);
        });
      }
      if (stage == SessionStage.locked) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
        });
      }
      _lastStage = stage;
    }

    final Widget screen = switch (stage) {
      SessionStage.loading => const Scaffold(),
      SessionStage.server => const ServerScreen(),
      SessionStage.login => const LoginScreen(),
      SessionStage.twoFactor => const CodeScreen(),
      SessionStage.createPin => const PinCreateScreen(),
      SessionStage.locked => const PinUnlockScreen(),
      SessionStage.unlocked => const HomeShell(),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(stage), child: screen),
    );
  }
}
