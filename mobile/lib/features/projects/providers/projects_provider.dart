import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/models/task.dart' show TagBrief;
import '../models/project.dart';
import '../services/projects_api.dart';
import '../../tags/services/tags_api.dart';

/// Cached project list for the editor dropdown.
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  return ProjectsApi.instance.list();
});

/// Cached tags list for the editor chips.
final tagsProvider = FutureProvider<List<TagBrief>>((ref) async {
  return TagsApi.instance.list();
});
