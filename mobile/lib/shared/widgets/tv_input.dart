import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';

/// Premium, theme-aware text input for TaskVerse.
///
/// - Persian-first (RTL default)
/// - Optional label, icon, hint, helper, error
/// - Supports multiline, obscured, digits-only
/// - Garden at Dawn themed focus glow
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
  }) : assert(minLines == null || minLines > 0),
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
  final bool enabled;
  final bool readOnly;
  final String? errorText;
  final String? helperText;
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
  final bool showCounter;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hasError = errorText != null && errorText!.trim().isNotEmpty;

    final fill = enabled
        ? (isDark ? TvColors.nightSoft : TvColors.sand)
        : scheme.onSurface.withValues(alpha: 0.04);

    final textColor = enabled
        ? (isDark ? Colors.white : TvColors.ink)
        : scheme.onSurface.withValues(alpha: 0.45);

    final accentColor = isDark ? TvColors.mint : TvColors.brandPrimary;
    final borderColor = (isDark ? Colors.white : TvColors.ink).withValues(
      alpha: 0.08,
    );

    OutlineInputBorder makeBorder({required Color color, double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(TvRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final effectiveMaxLines = expands ? null : (obscure ? 1 : (maxLines ?? 1));
    final effectiveMinLines = expands
        ? null
        : (multiline ? (minLines ?? maxLines ?? 1) : null);
    final multiline = (maxLines ?? 1) > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label row
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 4,
            end: 4,
            bottom: 6,
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
                        : (isDark ? TvColors.inkMuted : TvColors.inkSoft),
                    fontWeight: FontWeight.w700,
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

        // Field
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(TvRadius.md),
            boxShadow: hasError
                ? [
                    BoxShadow(
                      color: scheme.error.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType:
                keyboardType ?? (digitsOnly ? TextInputType.number : null),
            obscureText: obscure,
            autofocus: autofocus,
            enabled: enabled,
            readOnly: readOnly,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onTap: onTap,
            textInputAction:
                textInputAction ?? (multiline ? TextInputAction.newline : null),
            textCapitalization: textCapitalization,
            autocorrect: autocorrect,
            enableSuggestions: enableSuggestions,
            minLines: effectiveMinLines,
            maxLines: effectiveMaxLines,
            expands: expands,
            textAlign: centerText ? TextAlign.center : textAlign,
            textDirection: TextDirection.rtl,
            textAlignVertical: multiline
                ? TextAlignVertical.top
                : TextAlignVertical.center,
            inputFormatters: [
              if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null)
                LengthLimitingTextInputFormatter(maxLength),
            ],
            style:
                style ??
                TvTypography.body.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
            cursorColor: accentColor,
            cursorWidth: 1.6,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TvTypography.body.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
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
              filled: false,
              isDense: false,
              contentPadding: EdgeInsets.symmetric(
                horizontal: TvSpacing.md,
                vertical: multiline ? TvSpacing.md : 18,
              ),
              counterText: showCounter ? null : '',
              errorText: null,
              border: makeBorder(color: Colors.transparent),
              enabledBorder: makeBorder(
                color: hasError
                    ? scheme.error.withValues(alpha: 0.7)
                    : borderColor,
              ),
              focusedBorder: makeBorder(
                color: hasError ? scheme.error : accentColor,
                width: 1.5,
              ),
              disabledBorder: makeBorder(
                color: borderColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),

        // Helper / Error
        if (hasError ||
            (helperText != null && helperText!.trim().isNotEmpty)) ...[
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
                      : (isDark ? TvColors.inkMuted : TvColors.inkSoft),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    hasError ? errorText! : helperText!,
                    style: TvTypography.caption.copyWith(
                      color: hasError
                          ? scheme.error
                          : (isDark ? TvColors.inkMuted : TvColors.inkSoft),
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
