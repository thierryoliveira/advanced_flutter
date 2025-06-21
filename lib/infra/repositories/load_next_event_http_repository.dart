import 'package:http/http.dart';

class LoadNextEventHttpRepository {
  final Client client;
  final String url;

  LoadNextEventHttpRepository({required this.client, required this.url});

  Future<Future<Response>> loadNextEvent({required String groupId}) async {
    final urlWithParams = url.replaceFirst(':groupId', groupId);
    return client.get(Uri.parse(urlWithParams));
  }
}
