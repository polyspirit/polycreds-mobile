import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Design tokens from the mockups (`L` and `D` objects in design/screens).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.text2,
    required this.text3,
    required this.border,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.danger,
    required this.dangerSoft,
    required this.onDanger,
    required this.success,
    required this.successSoft,
    required this.star,
    required this.scrim,
    required this.tab,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color text;
  final Color text2;
  final Color text3;
  final Color border;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;
  final Color danger;
  final Color dangerSoft;
  final Color onDanger;
  final Color success;
  final Color successSoft;
  final Color star;
  final Color scrim;
  final Color tab;

  static const light = AppColors(
    bg: Color(0xFFF3F4F7),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE9ECF1),
    text: Color(0xFF15171C),
    text2: Color(0xFF596072),
    text3: Color(0xFF6B7284),
    border: Color(0xFFE0E3EA),
    accent: Color(0xFF2A55D0),
    accentSoft: Color(0xFFE5EBFA),
    onAccent: Color(0xFFFFFFFF),
    danger: Color(0xFFB8322A),
    dangerSoft: Color(0xFFFBE9E7),
    onDanger: Color(0xFFFFFFFF),
    success: Color(0xFF1C7447),
    successSoft: Color(0xFFE3F2EA),
    star: Color(0xFFB7791F),
    scrim: Color(0x730D0F14),
    tab: Color(0xF0FFFFFF),
  );

  static const dark = AppColors(
    bg: Color(0xFF0D0F14),
    surface: Color(0xFF161920),
    surface2: Color(0xFF1F232C),
    text: Color(0xFFECEEF3),
    text2: Color(0xFFA0A7B6),
    text3: Color(0xFF8A91A1),
    border: Color(0xFF2A2F3A),
    accent: Color(0xFF7C9CFF),
    accentSoft: Color(0xFF1B2542),
    onAccent: Color(0xFF0B1020),
    danger: Color(0xFFFF8A80),
    dangerSoft: Color(0xFF3A1A19),
    onDanger: Color(0xFF2A0B09),
    success: Color(0xFF6FD39E),
    successSoft: Color(0xFF15301F),
    star: Color(0xFFF0B44C),
    scrim: Color(0x99000000),
    tab: Color(0xF5161920),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      text: l(text, other.text),
      text2: l(text2, other.text2),
      text3: l(text3, other.text3),
      border: l(border, other.border),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      onAccent: l(onAccent, other.onAccent),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      onDanger: l(onDanger, other.onDanger),
      success: l(success, other.success),
      successSoft: l(successSoft, other.successSoft),
      star: l(star, other.star),
      scrim: l(scrim, other.scrim),
      tab: l(tab, other.tab),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}

const kFont = 'Onest';
const kMono = 'JetBrainsMono';

ThemeData buildTheme(AppColors c, Brightness brightness) {
  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    fontFamily: kFont,
    scaffoldBackgroundColor: c.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.accent,
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      error: c.danger,
      surface: c.surface,
      onSurface: c.text,
    ),
    splashFactory: InkSparkle.splashFactory,
    extensions: [c],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: c.text, displayColor: c.text, fontFamily: kFont),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.accent,
      selectionColor: c.accent.withValues(alpha: 0.3),
      selectionHandleColor: c.accent,
    ),
    dividerColor: c.border,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}
