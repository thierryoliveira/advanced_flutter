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
              if (viewModel.players.isNotEmpty)
                PlayerPositionSection(
                  title: 'CONFIRMED - PLAYERS',
                  players: viewModel.players,
                ),
              if (viewModel.out.isNotEmpty)
                PlayerPositionSection(title: 'OUT', players: viewModel.out),
              if (viewModel.doubt.isNotEmpty)
                PlayerPositionSection(title: 'DOUBT', players: viewModel.doubt),
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
  final List<NextEventPlayerViewModel> players;
  final List<NextEventPlayerViewModel> out;
  final List<NextEventPlayerViewModel> doubt;

  const NextEventViewModel({
    this.goalkeepers = const [],
    this.players = const [],
    this.out = const [],
    this.doubt = const [],
  });
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
  final mockPlayers = [
    const NextEventPlayerViewModel(name: 'Thierry Henry'),
    const NextEventPlayerViewModel(name: 'Lucas Moura'),
    const NextEventPlayerViewModel(name: 'Ronaldinho'),
    const NextEventPlayerViewModel(name: 'Kaká'),
  ];

  registerFallbackValue(const NextEventViewModel());

  mockEmitNextEventWith({
    List<NextEventPlayerViewModel> goalkeepers = const [],
    List<NextEventPlayerViewModel> players = const [],
    List<NextEventPlayerViewModel> out = const [],
    List<NextEventPlayerViewModel> doubt = const [],
  }) {
    when(
      () => presenter.emitNextEvent(viewModel: any(named: 'viewModel')),
    ).thenAnswer(
      (_) => nextEventSubject.add(
        NextEventViewModel(
          goalkeepers: goalkeepers,
          players: players,
          out: out,
          doubt: doubt,
        ),
      ),
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

  testWidgets('should display players section', (tester) async {
    mockEmitNextEventWith(goalkeepers: mockGoalkeepers, players: mockPlayers);

    await tester.pumpWidget(sut);
    presenter.emitNextEvent(
      viewModel: NextEventViewModel(
        goalkeepers: mockGoalkeepers,
        players: mockPlayers,
      ),
    );
    await tester.pump();
    expect(find.text('CONFIRMED - PLAYERS'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Thierry Henry'), findsOneWidget);
    expect(find.text('Lucas Moura'), findsOneWidget);
    expect(find.text('Ronaldinho'), findsOneWidget);
    expect(find.text('Kaká'), findsOneWidget);
  });

  testWidgets('should hide players section when there are no players', (
    tester,
  ) async {
    await tester.pumpWidget(sut);
    presenter.emitNextEvent();
    await tester.pump();

    expect(find.text('CONFIRMED - PLAYERS'), findsNothing);
  });

  testWidgets('should display the OUT section', (tester) async {
    mockEmitNextEventWith(out: mockPlayers);

    await tester.pumpWidget(sut);
    presenter.emitNextEvent(viewModel: NextEventViewModel(out: mockPlayers));
    await tester.pump();
    expect(find.text('OUT'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Thierry Henry'), findsOneWidget);
    expect(find.text('Lucas Moura'), findsOneWidget);
    expect(find.text('Ronaldinho'), findsOneWidget);
    expect(find.text('Kaká'), findsOneWidget);
  });

  testWidgets(
    'should hide OUT section when there are not players OUT of the game',
    (tester) async {
      await tester.pumpWidget(sut);
      presenter.emitNextEvent();
      await tester.pump();

      expect(find.text('OUT'), findsNothing);
    },
  );

  testWidgets('should display the DOUBT section', (tester) async {
    mockEmitNextEventWith(doubt: mockPlayers);

    await tester.pumpWidget(sut);
    presenter.emitNextEvent(viewModel: NextEventViewModel(doubt: mockPlayers));
    await tester.pump();
    expect(find.text('DOUBT'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Thierry Henry'), findsOneWidget);
    expect(find.text('Lucas Moura'), findsOneWidget);
    expect(find.text('Ronaldinho'), findsOneWidget);
    expect(find.text('Kaká'), findsOneWidget);
  });
}
