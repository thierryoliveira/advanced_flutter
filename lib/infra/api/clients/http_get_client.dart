import 'package:advanced_flutter/infra/types/json.dart';

abstract interface class HttpGetClient {
  Future<T?> get<T>({
    required String url,
    Json? headers,
    Json? params,
    Map<String, String>? queryString,
  });
}
