import 'dart:convert';

import 'package:advanced_flutter/domain/entities/domain_error.dart';
import 'package:advanced_flutter/infra/api/clients/http_get_client.dart';
import 'package:advanced_flutter/infra/types/json.dart';
import 'package:dartx/dartx.dart';
import 'package:http/http.dart';

class HttpAdapter implements HttpGetClient {
  final Client client;

  HttpAdapter({required this.client});

  @override
  Future<T?> get<T>({
    required String url,
    Map<String, String>? headers,
    Map<String, String?>? params,
    Map<String, String>? queryString,
  }) async {
    final requestHeaders = {
      'content-type': 'application/json',
      'accept': 'application/json',
      ...?headers,
    };
    final uri = _buildUri(url: url, params: params, queryString: queryString);

    final response = await client.get(uri, headers: requestHeaders);

    if (![200, 204].contains(response.statusCode)) {
      throw DomainError.fromStatusCode(response.statusCode);
    }

    if (response.body.isEmpty || response.statusCode == 204) return null;

    final decodedJson = jsonDecode(response.body);
    if (T == JsonList) {
      return decodedJson.whereType<Json>().toList();
    }

    return decodedJson;
  }

  Uri _buildUri({
    required String url,
    Map<String, String?>? params,
    Map<String, String>? queryString,
  }) {
    url =
        params?.keys
            .fold(
              url,
              (result, key) => result.replaceFirst(':$key', params[key] ?? ''),
            )
            .removeSuffix('/') ??
        url;
    url =
        queryString?.keys
            .fold('$url?', (result, key) => '$result$key=${queryString[key]}&')
            .removeSuffix('&') ??
        url;
    return Uri.parse(url);
  }
}
