import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../services/tasks_api.dart';

class TaskFilter {
  const TaskFilter({this.view = 'all', this.statusFilter});

  final String view;
  final String? statusFilter;
}

final taskFilterProvider = StateProvider<TaskFilter>(
  (ref) => const TaskFilter(view: 'all'),
);

/// Home screen task list. Shows ALL tasks (done + undone),
/// undone first, then done.
final todayTasksProvider = FutureProvider<List<Task>>((ref) async {
  if (kDebugMode) debugPrint('=== PROVIDER: fetching tasks ===');
  try {
    final all = await TasksApi.instance.list(view: 'all');
    if (kDebugMode) debugPrint('=== PROVIDER: got ${all.length} tasks ===');

    // Sort: undone first, done after
    final sorted = [...all]
      ..sort((a, b) {
        if (a.isDone == b.isDone) return 0;
        return a.isDone ? 1 : -1;
      });
    return sorted;
  } catch (e) {
    if (kDebugMode) debugPrint('=== PROVIDER ERROR: $e ===');
    rethrow;
  }
});

final allTasksProvider = FutureProvider<List<Task>>((ref) async {
  return TasksApi.instance.list(view: 'all');
});

/// Family provider: fetches subtasks of a given parent task.
final subtasksProvider = FutureProvider.family<List<Subtask>, int>((
  ref,
  parentId,
) async {
  return TasksApi.instance.listSubtasks(parentId);
});

/// Currently selected day in the home week strip.
/// Defaults to today. Nulls mean "all days" is not available — always a date.
final selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Tasks filtered to the currently selected day.
final dayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final all = await TasksApi.instance.list(view: 'all');
  final day = ref.watch(selectedDayProvider);
  final start = DateTime(day.year, day.month, day.day);
  final end = start.add(const Duration(days: 1));

  final filtered = all.where((t) {
    if (t.dueDate != null) {
      return !t.dueDate!.isBefore(start) && t.dueDate!.isBefore(end);
    }
    // Tasks without due dates fall into their creation day.
    return !t.createdAt.isBefore(start) && t.createdAt.isBefore(end);
  }).toList();

  // Sort: undone first, then by due_time / priority.
  filtered.sort((a, b) {
    if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
    return a.priority.compareTo(b.priority);
  });
  return filtered;
});
