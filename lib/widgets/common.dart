import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

/// Rounded press feedback used by all custom controls.
class Pressable extends StatelessWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.radius = 0,
    this.color = Colors.transparent,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double radius;
  final Color color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget w = Material(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: radius > 0 ? Clip.antiAlias : Clip.none,
      child: InkWell(onTap: onTap, onLongPress: onLongPress, child: child),
    );
    if (semanticLabel != null) w = Semantics(button: true, label: semanticLabel, child: w);
    return w;
  }
}

enum ButtonKind { primary, secondary, danger, dangerOutline, dangerSoft }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = ButtonKind.primary,
    this.icon,
    this.loading = false,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonKind kind;
  final IconData? icon;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, fg, border) = switch (kind) {
      ButtonKind.primary => (c.accent, c.onAccent, null),
      ButtonKind.secondary => (c.surface, c.text, c.border),
      ButtonKind.danger => (c.danger, c.onDanger, null),
      ButtonKind.dangerOutline => (c.surface, c.danger, c.border),
      ButtonKind.dangerSoft => (c.dangerSoft, c.danger, null),
    };
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: border != null ? BorderSide(color: border) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            height: height,
            child: Center(
              child: loading
                  ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
                        Flexible(
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: fg, fontSize: height >= 54 ? 17 : 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 44×44 icon button.
class IconBtn extends StatelessWidget {
  const IconBtn({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
    this.background,
    this.border = false,
    this.size = 22,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? background;
  final bool border;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: background ?? Colors.transparent,
          shape: CircleBorder(side: border ? BorderSide(color: c.border) : BorderSide.none),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(width: 44, height: 44, child: Icon(icon, size: size, color: color ?? c.text2)),
          ),
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: context.c.text2),
      );
}

/// Surface card with border; [children] are separated by hairlines.
class CardList extends StatelessWidget {
  const CardList({super.key, required this.children, this.borderColor, this.borderWidth = 1});

  final List<Widget> children;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? c.border, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) Divider(height: 1, thickness: 1, color: c.border),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.onTap, this.radius = 16});

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: BorderSide(color: c.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class FilterChipPill extends StatelessWidget {
  const FilterChipPill({super.key, required this.label, required this.selected, this.onTap, this.onLongPress});

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: selected ? c.text : c.surface,
      shape: StadiumBorder(side: selected ? BorderSide.none : BorderSide(color: c.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: selected ? c.bg : c.text,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class ChipsRow extends StatelessWidget {
  const ChipsRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 8), children[i]],
        ]),
      );
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    required this.hint,
    this.controller,
    this.onTap,
    this.onChanged,
    this.autofocus = false,
    this.readOnly = false,
  });

  final String hint;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 20, color: c.text3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 16, color: c.text),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: c.text3, fontSize: 16),
              ),
            ),
          ),
          if (controller != null && !readOnly)
            ListenableBuilder(
              listenable: controller!,
              builder: (context, _) => controller!.text.isEmpty
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () {
                        controller!.clear();
                        onChanged?.call('');
                      },
                      child: Semantics(
                        button: true,
                        label: context.l.clear,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(color: c.text3, shape: BoxShape.circle),
                          child: Icon(LucideIcons.x, size: 16, color: c.surface2),
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

/// Labelled input field from the forms in the design.
class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.mono = false,
    this.error,
    this.helper,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.autofillHints,
    this.trailing,
    this.height = 48,
    this.fontSize = 16,
    this.maxLines = 1,
    this.enabled = true,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final bool mono;
  final String? error;
  final String? helper;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final Widget? trailing;
  final double height;
  final double fontSize;
  final int maxLines;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  final _focus = FocusNode();
  late bool _hidden = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasError = widget.error != null;
    final borderColor = hasError ? c.danger : (_focus.hasFocus ? c.accent : c.border);
    final borderWidth = hasError || _focus.hasFocus ? 2.0 : 1.0;
    final multiline = widget.maxLines > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.text2)),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: BoxConstraints(minHeight: widget.height),
          padding: EdgeInsets.only(
            left: 14 - (borderWidth - 1),
            right: (widget.obscure || widget.trailing != null ? 4 : 14) - (borderWidth - 1),
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: multiline ? 12 : 0),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    obscureText: _hidden,
                    autocorrect: !widget.obscure && !widget.mono,
                    enableSuggestions: !widget.obscure && !widget.mono,
                    keyboardType: multiline ? TextInputType.multiline : widget.keyboardType,
                    textInputAction: multiline ? TextInputAction.newline : widget.textInputAction,
                    onSubmitted: widget.onSubmitted,
                    onChanged: widget.onChanged,
                    autofocus: widget.autofocus,
                    autofillHints: widget.autofillHints,
                    inputFormatters: widget.inputFormatters,
                    minLines: multiline ? 2 : 1,
                    maxLines: widget.obscure ? 1 : widget.maxLines,
                    style: TextStyle(
                      fontSize: widget.mono ? widget.fontSize - 1 : widget.fontSize,
                      fontFamily: widget.mono ? kMono : kFont,
                      color: c.text,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: TextStyle(color: c.text3),
                    ),
                  ),
                ),
              ),
              if (widget.obscure)
                IconBtn(
                  icon: _hidden ? LucideIcons.eye : LucideIcons.eyeOff,
                  label: _hidden ? context.l.showPassword : context.l.hidePassword,
                  onPressed: () => setState(() => _hidden = !_hidden),
                ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(children: [
            Icon(LucideIcons.circleAlert, size: 15, color: c.danger),
            const SizedBox(width: 6),
            Expanded(child: Text(widget.error!, style: TextStyle(fontSize: 13, color: c.danger))),
          ]),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 6),
          Text(widget.helper!, style: TextStyle(fontSize: 13, color: c.text2)),
        ],
      ],
    );
  }
}

