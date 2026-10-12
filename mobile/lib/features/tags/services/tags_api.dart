import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../tasks/models/task.dart' show TagBrief;

class TagsApi {
  TagsApi._();
  static final TagsApi instance = TagsApi._();

  Dio get _dio => ApiClient.instance.dio;

  Future<List<TagBrief>> list() async {
    final r = await _dio.get(ApiConfig.tags);
    return (r.data as List<dynamic>)
        .map((e) => TagBrief.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TagBrief> create({required String name, String? color}) async {
    final r = await _dio.post(
      ApiConfig.tags,
      data: {'name': name, if (color != null) 'color': color},
    );
    return TagBrief.fromJson(r.data as Map<String, dynamic>);
  }
}
