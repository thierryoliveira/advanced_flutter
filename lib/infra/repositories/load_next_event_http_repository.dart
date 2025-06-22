import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';
import 'package:http/http.dart';

enum DomainError { unexpected }

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

    if (result.statusCode == 400 ||
        result.statusCode == 403 ||
        result.statusCode == 404 ||
        result.statusCode == 500) {
      throw DomainError.unexpected;
    }

    return NextEvent.fromJson(result.body);
  }
}
