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
  test('should load event data from a repository', () async {
    final repository = LoadNextEventMockRepository();
    final sut = LoadNextEventUseCase(loadNextEventRepository: repository);
    final groupId = Random().nextInt(50000).toString();
    await sut(groupId: groupId);
    expect(repository.groupId, groupId);
  });
}
