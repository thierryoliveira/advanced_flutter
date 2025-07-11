import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';

final class LoadNextEventUseCase {
  final LoadNextEventRepository loadNextEventRepository;

  const LoadNextEventUseCase({required this.loadNextEventRepository});

  Future<NextEvent> call({required String groupId}) async {
    return loadNextEventRepository.loadNextEvent(groupId: groupId);
  }
}
