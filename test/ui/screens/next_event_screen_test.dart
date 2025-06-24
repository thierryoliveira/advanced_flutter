import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class NextEventScreen extends StatefulWidget {
  final NextEventPresenter presenter;
  final String groupId;

  const NextEventScreen({
    required this.presenter,
    required this.groupId,
    super.key,
  });

  @override
  State<NextEventScreen> createState() => _NextEventScreenState();
}

class _NextEventScreenState extends State<NextEventScreen> {
  @override
  void initState() {
    super.initState();

    widget.presenter.loadNextEvent(groupId: widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

abstract class NextEventPresenter {
  void loadNextEvent({required String groupId});
}

final class NextEventPresenterSpy extends Mock implements NextEventPresenter {}

void main() {
  testWidgets('should load event data on screen inits', (tester) async {
    final presenter = NextEventPresenterSpy();
    final groupId = anyString();
    final sut = MaterialApp(
      home: NextEventScreen(presenter: presenter, groupId: groupId),
    );
    await tester.pumpWidget(sut);

    verify(() => presenter.loadNextEvent(groupId: groupId)).called(1);
  });
}
