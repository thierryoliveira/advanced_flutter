import 'package:flutter_test/flutter_test.dart';

class NextEventPlayer {
  final String id;
  final String name;
  final String? photo;
  final String? position;
  final bool isConfirmed;
  final DateTime? confirmationDate;

  NextEventPlayer({
    required this.id,
    required this.name,
    required this.isConfirmed,
    this.photo,
    this.position,
    this.confirmationDate,
  });

  String getInitials() {
    final names = name.split(' ');
    final firstNameInitial = names.first[0];
    final lastNameInitial = names.last[0];
    return '$firstNameInitial$lastNameInitial';
  }
}

void main() {
  test('should return the initial of the first and last names', () {
    final player = NextEventPlayer(
      id: '',
      name: 'Thierry Oliveira',
      isConfirmed: true,
    );
    expect(player.getInitials(), 'TO');

    final player2 = NextEventPlayer(
      id: '',
      name: 'Lorem Ipsum',
      isConfirmed: true,
    );
    expect(player2.getInitials(), 'LI');

    final player3 = NextEventPlayer(
      id: '',
      name: 'Rogerio Mucke Ceni',
      isConfirmed: true,
    );
    expect(player3.getInitials(), 'RC');
  });
}
