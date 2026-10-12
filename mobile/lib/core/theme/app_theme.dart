
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'colors.dart';
import 'motion.dart';
import 'spacing.dart';
import 'typography.dart';

/// TaskVerse theme factory.
///
/// Three coordinated themes:
/// - Light: warm, calm, garden-inspired surfaces.
/// - Dark: deep green surfaces with comfortable contrast.
/// - AMOLED: true-black backgrounds for OLED displays.
///
/// Prefer Theme.of(context) and Theme extensions over hardcoded
/// colors and component styling inside widgets.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _base(
        brightness: Brightness.light,
        background: TvColors.sand,
        surface: TvColors.paper,
        surfaceElevated: TvColors.cloud,
        onBackground: TvColors.ink,
        onSurface: TvColors.ink,
        onSurfaceMuted: TvColors.inkSoft,
        onSurfaceSubtle: TvColors.inkMuted,
        isAmoled: false,
      );

  static ThemeData dark() => _base(
        brightness: Brightness.dark,
        background: TvColors.night,
        surface: TvColors.nightSoft,
        surfaceElevated: TvColors.nightElevated,
        onBackground: const Color(0xFFEDEFEE),
        onSurface: const Color(0xFFEDEFEE),
        onSurfaceMuted: const Color(0xFF98A29E),
        onSurfaceSubtle: const Color(0xFF75817C),
        isAmoled: false,
      );

  static ThemeData amoled() => _base(
        brightness: Brightness.dark,
        background: TvColors.amoled,
        surface: TvColors.amoled,
        surfaceElevated: const Color(0xFF101311),
        onBackground: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFFF2F5F3),
        onSurfaceMuted: const Color(0xFFADB8B2),
        onSurfaceSubtle: const Color(0xFF7D8983),
        isAmoled: true,
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceElevated,
    required Color onBackground,
    required Color onSurface,
    required Color onSurfaceMuted,
    required Color onSurfaceSubtle,
    required bool isAmoled,
  }) {
    final isLight = brightness == Brightness.light;

    final outline = isLight
        ? const Color(0xFFE5E0D7)
        : const Color(0xFF303A35);

    final subtleSurface = isLight
        ? const Color(0xFFF0ECE4)
        : (isAmoled
            ? const Color(0xFF080A09)
            : const Color(0xFF19211D));

    final scheme = ColorScheme(
      brightness: brightness,
      primary: TvColors.brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: isLight
          ? TvColors.brandPrimarySoft
          : const Color(0xFF174B36),
      onPrimaryContainer:
          isLight ? TvColors.brandPrimaryDeep : const Color(0xFFD5E5DE),
      secondary: TvColors.mint,
      onSecondary: const Color(0xFF06291F),
      secondaryContainer: isLight
          ? TvColors.mintSoft
          : const Color(0xFF164B3D),
      onSecondaryContainer:
          isLight ? const Color(0xFF07523D) : const Color(0xFFC8F3E4),
      tertiary: TvColors.sunGold,
      onTertiary: const Color(0xFF352407),
      tertiaryContainer: isLight
          ? TvColors.sunGoldSoft
          : const Color(0xFF493719),
      onTertiaryContainer:
          isLight ? const Color(0xFF60420C) : const Color(0xFFFCEFCE),
      error: TvColors.rose,
      onError: Colors.white,
      errorContainer:
          isLight ? TvColors.roseSoft : const Color(0xFF512631),
      onErrorContainer:
          isLight ? const Color(0xFF8D263C) : const Color(0xFFFBD9E0),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: background,
      surfaceContainerLow: subtleSurface,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceElevated,
      surfaceContainerHighest: isLight
          ? const Color(0xFFEAE5DC)
          : (isAmoled
              ? const Color(0xFF151916)
              : const Color(0xFF252E29)),
      onSurfaceVariant: onSurfaceMuted,
      outline: isLight ? const Color(0xFFB8C0BA) : const Color(0xFF64716A),
      outlineVariant: outline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isLight
          ? const Color(0xFF242B27)
          : const Color(0xFFF5F1EA),
      onInverseSurface: isLight
          ? const Color(0xFFF5F1EA)
          : const Color(0xFF1A1F1D),
      inversePrimary:
          isLight ? const Color(0xFFB7DCCB) : TvColors.brandPrimary,
    );

    final defaultTextTheme = TvTypography.bodyTextTheme(
      brightness: brightness,
      primary: onSurface,
      secondary: onSurfaceMuted,
      subtle: onSurfaceSubtle,
    );

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(TvRadius.lg),
      borderSide: BorderSide(color: outline, width: 1),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(TvRadius.lg),
      borderSide: BorderSide(
        color: TvColors.mint,
        width: 1.5,
      ),
    );

    final disabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(TvRadius.lg),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: TvTypography.fontFamily,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerColor: outline,
      disabledColor: onSurfaceSubtle.withValues(alpha: 0.55),

      textTheme: defaultTextTheme.copyWith(
        displayLarge: TvTypography.display.copyWith(color: onBackground),
        displayMedium: TvTypography.display.copyWith(
          color: onBackground,
          fontSize: 30,
        ),
        displaySmall: TvTypography.headline.copyWith(color: onBackground),
        headlineLarge: TvTypography.headline.copyWith(color: onBackground),
        headlineMedium: TvTypography.headline.copyWith(
          color: onBackground,
          fontSize: 22,
        ),
        headlineSmall: TvTypography.title.copyWith(color: onBackground),
        titleLarge: TvTypography.headline.copyWith(
          color: onSurface,
          fontSize: 20,
        ),
        titleMedium: TvTypography.title.copyWith(color: onSurface),
        titleSmall: TvTypography.label.copyWith(color: onSurfaceMuted),
        bodyLarge: TvTypography.body.copyWith(color: onSurface),
        bodyMedium: TvTypography.bodySmall.copyWith(color: onSurface),
        bodySmall: TvTypography.caption.copyWith(color: onSurfaceMuted),
        labelLarge: TvTypography.label.copyWith(color: onSurface),
        labelMedium: TvTypography.caption.copyWith(color: onSurfaceMuted),
        labelSmall: TvTypography.caption.copyWith(color: onSurfaceSubtle),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TvTypography.title.copyWith(
          color: onBackground,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: onBackground, size: 22),
        actionsIconTheme: IconThemeData(color: onBackground, size: 22),
      ),

      cardTheme: CardThemeData(
        color: surfaceElevated,
        elevation: 0,
        shadowColor: TvColors.brandPrimary.withValues(alpha: 0.05),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.xl),
          side: BorderSide(
            color: outline.withValues(alpha: isLight ? 0.75 : 0.55),
            width: 0.7,
          ),
        ),
      ),

      iconTheme: IconThemeData(
        color: onSurfaceMuted,
        size: 22,
      ),

      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 0.8,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: subtleSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.md,
          vertical: TvSpacing.md,
        ),
        hintStyle: TvTypography.bodySmall.copyWith(
          color: onSurfaceSubtle,
        ),
        labelStyle: TvTypography.bodySmall.copyWith(
          color: onSurfaceMuted,
        ),
        floatingLabelStyle: TvTypography.label.copyWith(
          color: TvColors.mint,
        ),
        errorStyle: TvTypography.caption.copyWith(
          color: scheme.error,
        ),
        border: disabledBorder,
        enabledBorder: outlineBorder,
        focusedBorder: focusedBorder,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TvRadius.lg),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TvRadius.lg),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        disabledBorder: disabledBorder,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TvColors.brandPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: onSurfaceSubtle.withValues(alpha: 0.15),
          disabledForegroundColor: onSurfaceSubtle,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: TvSpacing.lg,
            vertical: TvSpacing.md,
          ),
          elevation: 0,
          shadowColor: TvColors.brandPrimary.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TvRadius.lg),
          ),
          textStyle: TvTypography.title.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          animationDuration: TvMotion.quick,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceElevated,
          foregroundColor: onSurface,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(
            horizontal: TvSpacing.lg,
            vertical: TvSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TvRadius.lg),
            side: BorderSide(color: outline),
          ),
          textStyle: TvTypography.label.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TvColors.brandPrimary,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(
            horizontal: TvSpacing.lg,
            vertical: TvSpacing.md,
          ),
          side: BorderSide(
            color: isLight
                ? TvColors.brandPrimary.withValues(alpha: 0.35)
                : const Color(0xFF466C59),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TvRadius.lg),
          ),
          textStyle: TvTypography.label.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TvColors.brandPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: TvSpacing.md,
            vertical: TvSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TvRadius.md),
          ),
          textStyle: TvTypography.label.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: subtleSurface,
        selectedColor: isLight
            ? TvColors.mintSoft
            : const Color(0xFF174B3A),
        disabledColor: onSurfaceSubtle.withValues(alpha: 0.12),
        secondarySelectedColor: isLight
            ? TvColors.brandPrimarySoft
            : const Color(0xFF244B39),
        labelStyle: TvTypography.label.copyWith(color: onSurface),
        secondaryLabelStyle: TvTypography.label.copyWith(
          color: isLight ? TvColors.brandPrimaryDeep : TvColors.mintSoft,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.sm,
          vertical: TvSpacing.xs,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.full),
        ),
        showCheckmark: false,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight
            ? const Color(0xFF202923)
            : const Color(0xFF29332D),
        contentTextStyle: TvTypography.bodySmall.copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(
          TvSpacing.md,
          TvSpacing.sm,
          TvSpacing.md,
          TvSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.lg),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.xl),
          side: BorderSide(color: outline.withValues(alpha: 0.75)),
        ),
        titleTextStyle: TvTypography.title.copyWith(color: onSurface),
        contentTextStyle: TvTypography.bodySmall.copyWith(
          color: onSurfaceMuted,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        modalBackgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: onSurfaceSubtle.withValues(alpha: 0.55),
        dragHandleSize: const Size(36, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(TvRadius.xl),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: TvColors.mint,
        foregroundColor: const Color(0xFF06291F),
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.lg),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: isLight
            ? TvColors.brandPrimarySoft
            : const Color(0xFF234B39),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.md),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (states) {
            final selected = states.contains(WidgetState.selected);
            return TvTypography.caption.copyWith(
              color: selected ? TvColors.mint : onSurfaceMuted,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
          (states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? TvColors.mint : onSurfaceMuted,
              size: 22,
            );
          },
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: TvColors.mint,
        linearTrackColor: isLight
            ? TvColors.brandPrimarySoft
            : const Color(0xFF26352D),
        circularTrackColor: isLight
            ? TvColors.brandPrimarySoft
            : const Color(0xFF26352D),
        linearMinHeight: 5,
        refreshBackgroundColor: surfaceElevated,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight
              ? const Color(0xFF202923)
              : const Color(0xFF354139),
          borderRadius: BorderRadius.circular(TvRadius.sm),
        ),
        textStyle: TvTypography.caption.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.sm,
          vertical: TvSpacing.xs,
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),

      listTileTheme: ListTileThemeData(
        textColor: onSurface,
        iconColor: onSurfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.md,
          vertical: TvSpacing.xs,
        ),
        minVerticalPadding: TvSpacing.sm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.md),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.lg),
          side: BorderSide(color: outline),
        ),
        textStyle: TvTypography.bodySmall.copyWith(color: onSurface),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: TvColors.brandPrimary,
        unselectedLabelColor: onSurfaceMuted,
        labelStyle: TvTypography.label.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TvTypography.label,
        indicatorColor: TvColors.mint,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: outline,
        overlayColor: WidgetStatePropertyAll(
          TvColors.mint.withValues(alpha: 0.08),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return onSurfaceSubtle;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return TvColors.brandPrimary;
          }
          return subtleSurface;
        }),
        trackOutlineColor:
            WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return TvColors.brandPrimary;
          }
          return outline;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: BorderSide(color: onSurfaceSubtle, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return TvColors.brandPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return TvColors.brandPrimary;
          }
          return onSurfaceSubtle;
        }),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: TvColors.brandPrimary,
        inactiveTrackColor: outline,
        thumbColor: TvColors.mint,
        overlayColor: TvColors.mint.withValues(alpha: 0.12),
        valueIndicatorColor: TvColors.brandPrimary,
        valueIndicatorTextStyle:
            TvTypography.label.copyWith(color: Colors.white),
        trackHeight: 4,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
