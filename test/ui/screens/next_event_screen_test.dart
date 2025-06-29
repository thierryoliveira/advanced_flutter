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
      body: StreamBuilder<NextEventViewModel>(
        stream: widget.presenter.nextEventStream,
        builder: (context, snapshot) {
          final viewModel = snapshot.data;
          if (snapshot.connectionState != ConnectionState.active) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError || viewModel == null) {
            return const SizedBox.shrink();
          }
          return ListView(
            children: [
              if (viewModel.goalkeepers.isNotEmpty)
                PlayerPositionSection(
                  title: 'CONFIRMED - GOALKEEPERS',
                  players: viewModel.goalkeepers,
                ),
            ],
          );
        },
      ),
    );
  }
}

class PlayerPositionSection extends StatelessWidget {
  final String title;
  final List<NextEventPlayerViewModel> players;

  const PlayerPositionSection({
    required this.title,
    required this.players,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Text(players.length.toString()),
        ...players.map((player) => Text(player.name)),
      ],
    );
  }
}

abstract class NextEventPresenter {
  Stream<NextEventViewModel> get nextEventStream;

  void loadNextEvent({required String groupId});
  void emitNextEvent({
    NextEventViewModel viewModel = const NextEventViewModel(),
  });
}

final class NextEventPresenterSpy extends Mock implements NextEventPresenter {}

final class NextEventViewModel {
  final List<NextEventPlayerViewModel> goalkeepers;

  const NextEventViewModel({this.goalkeepers = const []});
}

final class NextEventPlayerViewModel {
  final String name;

  const NextEventPlayerViewModel({required this.name});
}

void main() {
  late Widget sut;
  late NextEventPresenter presenter;
  late String groupId;
  late BehaviorSubject<NextEventViewModel> nextEventSubject;
  final mockGoalkeepers = [
    const NextEventPlayerViewModel(name: 'Rogerio Ceni'),
    const NextEventPlayerViewModel(name: 'Buffon'),
    const NextEventPlayerViewModel(name: 'Dida'),
  ];

  registerFallbackValue(const NextEventViewModel());

  mockEmitNextEventWith({
    List<NextEventPlayerViewModel> goalkeepers = const [],
  }) {
    when(
      () => presenter.emitNextEvent(viewModel: any(named: 'viewModel')),
    ).thenAnswer(
      (_) => nextEventSubject.add(NextEventViewModel(goalkeepers: goalkeepers)),
    );
  }

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

    mockEmitNextEventWith();
  });

  tearDown(() {
    nextEventSubject.close();
  });

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

    presenter.emitNextEvent();
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

  testWidgets('should display goalkeepers section', (tester) async {
    mockEmitNextEventWith(goalkeepers: mockGoalkeepers);

    await tester.pumpWidget(sut);
    presenter.emitNextEvent(
      viewModel: NextEventViewModel(goalkeepers: mockGoalkeepers),
    );
    await tester.pump();
    expect(find.text('CONFIRMED - GOALKEEPERS'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Rogerio Ceni'), findsOneWidget);
    expect(find.text('Buffon'), findsOneWidget);
    expect(find.text('Dida'), findsOneWidget);
  });

  testWidgets('should hide goalkeepers section when there are no goalkeepers', (
    tester,
  ) async {
    await tester.pumpWidget(sut);
    presenter.emitNextEvent();
    await tester.pump();

    expect(find.text('CONFIRMED - GOALKEEPERS'), findsNothing);
  });
}
