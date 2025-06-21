import 'package:advanced_flutter/infra/repositories/load_next_event_http_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

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
    final sut = LoadNextEventHttpRepository(client: httpClient, url: '');
    await sut.loadNextEvent(groupId: groupId);

    verify(() => httpClient.get(any())).called(1);
  });

  test('should request with the correct URL', () async {
    final groupId = anyString();
    final url = 'https://domain.com/api/groups/:groupId/next_event';
    final sut = LoadNextEventHttpRepository(client: httpClient, url: url);
    await sut.loadNextEvent(groupId: groupId);

    verify(
      () => httpClient.get(
        Uri.parse('https://domain.com/api/groups/$groupId/next_event'),
      ),
    ).called(1);
  });
}
