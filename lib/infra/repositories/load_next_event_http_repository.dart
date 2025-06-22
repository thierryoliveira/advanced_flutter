import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';
import 'package:http/http.dart';

enum DomainError {
  unexpected,
  sessionExpired;

  factory DomainError.fromStatusCode(int statusCode) {
    if (statusCode == 401) return DomainError.sessionExpired;
    return DomainError.unexpected;
  }
}

class LoadNextEventHttpRepository implements LoadNextEventRepository {
  final Client client;
  final String url;
  final Map<String, String>? headers;

  LoadNextEventHttpRepository({
    required this.client,
    required this.url,
    this.headers,
  });

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final urlWithParams = url.replaceFirst(':groupId', groupId);
    final result = await client.get(Uri.parse(urlWithParams), headers: headers);

    if (result.statusCode != 200) {
      throw DomainError.fromStatusCode(result.statusCode);
    }

    return NextEvent.fromJson(result.body);
  }
}
