import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/models/task.dart' show TagBrief;
import '../models/project.dart';
import '../services/projects_api.dart';
import '../../tags/services/tags_api.dart';

/// Cached project list for the editor dropdown + detail lookups.
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  return ProjectsApi.instance.list();
});

/// Cached tags list for the editor chips.
final tagsProvider = FutureProvider<List<TagBrief>>((ref) async {
  return TagsApi.instance.list();
});

/// Look up a project by ID from the cached list (or null if not found).
final projectByIdProvider = Provider.family<Project?, int>((ref, id) {
  final async = ref.watch(projectsProvider);
  return async.when(
    data: (list) {
      for (final p in list) {
        if (p.id == id) return p;
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
