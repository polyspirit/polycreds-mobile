import 'package:intl/intl.dart';

import '../l10n/l10n.dart';

String formatDate(DateTime? d, {bool withYear = false}) {
  if (d == null) return '';
  final now = DateTime.now();
  final pattern = withYear || d.year != now.year ? 'd MMMM y' : 'd MMMM';
  return DateFormat(pattern, localeTag).format(d);
}

String credentialsCount(int n) => tr.credentialsCount(n);
String notesCount(int n) => tr.notesCount(n);

String relativeTime(DateTime? d) {
  if (d == null) return tr.neverUsed;
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 5) return tr.activeNow;
  if (diff.inHours < 1) return tr.activeMinutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return tr.activeHoursAgo(diff.inHours);
  if (diff.inDays < 7) return tr.activeDaysAgo(diff.inDays);
  if (diff.inDays < 31) return tr.activeWeeksAgo(diff.inDays ~/ 7);
  return tr.activeOn(formatDate(d));
}

/// Host of a URL for display: "https://github.com/login" -> "github.com/login".
String displayUrl(String url) => url.replaceFirst(RegExp(r'^[a-z]+://', caseSensitive: false), '').replaceFirst(RegExp(r'/$'), '');

Uri? launchableUrl(String url) {
  final u = url.trim();
  if (u.isEmpty) return null;
  return Uri.tryParse(RegExp(r'^[a-z]+://', caseSensitive: false).hasMatch(u) ? u : 'https://$u');
}

/// "p***@example.com"
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at <= 1) return email;
  return '${email[0]}***${email.substring(at)}';
}

String initial(String name) {
  final t = name.trim();
  return t.isEmpty ? '?' : String.fromCharCode(t.runes.first).toUpperCase();
}
