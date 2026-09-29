import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

/// Notes are stored as Quill Delta JSON by the web app; old records may be plain text.
Document parseNote(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.isEmpty) return Document();
  try {
    final decoded = jsonDecode(text);
    final ops = decoded is Map ? decoded['ops'] : decoded;
    if (ops is List && ops.isNotEmpty) {
      final doc = Document.fromJson(ops.map(_normalizeOp).toList());
      return doc;
    }
  } catch (_) {
    // Not JSON or unsupported delta: show as plain text.
  }
  return Document()..insert(0, raw!);
}

/// Web Quill 2 marks code blocks with the language name ("plain", "javascript").
/// flutter_quill expects `true`.
Map<String, dynamic> _normalizeOp(dynamic op) {
  final m = Map<String, dynamic>.from(op as Map);
  final attrs = m['attributes'];
  if (attrs is Map && attrs['code-block'] != null && attrs['code-block'] != true) {
    m['attributes'] = {...Map<String, dynamic>.from(attrs), 'code-block': true};
  }
  final insert = m['insert'];
  // Embeds not supported by the mobile editor (image/video/formula) become text.
  if (insert is Map) {
    final kind = insert.keys.isNotEmpty ? insert.keys.first : 'embed';
    final value = insert[kind];
    m['insert'] = kind == 'image' || kind == 'video' ? '[$kind: $value]' : '$value';
    m.remove('attributes');
  }
  return m;
}

/// Serializes to the same shape the web editor saves: {"ops":[...]}.
String serializeNote(Document doc) => jsonEncode({'ops': doc.toDelta().toJson()});

bool isNoteEmpty(Document doc) => doc.toPlainText().trim().isEmpty;

String notePlainText(String? raw) => parseNote(raw).toPlainText().trim();
