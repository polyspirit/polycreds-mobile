import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../util/format.dart';
import '../util/rich_text.dart';

/// Quill styles matching the note typography in the design.
DefaultStyles noteStyles(BuildContext context, {double fontSize = 17}) {
  final c = context.c;
  final base = TextStyle(fontSize: fontSize, height: 1.55, color: c.text, fontFamily: kFont);
  const none = HorizontalSpacing.zero;
  const gap = VerticalSpacing(0, 10);
  return DefaultStyles(
    paragraph: DefaultTextBlockStyle(base, none, gap, VerticalSpacing.zero, null),
    h1: DefaultTextBlockStyle(
        base.copyWith(fontSize: fontSize + 7, fontWeight: FontWeight.w700, height: 1.3), none, const VerticalSpacing(12, 4), VerticalSpacing.zero, null),
    h2: DefaultTextBlockStyle(
        base.copyWith(fontSize: fontSize + 3, fontWeight: FontWeight.w700, height: 1.3), none, const VerticalSpacing(10, 4), VerticalSpacing.zero, null),
    h3: DefaultTextBlockStyle(
        base.copyWith(fontSize: fontSize + 1, fontWeight: FontWeight.w700, height: 1.3), none, const VerticalSpacing(8, 4), VerticalSpacing.zero, null),
    bold: const TextStyle(fontWeight: FontWeight.w700),
    italic: const TextStyle(fontStyle: FontStyle.italic),
    underline: const TextStyle(decoration: TextDecoration.underline),
    strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
    link: TextStyle(color: c.accent, decoration: TextDecoration.underline, decorationColor: c.accent),
    inlineCode: InlineCodeStyle(
      style: TextStyle(fontFamily: kMono, fontSize: fontSize - 2, color: c.text),
      backgroundColor: c.surface2,
      radius: const Radius.circular(6),
    ),
    code: DefaultTextBlockStyle(
      TextStyle(fontFamily: kMono, fontSize: 14, height: 1.6, color: c.text),
      none,
      const VerticalSpacing(8, 8),
      VerticalSpacing.zero,
      BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(12)),
    ),
    lists: DefaultListBlockStyle(base, none, const VerticalSpacing(3, 3), VerticalSpacing.zero, null, null),
    quote: DefaultTextBlockStyle(
      base.copyWith(color: c.text2),
      none,
      gap,
      VerticalSpacing.zero,
      BoxDecoration(border: Border(left: BorderSide(color: c.border, width: 4))),
    ),
    placeHolder: DefaultTextBlockStyle(base.copyWith(color: c.text3), none, gap, VerticalSpacing.zero, null),
  );
}

void _openLink(String url) {
  final uri = launchableUrl(url);
  if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Read-only rendering of a note document.
class NoteView extends StatefulWidget {
  const NoteView({super.key, required this.raw, this.fontSize = 17});

  /// Stored note (Delta JSON or plain text).
  final String? raw;
  final double fontSize;

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late QuillController _controller = _make();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  QuillController _make() => QuillController(
        document: parseNote(widget.raw),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );

  @override
  void didUpdateWidget(covariant NoteView old) {
    super.didUpdateWidget(old);
    if (old.raw != widget.raw) {
      _controller.dispose();
      _controller = _make();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => QuillEditor(
        controller: _controller,
        focusNode: _focus,
        scrollController: _scroll,
        config: QuillEditorConfig(
          scrollable: false,
          expands: false,
          showCursor: false,
          enableInteractiveSelection: true,
          padding: EdgeInsets.zero,
          customStyles: noteStyles(context, fontSize: widget.fontSize),
          onLaunchUrl: _openLink,
          showCodeBlockLineNumbers: false,
        ),
      );
}

/// Editable note body (no toolbar; pass the controller to a toolbar separately).
class NoteEditorField extends StatelessWidget {
  const NoteEditorField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    this.placeholder,
    this.fontSize = 17,
    this.scrollable = true,
    this.minHeight,
  });

  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final String? placeholder;
  final double fontSize;
  final bool scrollable;
  final double? minHeight;

  @override
  Widget build(BuildContext context) => QuillEditor(
        controller: controller,
        focusNode: focusNode,
        scrollController: scrollController,
        config: QuillEditorConfig(
          scrollable: scrollable,
          expands: false,
          padding: EdgeInsets.zero,
          placeholder: placeholder,
          minHeight: minHeight,
          customStyles: noteStyles(context, fontSize: fontSize),
          onLaunchUrl: _openLink,
          showCodeBlockLineNumbers: false,
        ),
      );
}
