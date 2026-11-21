import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({ required Dio dio}) : _dio = dio;


  Future<Response> post({
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final url = 'https://generativelanguage.googleapis.com/v1beta/interactions';
    final response = await _dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
    return response;
  }
}
