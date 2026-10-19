import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tv_button.dart';
import '../models/project.dart';
import '../providers/projects_provider.dart';
import '../services/projects_api.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  Future<void> _refresh() async {
    TvHaptics.tap();
    ref.invalidate(projectsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _createProject() async {
    TvHaptics.tap();
    final name = await _promptName();
    if (name == null || name.isEmpty) return;
    try {
      await ProjectsApi.instance.create(name: name);
      ref.invalidate(projectsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا در ساخت پروژه'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<String?> _promptName() async {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        // We read insets INSIDE the sheet so keyboard height is current.
        final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
        final safeBottom = MediaQuery.viewPaddingOf(ctx).bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
            ),
            padding: EdgeInsets.fromLTRB(
              TvSpacing.lg,
              TvSpacing.md,
              TvSpacing.lg,
              safeBottom + TvSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: isDark ? TvColors.nightSoft : TvColors.paper,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(TvRadius.xl),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            TvColors.inkMuted.withValues(alpha: 0.45),
                        borderRadius:
                            BorderRadius.circular(TvRadius.full),
                      ),
                    ),
                  ),
                  const SizedBox(height: TvSpacing.lg),
                  Text(
                    'پروژه تازه',
                    textAlign: TextAlign.right,
                    style: TvTypography.headline.copyWith(
                      color: isDark ? Colors.white : TvColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: TvSpacing.xs),
                  Text(
                    'اسم پروژه‌ت رو انتخاب کن',
                    textAlign: TextAlign.right,
                    style: TvTypography.bodySmall.copyWith(
                      color: isDark
                          ? TvColors.inkMuted
                          : TvColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: TvSpacing.lg),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TvTypography.body.copyWith(
                      color: isDark ? Colors.white : TvColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'مثلاً: محتوای کانال',
                      filled: true,
                      fillColor: isDark
                          ? TvColors.nightElevated
                          : TvColors.sand,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(TvRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(TvRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(TvRadius.md),
                        borderSide: BorderSide(
                          color: TvColors.mint
                              .withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: TvSpacing.md,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: TvSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(ctx)
                              .pop<String?>(null),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                TvRadius.md,
                              ),
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
                          onPressed: () {
                            final v = controller.text.trim();
                            Navigator.of(ctx).pop<String?>(
                              v.isEmpty ? null : v,
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: TvColors.brandPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                TvRadius.md,
                              ),
                            ),
                          ),
                          child: Text(
                            'ساخت',
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
      },
    );

    await Future<void>.delayed(Duration.zero);
    controller.dispose();
    return result;
  }
  
  @override
  Widget build(BuildContext context) {
    final asyncProjects = ref.watch(projectsProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: context.brand,
          backgroundColor: context.surface,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              TvSpacing.md,
              TvSpacing.lg,
              TvSpacing.md,
              120,
            ),
            children: [
              _header(),
              const SizedBox(height: TvSpacing.lg),
              asyncProjects.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(TvSpacing.xl),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, __) => _errorState(),
                data: (projects) {
                  if (projects.isEmpty) return _emptyState();
                  return _grid(projects);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'پروژه‌ها',
                style: TvTypography.headline.copyWith(
                  color: context.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'هر پروژه، یک باغچه در باغ بزرگ‌تر توست.',
                style: TvTypography.bodySmall.copyWith(color: context.inkSoft),
              ),
            ],
          ),
        ),
        Material(
          color: context.brand,
          borderRadius: BorderRadius.circular(TvRadius.full),
          child: InkWell(
            borderRadius: BorderRadius.circular(TvRadius.full),
            onTap: _createProject,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _grid(List<Project> projects) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: TvSpacing.sm,
        crossAxisSpacing: TvSpacing.sm,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (_, i) => _ProjectCard(project: projects[i], index: i),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(TvSpacing.xl),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(TvRadius.xl),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: context.brandSoft,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(Icons.layers_outlined, size: 40, color: context.brand),
          ),
          const SizedBox(height: TvSpacing.md),
          Text(
            'هنوز پروژه‌ای نداری',
            style: TvTypography.title.copyWith(
              color: context.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TvSpacing.xs),
          Text(
            'پروژه‌ها به تو کمک می‌کنن تسک‌های مرتبط رو یه‌جا ببینی.',
            textAlign: TextAlign.center,
            style: TvTypography.bodySmall.copyWith(color: context.inkSoft),
          ),
          const SizedBox(height: TvSpacing.lg),
          TvButton(
            label: 'ساخت اولین پروژه',
            icon: Icons.add_rounded,
            onPressed: _createProject,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _errorState() {
    return Container(
      padding: const EdgeInsets.all(TvSpacing.xl),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(TvRadius.xl),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 40, color: context.inkSoft),
          const SizedBox(height: TvSpacing.md),
          Text(
            'ارتباط برقرار نشد',
            style: TvTypography.title.copyWith(
              color: context.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TvSpacing.lg),
          TvButton(
            label: 'تلاش دوباره',
            icon: Icons.refresh_rounded,
            variant: TvButtonVariant.secondary,
            expand: false,
            onPressed: () => ref.invalidate(projectsProvider),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.index});

  final Project project;
  final int index;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final accent = context.accent;
    final brandDeep = context.brandDeep;

    final gradients = [
      [brand, brandDeep],
      [accent, brand],
      [brandDeep, brand],
      [accent, brandDeep],
    ];
    final gradient = gradients[index % gradients.length];

    return Container(
          padding: const EdgeInsets.all(TvSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(TvRadius.xl),
            boxShadow: [
              BoxShadow(
                color: brand.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconFor(project.icon),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const Spacer(),
              Text(
                project.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TvTypography.title.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  height: 1.4,
                ),
              ),
              if (project.description != null &&
                  project.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  project.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TvTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.80),
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 60 * index),
        )
        .slideY(
          begin: 0.06,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  IconData _iconFor(String? name) {
    if (name == null) return Icons.layers_rounded;
    switch (name) {
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      default:
        return Icons.layers_rounded;
    }
  }
}
