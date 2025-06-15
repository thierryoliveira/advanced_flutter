import 'dart:math';

import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:advanced_flutter/domain/entities/next_event_player.dart';

import '../repositories/load_next_event_repository.dart';

class LoadNextEventUseCase {
  final LoadNextEventRepository loadNextEventRepository;

  LoadNextEventUseCase({required this.loadNextEventRepository});

  Future<NextEvent> call({required String groupId}) async {
    return loadNextEventRepository.loadNextEvent(groupId: groupId);
  }
}

class LoadNextEventSpyRepository implements LoadNextEventRepository {
  String? groupId;
  NextEvent? output;
  Error? error;

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
    if (error != null) throw error!;
    return output!;
  }
}

void main() {
  late LoadNextEventSpyRepository repository;
  late LoadNextEventUseCase sut;
  late String groupId;

  setUp(() {
    groupId = Random().nextInt(50000).toString();
    repository = LoadNextEventSpyRepository();

    repository.output = NextEvent(
      groupName: 'any group name',
      date: DateTime.now(),
      players: [
        NextEventPlayer(
          id: 'any id 1',
          name: 'any name 1',
          photo: 'any photo 1',
          isConfirmed: true,
          confirmationDate: DateTime.now(),
        ),
        NextEventPlayer(
          id: 'any id 2',
          name: 'any name 2',
          position: 'any position 2',
          isConfirmed: false,
          confirmationDate: DateTime.now(),
        ),
      ],
    );
    sut = LoadNextEventUseCase(loadNextEventRepository: repository);
  });

  test('should load event data from a repository', () async {
    await sut(groupId: groupId);
    expect(repository.groupId, groupId);
  });

  test('should return event data on success', () async {
    final event = await sut(groupId: groupId);
    expect(event.groupName, repository.output?.groupName);
    expect(event.date, repository.output?.date);
    expect(event.players.length, repository.output?.players.length);

    expect(event.players[0].id, repository.output?.players[0].id);
    expect(event.players[0].name, repository.output?.players[0].name);
    expect(event.players[0].initials, isNotEmpty);
    expect(event.players[0].photo, repository.output?.players[0].photo);
    expect(
      event.players[0].isConfirmed,
      repository.output?.players[0].isConfirmed,
    );
    expect(
      event.players[0].confirmationDate,
      repository.output?.players[0].confirmationDate,
    );
    expect(event.players[1].id, repository.output?.players[1].id);
    expect(event.players[1].name, repository.output?.players[1].name);
    expect(event.players[1].initials, isNotEmpty);
    expect(event.players[1].position, repository.output?.players[1].position);
    expect(
      event.players[1].isConfirmed,
      repository.output?.players[1].isConfirmed,
    );
    expect(
      event.players[1].confirmationDate,
      repository.output?.players[1].confirmationDate,
    );
  });

  test('should rethrow on error', () async {
    final error = Error();
    repository.error = error;
    final future = sut(groupId: groupId);
    expect(future, throwsA(error));
  });
}
