import 'package:advanced_flutter/infra/repositories/load_next_event_http_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class HttpClientSpy extends Mock implements Client {}

void main() {
  late Client httpClient;
  late String groupId;
  const url = 'https://domain.com/api/groups/:groupId/next_event';

  setUp(() {
    httpClient = HttpClientSpy();
    registerFallbackValue(Uri());
    groupId = anyString();

    when(
      () => httpClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => Response('', 200));
  });

  test('should request with the correct method', () async {
    final sut = LoadNextEventHttpRepository(client: httpClient, url: url);
    await sut.loadNextEvent(groupId: groupId);

    verify(() => httpClient.get(any())).called(1);
  });

  test('should request with the correct URL', () async {
    final sut = LoadNextEventHttpRepository(client: httpClient, url: url);
    await sut.loadNextEvent(groupId: groupId);

    verify(
      () => httpClient.get(
        Uri.parse('https://domain.com/api/groups/$groupId/next_event'),
      ),
    ).called(1);
  });

  test('should request with the correct headers', () async {
    final headers = <String, String>{
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    final sut = LoadNextEventHttpRepository(
      client: httpClient,
      url: url,
      headers: headers,
    );
    await sut.loadNextEvent(groupId: groupId);

    verify(() => httpClient.get(any(), headers: headers)).called(1);
  });
}
