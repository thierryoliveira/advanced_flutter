import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:http/http.dart';

class LoadNextEventHttpRepository {
  final Client client;
  final String url;
  final Map<String, String>? headers;

  LoadNextEventHttpRepository({
    required this.client,
    required this.url,
    this.headers,
  });

  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final urlWithParams = url.replaceFirst(':groupId', groupId);
    final result = await client.get(Uri.parse(urlWithParams), headers: headers);
    return NextEvent.fromJson(result.body);
  }
}
