import 'dart:convert';

import 'package:advanced_flutter/domain/entities/next_event_player.dart';

final class NextEvent {
  final String groupName;
  final DateTime date;
  final List<NextEventPlayer> players;

  const NextEvent({
    required this.groupName,
    required this.date,
    required this.players,
  });

  factory NextEvent.fromMap(Map<String, dynamic> map) {
    return NextEvent(
      groupName: map['groupName'] ?? '',
      date: DateTime.parse(map['date']),
      players: List<NextEventPlayer>.from(
        map['players']?.map((player) => NextEventPlayer.fromMap(player)),
      ),
    );
  }

  factory NextEvent.fromJson(String source) {
    final map = json.decode(source);
    return NextEvent.fromMap(map);
  }
}
