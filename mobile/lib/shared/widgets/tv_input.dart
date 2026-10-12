
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';

/// Premium, theme-aware text input for TaskVerse.
///
/// Designed for Persian-first interfaces with RTL text direction,
/// accessible focus states, optional validation feedback, and
/// consistent Garden at Dawn styling.
class TvInput extends StatelessWidget {
  const TvInput({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.digitsOnly = false,
    this.maxLength,
    this.suffix,
    this.textAlign = TextAlign.right,
    this.centerText = false,
    this.style,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.errorText,
    this.helperText,
    this.prefix,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.expands = false,
    this.showCounter = false,
    this.required = false,
  })  : assert(minLines == null || minLines > 0),
        assert(maxLines == null || maxLines > 0),
        assert(!expands || (minLines == null && maxLines == null));

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool digitsOnly;
  final int? maxLength;
  final Widget? suffix;
  final TextAlign textAlign;
  final bool centerText;
  final TextStyle? style;
  final bool autofocus;

  /// Enables or disables editing and interaction.
  final bool enabled;

  /// Allows focus and selection without editing.
  final bool readOnly;

  /// Optional validation error shown beneath the input.
  final String? errorText;

  /// Optional supporting text shown beneath the input.
  final String? helperText;

  /// Optional leading widget, placed before the text field content.
  final Widget? prefix;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? minLines;
  final int? maxLines;
  final bool expands;

  /// Whether to show the character counter when maxLength is specified.
  final bool showCounter;

  /// Adds a visual required marker beside the label.
  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hasError = errorText != null && errorText!.trim().isNotEmpty;

    final fill = enabled
        ? (isDark ? TvColors.nightSoft : TvColors.paper)
        : scheme.onSurface.withValues(alpha: 0.045);

    final textColor = enabled
        ? scheme.onSurface
        : scheme.onSurface.withValues(alpha: 0.45);

    final accentColor = isDark ? TvColors.mint : TvColors.brandPrimary;
    final borderColor = scheme.outlineVariant;

    OutlineInputBorder makeBorder({
      required Color color,
      double width = 1,
    }) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(TvRadius.lg),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 4,
            end: 4,
            bottom: TvSpacing.xs,
          ),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TvTypography.label.copyWith(
                    color: hasError
                        ? scheme.error
                        : enabled
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (required) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TvTypography.label.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(TvRadius.lg),
            boxShadow: hasError
                ? [
                    BoxShadow(
                      color: scheme.error.withValues(alpha: 0.055),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType ??
                (digitsOnly ? TextInputType.number : null),
            obscureText: obscure,
            autofocus: autofocus,
            enabled: enabled,
            readOnly: readOnly,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onTap: onTap,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            autocorrect: autocorrect,
            enableSuggestions: enableSuggestions,
            minLines: expands ? null : minLines,
            maxLines: expands ? null : (obscure ? 1 : maxLines),
            expands: expands,
            textAlign: centerText ? TextAlign.center : textAlign,
            textDirection: TextDirection.rtl,
            textAlignVertical: expands
                ? TextAlignVertical.top
                : TextAlignVertical.center,
            inputFormatters: [
              if (digitsOnly)
                FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            style: style ??
                TvTypography.body.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
            cursorColor: accentColor,
            cursorWidth: 1.6,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TvTypography.body.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.78),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: icon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: TvSpacing.sm,
                        end: TvSpacing.xs,
                      ),
                      child: Icon(
                        icon,
                        size: 21,
                        color: hasError
                            ? scheme.error
                            : enabled
                                ? accentColor
                                : scheme.onSurfaceVariant,
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 48,
              ),
              prefix: prefix,
              suffixIcon: suffix,
              filled: true,
              fillColor: Colors.transparent,
              isDense: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: TvSpacing.md,
                vertical: 18,
              ),
              counterText: showCounter ? null : '',
              errorText: null,
              border: makeBorder(color: Colors.transparent),
              enabledBorder: makeBorder(
                color: hasError
                    ? scheme.error.withValues(alpha: 0.8)
                    : borderColor.withValues(alpha: 0.72),
              ),
              focusedBorder: makeBorder(
                color: hasError ? scheme.error : accentColor,
                width: 1.5,
              ),
              disabledBorder: makeBorder(
                color: borderColor.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
        if (hasError || (helperText != null && helperText!.isNotEmpty)) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, end: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasError
                      ? Icons.error_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 14,
                  color: hasError
                      ? scheme.error
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    hasError ? errorText! : helperText!,
                    style: TvTypography.caption.copyWith(
                      color: hasError
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
