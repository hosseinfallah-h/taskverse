/// Task model - matches backend `/tasks` response.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description,
    this.projectId,
    this.parentId,
    this.status = 'todo',
    this.priority = 2,
    this.energy,
    this.dueDate,
    this.dueTime,
    this.estimatedMin,
    this.actualMin = 0,
    this.rrule,
    this.deferredUntil,
    this.completedAt,
    this.sortOrder = 0,
    this.tags = const [],
    this.subtasksCount = 0,
    this.subtasksDone = 0,
  });

  final int id;
  final String title;
  final String? description;
  final int? projectId;
  final int? parentId;
  final String status;
  final int priority;
  final String? energy;
  final DateTime? dueDate;
  final String? dueTime;
  final int? estimatedMin;
  final int actualMin;
  final String? rrule;
  final DateTime? deferredUntil;
  final DateTime? completedAt;
  final DateTime createdAt;
  final int sortOrder;
  final List<TagBrief> tags;
  final int subtasksCount;
  final int subtasksDone;

  bool get isDone => status == 'done';
  bool get isDoing => status == 'doing';
  bool get isOverdue =>
      !isDone &&
      dueDate != null &&
      dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)));

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as int,
    title: json['title'] as String,
    description: json['description'] as String?,
    projectId: json['project_id'] as int?,
    parentId: json['parent_id'] as int?,
    status: (json['status'] as String?) ?? 'todo',
    priority: (json['priority'] as int?) ?? 2,
    energy: json['energy'] as String?,
    dueDate: json['due_date'] == null
        ? null
        : DateTime.parse(json['due_date'] as String),
    dueTime: json['due_time'] as String?,
    estimatedMin: json['estimated_min'] as int?,
    actualMin: (json['actual_min'] as int?) ?? 0,
    rrule: json['rrule'] as String?,
    deferredUntil: json['deferred_until'] == null
        ? null
        : DateTime.parse(json['deferred_until'] as String),
    completedAt: json['completed_at'] == null
        ? null
        : DateTime.parse(json['completed_at'] as String),
    createdAt: json['created_at'] == null
        ? DateTime.now()
        : DateTime.parse(json['created_at'] as String),
    sortOrder: (json['sort_order'] as int?) ?? 0,
    tags: (json['tags'] as List<dynamic>? ?? [])
        .map((e) => TagBrief.fromJson(e as Map<String, dynamic>))
        .toList(),
    subtasksCount: (json['subtasks_count'] as int?) ?? 0,
    subtasksDone: (json['subtasks_done'] as int?) ?? 0,
  );
}

class TagBrief {
  const TagBrief({required this.id, required this.name, this.color});

  final int id;
  final String name;
  final String? color;

  factory TagBrief.fromJson(Map<String, dynamic> json) => TagBrief(
    id: json['id'] as int,
    name: json['name'] as String,
    color: json['color'] as String?,
  );
}

/// Lightweight model for a subtask as returned in the task detail screen.
class Subtask {
  const Subtask({
    required this.id,
    required this.title,
    this.status = 'todo',
    this.priority = 2,
  });

  final int id;
  final String title;
  final String status;
  final int priority;

  bool get isDone => status == 'done';

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
    id: json['id'] as int,
    title: json['title'] as String,
    status: (json['status'] as String?) ?? 'todo',
    priority: (json['priority'] as int?) ?? 2,
  );
}
