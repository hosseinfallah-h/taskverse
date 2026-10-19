import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/widgets/tv_bottom_nav.dart';
import '../../../shared/widgets/tv_progress_ring.dart' show TvProgressRing;
import '../../projects/models/project.dart';
import '../../projects/providers/projects_provider.dart';
import '../../projects/services/projects_api.dart';
import '../../tags/services/tags_api.dart';
import '../../tasks/models/task.dart' show TagBrief;
import '../../tasks/providers/tasks_provider.dart';
import '../../tasks/widgets/task_editor_sheet.dart';

/// Shell wrapper that hosts the global bottom nav for all main screens.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  int _currentIndex() {
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/me')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: child,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: TvSpacing.md,
          right: TvSpacing.md,
          bottom: MediaQuery.viewPaddingOf(context).bottom > 0
              ? MediaQuery.viewPaddingOf(context).bottom + TvSpacing.xs
              : TvSpacing.md,
        ),
        child: TvBottomNav(
          currentIndex: _currentIndex(),
          onTap: (index) {
            TvHaptics.tap();
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/projects');
                break;
              case 2:
                context.go('/calendar');
                break;
              case 3:
                context.go('/me');
                break;
            }
          },
          onFabTap: () => _openEditor(context, ref),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref) {
    TvHaptics.tap();

    final projects = ref.read(projectsProvider).value ?? const <Project>[];
    final tags = ref.read(tagsProvider).value ?? const <TagBrief>[];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskEditorSheet(
        initialProjects: projects,
        initialTags: tags,
        onCreateProject: (name) async {
          try {
            return await ProjectsApi.instance.create(name: name);
          } catch (_) {
            return null;
          }
        },
        onCreateTag: (name) async {
          try {
            return await TagsApi.instance.create(name: name);
          } catch (_) {
            return null;
          }
        },
        onSaved: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.invalidate(projectsProvider);
            ref.invalidate(tagsProvider);
            ref.invalidate(dayTasksProvider);
            ref.invalidate(todayTasksProvider);
            ref.invalidate(allTasksProvider);
          });
        },
      ),
    );
  }
}
