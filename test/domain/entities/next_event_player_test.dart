import 'package:flutter_test/flutter_test.dart';

class NextEventPlayer {
  final String id;
  final String name;
  final String initials;
  final String? photo;
  final String? position;
  final bool isConfirmed;
  final DateTime? confirmationDate;

  NextEventPlayer._({
    required this.id,
    required this.name,
    required this.isConfirmed,
    required this.initials,
    this.photo,
    this.position,
    this.confirmationDate,
  });

  factory NextEventPlayer({
    required String id,
    required String name,
    required bool isConfirmed,
    String? photo,
    String? position,
    DateTime? confirmationDate,
  }) => NextEventPlayer._(
    id: id,
    name: name,
    initials: _getInitials(name),
    isConfirmed: isConfirmed,
    confirmationDate: confirmationDate,
    position: position,
    photo: photo,
  );

  static String _getInitials(String name) {
    final names = name.split(' ');
    final firstNameInitial = names.first[0].toUpperCase();
    final lastNameInitial = names.last[names.length == 1 ? 1 : 0].toUpperCase();
    return '$firstNameInitial$lastNameInitial';
  }
}

void main() {
  String initialsOf(String name) =>
      NextEventPlayer(id: '', name: name, isConfirmed: true).initials;

  test('should return the initial of the first and last names', () {
    expect(initialsOf('Thierry Oliveira'), 'TO');
    expect(initialsOf('Lorem Ipsum'), 'LI');
    expect(initialsOf('Rogerio Mucki Ceni'), 'RC');
  });

  test('should return the first two letters in case there is only a name', () {
    expect(initialsOf('Thierry'), 'TH');
  });

  test('should convert to uppercase', () {
    expect(initialsOf('thierry oliveira'), 'TO');
    expect(initialsOf('thierry'), 'TH');
  });
}
