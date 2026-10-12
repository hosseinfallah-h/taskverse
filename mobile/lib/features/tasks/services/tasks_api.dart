import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../models/task.dart';

class TasksApi {
  TasksApi._();
  static final TasksApi instance = TasksApi._();

  Dio get _dio => ApiClient.instance.dio;

  Future<List<Task>> list({
    String view = 'all',
    int? projectId,
    int? tagId,
    String? statusFilter,
  }) async {
    final r = await _dio.get(
      ApiConfig.tasks,
      queryParameters: {
        'view': view,
        if (projectId != null) 'project_id': projectId,
        if (tagId != null) 'tag_id': tagId,
        if (statusFilter != null) 'status_filter': statusFilter,
      },
    );
    return (r.data as List<dynamic>)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Task> create({
    required String title,
    String? description,
    int? projectId,
    int? parentId,
    int priority = 2,
    String? energy,
    DateTime? dueDate,
    String? dueTime,
    int? estimatedMin,
    List<int> tagIds = const [],
    String? rrule,
  }) async {
    final r = await _dio.post(
      ApiConfig.tasks,
      data: {
        'title': title,
        if (description != null) 'description': description,
        if (projectId != null) 'project_id': projectId,
        if (parentId != null) 'parent_id': parentId,
        'priority': priority,
        if (energy != null) 'energy': energy,
        if (dueDate != null)
          'due_date': dueDate.toIso8601String().split('T').first,
        if (dueTime != null) 'due_time': dueTime,
        if (estimatedMin != null) 'estimated_min': estimatedMin,
        'tag_ids': tagIds,
        if (rrule != null) 'rrule': rrule,
      },
    );
    return Task.fromJson(r.data as Map<String, dynamic>);
  }

  Future<Task> setStatus(int taskId, String status) async {
    final r = await _dio.post(
      '${ApiConfig.tasks}/$taskId/status',
      data: {'status': status},
    );
    return Task.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> delete(int taskId) async {
    await _dio.delete('${ApiConfig.tasks}/$taskId');
  }
}
