import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/models/task.dart';
import '../../tasks/providers/tasks_provider.dart';

/// Preview XP/level/rank derived from completed tasks.
/// Sprint 4 replaces this with real server-side XP.
class Progress {
  const Progress({
    required this.todayDone,
    required this.todayTotal,
    required this.weekDone,
    required this.weekTotal,
    required this.xp,
    required this.level,
    required this.levelProgress,
    required this.sprouts,
    required this.streak,
    required this.rankName,
    required this.rankEmoji,
    required this.rankColor,
  });

  final int todayDone;
  final int todayTotal;
  final int weekDone;
  final int weekTotal;
  final int xp;
  final int level;
  final double levelProgress;
  final int sprouts;
  final int streak;
  final String rankName;
  final String rankEmoji;
  final int rankColor; // ARGB for gradient end

  double get todayRatio =>
      todayTotal == 0 ? 0 : (todayDone / todayTotal).clamp(0.0, 1.0);
  double get weekRatio =>
      weekTotal == 0 ? 0 : (weekDone / weekTotal).clamp(0.0, 1.0);
}

/// XP awarded per completed task (matches Sprint 4 rules).
int xpForTask(Task t) {
  switch (t.priority) {
    case 0:
      return 30;
    case 1:
      return 20;
    case 2:
      return 15;
    case 3:
      return 10;
    default:
      return 15;
  }
}

/// Rank thresholds (locked in DESIGN_SYSTEM.md §19).
/// Returns (name, emoji, ARGB).
(List<String>, String, int) rankFor(int xp) {
  if (xp >= 200000) {
    return (['باغ افسانه‌ای'], '🌺', 0xFFE85D75);
  }
  if (xp >= 75000) {
    return (['بیشه'], '🌲', 0xFF7A5AA8);
  }
  if (xp >= 35000) {
    return (['بارور'], '🍃', 0xFFF2B33D);
  }
  if (xp >= 15000) {
    return (['شکوفه'], '🌸', 0xFFE85D75);
  }
  if (xp >= 6000) {
    return (['درخت'], '🌳', 0xFF0F5132);
  }
  if (xp >= 2000) {
    return (['نهال'], '🌿', 0xFF4DBA7A);
  }
  if (xp >= 500) {
    return (['جوانه'], '🌱', 0xFF00C896);
  }
  return (['دانه'], '🌰', 0xFF98A29E);
}

final progressProvider = Provider<Progress>((ref) {
  final tasks = ref.watch(todayTasksProvider).value ?? const <Task>[];
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  final weekStart = todayStart.subtract(Duration(days: todayStart.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));

  bool inRange(DateTime? d, DateTime start, DateTime end) {
    if (d == null) return false;
    return !d.isBefore(start) && d.isBefore(end);
  }

  // Today's bucket — tasks with due_date == today, or created today if no due date
  final todayTasks = tasks.where((t) {
    if (t.dueDate != null) return inRange(t.dueDate, todayStart, todayEnd);
    return !t.createdAt.isBefore(todayStart) && t.createdAt.isBefore(todayEnd);
  }).toList();

  // Week's bucket
  final weekTasks = tasks.where((t) {
    if (t.dueDate != null) return inRange(t.dueDate, weekStart, weekEnd);
    return !t.createdAt.isBefore(weekStart) && t.createdAt.isBefore(weekEnd);
  }).toList();

  final todayDone = todayTasks.where((t) => t.isDone).length;
  final weekDone = weekTasks.where((t) => t.isDone).length;

  // Total XP from all completed tasks
  int xp = 0;
  for (final t in tasks) {
    if (t.isDone) xp += xpForTask(t);
  }

  final level = (xp ~/ 100) + 1;
  final levelProgress = (xp % 100) / 100.0;

  // Sprouts = tasks completed in last 7 days
  final sevenAgo = now.subtract(const Duration(days: 7));
  final sprouts = tasks
      .where((t) =>
          t.isDone &&
          t.completedAt != null &&
          t.completedAt!.isAfter(sevenAgo))
      .length;

  // Streak (simplified: distinct days with any completion in last 30)
  final doneDays = <String>{};
  for (final t in tasks) {
    if (t.isDone && t.completedAt != null) {
      final d = t.completedAt!;
      doneDays.add('${d.year}-${d.month}-${d.day}');
    }
  }
  int streak = 0;
  for (int i = 0; i < 30; i++) {
    final day = now.subtract(Duration(days: i));
    final key = '${day.year}-${day.month}-${day.day}';
    if (doneDays.contains(key)) {
      streak++;
    } else if (i > 0) {
      break;
    }
  }

  final rank = rankFor(xp);

  return Progress(
    todayDone: todayDone,
    todayTotal: todayTasks.length,
    weekDone: weekDone,
    weekTotal: weekTasks.length,
    xp: xp,
    level: level,
    levelProgress: levelProgress,
    sprouts: sprouts,
    streak: streak,
    rankName: rank.$1.first,
    rankEmoji: rank.$2,
    rankColor: rank.$3,
  );
});