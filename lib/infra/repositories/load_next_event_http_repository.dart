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

  Future<Future<Response>> loadNextEvent({required String groupId}) async {
    final urlWithParams = url.replaceFirst(':groupId', groupId);
    return client.get(Uri.parse(urlWithParams), headers: headers);
  }
}