/// iOS-style switch with the success track color from the design.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: context.c.success,
        inactiveTrackColor: context.c.surface2,
      );
}

class Segmented<T> extends StatelessWidget {
  const Segmented({super.key, required this.value, required this.options, required this.onChanged});

  final T value;
  final List<(T, String, IconData?)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (final (v, label, icon) in options)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(v),
                child: Semantics(
                  selected: v == value,
                  button: true,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 34,
                    decoration: BoxDecoration(
                      color: v == value ? c.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: v == value
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 3, offset: const Offset(0, 1))]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 16, color: v == value ? c.text : c.text2),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              color: v == value ? c.text : c.text2,
                              fontWeight: v == value ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "‹ Title" back link used on pushed screens.
class BackLink extends StatelessWidget {
  const BackLink({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: context.l.backTo(label),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        child: SizedBox(
          height: 44,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.chevronLeft, size: 26, color: c.accent),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(label,
                  overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17, color: c.accent)),
            ),
            const SizedBox(width: 8),
          ]),
        ),
      ),
    );
  }
}

class TextLink extends StatelessWidget {
  const TextLink({super.key, required this.label, this.onTap, this.bold = false, this.color, this.fontSize = 17});

  final String label;
  final VoidCallback? onTap;
  final bool bold;
  final Color? color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: onTap == null ? c.text3 : (color ?? c.accent),
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Top bar of modal edit screens: "Отмена · Title · Сохранить".
class ModalBar extends StatelessWidget {
  const ModalBar({
    super.key,
    required this.title,
    required this.onDone,
    this.doneLabel,
    this.saving = false,
    this.center,
  });

  final String title;
  final VoidCallback? onDone;
  final String? doneLabel;
  final bool saving;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          TextLink(label: context.l.cancel, onTap: () => Navigator.of(context).maybePop()),
          Expanded(
            child: Center(
              child: center ??
                  Text(title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
            ),
          ),
          if (saving)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: c.accent)),
            )
          else
            TextLink(label: doneLabel ?? context.l.save, bold: true, onTap: onDone),
        ],
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.text, {super.key, this.size = 32});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(fontSize: size, fontWeight: FontWeight.w700, letterSpacing: size >= 30 ? -0.5 : -0.4, height: 1.2),
      );
}

/// Letter or icon tile in front of list rows.
class ItemTile extends StatelessWidget {
  const ItemTile({super.key, this.letter, this.icon, required this.bg, required this.fg, this.size = 36});

  final String? letter;
  final IconData? icon;
  final Color bg;
  final Color fg;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.28)),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: size * 0.55, color: fg)
            : Text(letter ?? '', style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: size * 0.43)),
      );
}

class Badge56 extends StatelessWidget {
  const Badge56({super.key, required this.icon, this.danger = false, this.round = false});

  final IconData icon;
  final bool danger;
  final bool round;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: danger ? c.dangerSoft : c.accentSoft,
        borderRadius: BorderRadius.circular(round ? 28 : 16),
      ),
      child: Icon(icon, size: 28, color: danger ? c.danger : c.accent),
    );
  }
}

/// Row with a chevron, used for settings/profile navigation.
class NavRow extends StatelessWidget {
  const NavRow({super.key, required this.label, this.value, this.leading, this.onTap, this.minHeight = 52, this.trailing});

  final String label;
  final String? value;
  final Widget? leading;
  final VoidCallback? onTap;
  final double minHeight;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: EdgeInsets.only(left: leading != null ? 14 : 16, right: 14),
          child: Row(children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            if (value != null) ...[
              Text(value!, style: TextStyle(fontSize: 15, color: c.text2)),
              const SizedBox(width: 10),
            ],
            trailing ?? Icon(LucideIcons.chevronRight, size: 18, color: c.text3),
          ]),
        ),
      ),
    );
  }
}

class CenteredLoader extends StatelessWidget {
  const CenteredLoader({super.key});

  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: context.c.accent));
}

class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.cloudOff, size: 40, color: c.text3),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: c.text2, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: AppButton(label: context.l.retry, onPressed: onRetry, kind: ButtonKind.secondary, height: 48),
          ),
        ]),
      ),
    );
  }
}
