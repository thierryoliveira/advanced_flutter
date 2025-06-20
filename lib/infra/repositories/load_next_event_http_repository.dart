import 'package:http/http.dart';

class LoadNextEventHttpRepository {
  final Client client;

  LoadNextEventHttpRepository({required this.client});

  Future<Future<Response>> loadNextEvent({required String groupId}) async {
    return client.get(Uri());
  }
}
