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
  const successJson = '''
    {
      "groupName": "group name",
      "date": "2025-06-22T19:00",
      "players": [
        {
          "id": "id 1",
          "name": "name 1",
          "isConfirmed": false
        },
        {
          "id": "id 2",
          "name": "name 2",
          "position": "position 2",
          "photo": "photo 2",
          "confirmationDate": "2025-06-21T11:00",
          "isConfirmed": true
        }
      ]
    }
''';

  setUp(() {
    httpClient = HttpClientSpy();
    registerFallbackValue(Uri());
    groupId = anyString();

    when(
      () => httpClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => Response(successJson, 200));
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

  test(
    'should return a [NextEvent] object when the status code is 200',
    () async {
      final sut = LoadNextEventHttpRepository(client: httpClient, url: url);
      final nextEvent = await sut.loadNextEvent(groupId: groupId);

      expect(nextEvent.groupName, 'group name');
      expect(nextEvent.date, DateTime(2025, 06, 22, 19, 0));

      expect(nextEvent.players.first.id, 'id 1');
      expect(nextEvent.players.first.name, 'name 1');
      expect(nextEvent.players.first.isConfirmed, isFalse);

      expect(nextEvent.players.last.id, 'id 2');
      expect(nextEvent.players.last.name, 'name 2');
      expect(nextEvent.players.last.position, 'position 2');
      expect(nextEvent.players.last.photo, 'photo 2');
      expect(
        nextEvent.players.last.confirmationDate,
        DateTime(2025, 06, 21, 11, 0),
      );
      expect(nextEvent.players.last.isConfirmed, isTrue);
    },
  );
}
