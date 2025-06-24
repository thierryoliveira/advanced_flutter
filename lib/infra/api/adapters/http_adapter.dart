import 'dart:convert';

import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/infra/api/clients/http_get_client.dart';
import 'package:advanced_flutter/infra/types/json.dart';
import 'package:dartx/dartx.dart';
import 'package:http/http.dart';

final class HttpAdapter implements HttpGetClient {
  final Client client;

  const HttpAdapter({required this.client});

  @override
  Future<T?> get<T>({
    required String url,
    Map<String, String>? headers,
    Map<String, String?>? params,
    Map<String, String>? queryString,
  }) async {
    final response = await client.get(
      _buildUri(url: url, params: params, queryString: queryString),
      headers: _buildHeaders(customHeaders: headers),
    );

    return _handleReponse<T>(response);
  }

  T? _handleReponse<T>(Response response) {
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

  Map<String, String> _buildHeaders({Map<String, String>? customHeaders}) {
    return {
      'content-type': 'application/json',
      'accept': 'application/json',
      ...?customHeaders,
    };
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
