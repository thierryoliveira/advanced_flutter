import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class LoadNextEventHttpRepository {
  final Client client;

  LoadNextEventHttpRepository({required this.client});

  Future<Future<Response>> loadNextEvent({required String groupId}) async {
    return client.get(Uri());
  }
}

class HttpClientSpy extends Mock implements Client {}

void main() {
  late Client httpClient;

  setUp(() {
    httpClient = HttpClientSpy();
    registerFallbackValue(Uri());

    when(
      () => httpClient.get(any()),
    ).thenAnswer((_) async => Response('', 200));
  });

  test('should request with the correct method', () async {
    final groupId = anyString();
    final sut = LoadNextEventHttpRepository(client: httpClient);
    await sut.loadNextEvent(groupId: groupId);

    verify(() => httpClient.get(any())).called(1);
  });
}
