import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/infra/api/repositories/load_next_event_api_repository.dart';
import 'package:advanced_flutter/infra/types/json.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';

void main() {
  late String groupId;
  late String url;
  late HttpGetClientSpy httpClient;
  late LoadNextEventApiRepository sut;
  const successMap = {
    "groupName": "group name",
    "date": "2025-06-22T19:00",
    "players": [
      {"id": "id 1", "name": "name 1", "isConfirmed": false},
      {
        "id": "id 2",
        "name": "name 2",
        "position": "position 2",
        "photo": "photo 2",
        "confirmationDate": "2025-06-21T11:00",
        "isConfirmed": true,
      },
    ],
  };

  setUp(() {
    groupId = anyString();
    url = anyString();
    httpClient = HttpGetClientSpy();
    sut = LoadNextEventApiRepository(httpClient: httpClient, url: url);
    when(
      () => httpClient.get<Json>(
        url: any(named: 'url'),
        params: any(named: 'params'),
      ),
    ).thenAnswer((_) async => successMap);
  });

  test('should call HttpClient with correct url', () async {
    await sut.loadNextEvent(groupId: groupId);

    verify(
      () => httpClient.get<Json>(url: url, params: any(named: 'params')),
    ).called(1);
  });

  test('should call HttpClient with the correct params on the URL', () async {
    await sut.loadNextEvent(groupId: groupId);

    verify(
      () => httpClient.get<Json>(url: url, params: {'groupId': groupId}),
    ).called(1);
  });

  test('should return a [NextEvent] object when successful', () async {
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
  });

  test('should rethrow on error', () {
    final error = Error();
    when(
      () => httpClient.get<Json>(url: url, params: any(named: 'params')),
    ).thenThrow(error);

    final future = sut.loadNextEvent(groupId: groupId);

    expect(future, throwsA(error));
  });

  test('should throw UnexpectedError on null response', () async {
    when(
      () => httpClient.get<Json>(url: url, params: any(named: 'params')),
    ).thenAnswer((_) async => null);
    final future = sut.loadNextEvent(groupId: groupId);

    expect(future, throwsA(isA<UnexpectedError>()));
  });
}
