import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../models/task.dart';

/// Shows a confirm sheet for toggling a task.
/// Returns true if user confirmed.
///
/// CALLER RESPONSIBILITY: after this returns true, wait one more frame
/// before mutating state — otherwise the sheet teardown can race.
Future<bool> showConfirmToggleSheet(
  BuildContext context, {
  required Task task,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final goingDone = !task.isDone;

  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          TvSpacing.lg,
          TvSpacing.md,
          TvSpacing.lg,
          TvSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: isDark ? TvColors.nightSoft : TvColors.paper,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(TvRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: TvColors.inkMuted.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(TvRadius.full),
                ),
              ),
            ),
            const SizedBox(height: TvSpacing.lg),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: goingDone
                      ? TvColors.mintSoft
                      : TvColors.brandPrimarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  goingDone
                      ? Icons.check_circle_outline_rounded
                      : Icons.undo_rounded,
                  size: 30,
                  color: TvColors.brandPrimary,
                ),
              ),
            ),
            const SizedBox(height: TvSpacing.md),
            Text(
              goingDone
                  ? 'تسک را انجام‌شده کنم؟'
                  : 'برگردانی به حالت فعال؟',
              textAlign: TextAlign.center,
              style: TvTypography.title.copyWith(
                color: isDark ? Colors.white : TvColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: TvSpacing.xs),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TvSpacing.md),
              child: Text(
                task.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TvTypography.bodySmall.copyWith(
                  color:
                      isDark ? TvColors.inkMuted : TvColors.inkSoft,
                ),
              ),
            ),
            const SizedBox(height: TvSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop<bool>(false),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(TvRadius.md),
                        side: BorderSide(
                          color: TvColors.inkMuted
                              .withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                    child: Text(
                      'لغو',
                      style: TvTypography.label.copyWith(
                        color: TvColors.inkMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TvSpacing.sm),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop<bool>(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: goingDone
                          ? TvColors.brandPrimary
                          : TvColors.sky,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(TvRadius.md),
                      ),
                    ),
                    child: Text(
                      goingDone ? 'بله، انجام شد' : 'بله، برگردان',
                      style: TvTypography.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (result == true) {
    TvHaptics.taskComplete();
  }
  return result == true;
}