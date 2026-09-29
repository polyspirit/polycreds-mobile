import 'dart:math';

import '../l10n/l10n.dart';

/// Character sets match the web generator (resources/js/classes/PasswordGenerator.js).
enum CharSet {
  digits('0–9', '0123456789'),
  lower('a–z', 'abcdefghijklmnopqrstuvwxyz'),
  upper('A–Z', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
  symbols('!@#\$%', '!@#\$%-_'),
  extended('{}[]~', r'^&*()+~№;%:?=[]{}\|/,.<>');

  const CharSet(this.sample, this.chars);

  final String sample;
  final String chars;

  String get label => switch (this) {
        digits => tr.setDigits,
        lower => tr.setLower,
        upper => tr.setUpper,
        symbols => tr.setSymbols,
        extended => tr.setExtended,
      };
}

final _rnd = Random.secure();

String generatePassword(int length, Set<CharSet> sets) {
  final active = sets.isEmpty ? {CharSet.lower} : sets;
  final pool = active.map((s) => s.chars).join().split('').toSet().toList();
  // Guarantee at least one char of each chosen set, then shuffle.
  final out = <String>[
    for (final s in active) s.chars[_rnd.nextInt(s.chars.length)],
  ];
  while (out.length < length) {
    out.add(pool[_rnd.nextInt(pool.length)]);
  }
  out.shuffle(_rnd);
  return out.take(length).join();
}

enum Strength {
  weak(1),
  fair(2),
  good(3),
  strong(4),
  veryStrong(4);

  const Strength(this.bars);

  final int bars;

  String get label => switch (this) {
        weak => tr.strengthWeak,
        fair => tr.strengthFair,
        good => tr.strengthGood,
        strong => tr.strengthStrong,
        veryStrong => tr.strengthVeryStrong,
      };
}

/// Rough entropy estimate from the character classes present.
double passwordBits(String p) {
  if (p.isEmpty) return 0;
  var pool = 0;
  if (RegExp('[0-9]').hasMatch(p)) pool += 10;
  if (RegExp('[a-z]').hasMatch(p)) pool += 26;
  if (RegExp('[A-Z]').hasMatch(p)) pool += 26;
  if (RegExp('[^0-9a-zA-Z]').hasMatch(p)) pool += 33;
  return p.length * log(pool) / ln2;
}

Strength passwordStrength(String p) {
  final bits = passwordBits(p);
  if (bits < 36) return Strength.weak;
  if (bits < 60) return Strength.fair;
  if (bits < 80) return Strength.good;
  if (bits < 110) return Strength.strong;
  return Strength.veryStrong;
}
