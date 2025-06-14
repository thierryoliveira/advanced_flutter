import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

class LoadNextEventUseCase {
  final LoadNextEventRepository loadNextEventRepository;

  LoadNextEventUseCase({required this.loadNextEventRepository});

  Future<void> call({required String groupId}) async {
    loadNextEventRepository.loadNextEvent(groupId: groupId);
  }
}

abstract class LoadNextEventRepository {
  Future<void> loadNextEvent({required String groupId});
}

class LoadNextEventMockRepository implements LoadNextEventRepository {
  String? groupId;

  @override
  Future<void> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
  }
}

void main() {
  late LoadNextEventMockRepository repository;
  late LoadNextEventUseCase sut;
  late String groupId;

  setUp(() {
    repository = LoadNextEventMockRepository();
    sut = LoadNextEventUseCase(loadNextEventRepository: repository);
    groupId = Random().nextInt(50000).toString();
  });

  test('should load event data from a repository', () async {
    await sut(groupId: groupId);
    expect(repository.groupId, groupId);
  });
}
