import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

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
    return Scaffold(
      body: StreamBuilder(
        stream: widget.presenter.nextEventStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return CircularProgressIndicator();
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

abstract class NextEventPresenter {
  Stream get nextEventStream;

  void loadNextEvent({required String groupId});
  void emitNextEvent();
}

final class NextEventPresenterSpy extends Mock implements NextEventPresenter {}

void main() {
  late Widget sut;
  late NextEventPresenter presenter;
  late String groupId;
  late BehaviorSubject nextEventSubject;

  setUp(() {
    presenter = NextEventPresenterSpy();
    groupId = anyString();
    nextEventSubject = BehaviorSubject();
    sut = MaterialApp(
      home: NextEventScreen(presenter: presenter, groupId: groupId),
    );

    when(
      () => presenter.nextEventStream,
    ).thenAnswer((_) => nextEventSubject.stream);
  });

  tearDown(() {
    nextEventSubject.close();
  });

  void emitNextEvent() => nextEventSubject.add('');
  void emitError() => nextEventSubject.addError(Error());

  testWidgets('should load event data on screen inits', (tester) async {
    await tester.pumpWidget(sut);

    verify(() => presenter.loadNextEvent(groupId: groupId)).called(1);
  });

  testWidgets('should present a spinner while the data is loading', (
    tester,
  ) async {
    await tester.pumpWidget(sut);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should hide the spinner when the data is loaded successfully', (
    tester,
  ) async {
    await tester.pumpWidget(sut);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    emitNextEvent();
    verify(() => presenter.loadNextEvent(groupId: groupId)).called(1);

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('should hide the spinner when the the loading failed', (
    tester,
  ) async {
    await tester.pumpWidget(sut);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    emitError();
    verify(() => presenter.loadNextEvent(groupId: groupId)).called(1);

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
