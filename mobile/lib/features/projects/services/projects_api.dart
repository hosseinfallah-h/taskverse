import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../models/project.dart';

class ProjectsApi {
  ProjectsApi._();
  static final ProjectsApi instance = ProjectsApi._();

  Dio get _dio => ApiClient.instance.dio;

  Future<List<Project>> list({bool includeArchived = false}) async {
    final r = await _dio.get(
      ApiConfig.projects,
      queryParameters: {if (includeArchived) 'include_archived': true},
    );
    return (r.data as List<dynamic>)
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Project> create({
    required String name,
    String? color,
    String? icon,
    String? description,
  }) async {
    final r = await _dio.post(
      ApiConfig.projects,
      data: {
        'name': name,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
        if (description != null) 'description': description,
      },
    );
    return Project.fromJson(r.data as Map<String, dynamic>);
  }
}
