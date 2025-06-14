import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

class LoadNextEventUseCase {
  final LoadNextEventRepository loadNextEventRepository;

  LoadNextEventUseCase({required this.loadNextEventRepository});

  Future<void> call({required String groupId}) async {
    loadNextEventRepository.loadNextEvent(groupId: groupId);
  }
}

class LoadNextEventRepository {
  String? groupId;

  Future<void> loadNextEvent({required String groupId}) async {
    this.groupId = groupId;
  }
}

void main() {
  test('should load event data from a repository', () async {
    final repository = LoadNextEventRepository();
    final sut = LoadNextEventUseCase(loadNextEventRepository: repository);
    final groupId = Random().nextInt(50000).toString();
    await sut(groupId: groupId);
    expect(repository.groupId, groupId);
  });
}
