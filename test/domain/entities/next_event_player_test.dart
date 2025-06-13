import 'package:flutter_test/flutter_test.dart';

class NextEventPlayer {
  final String id;
  final String name;
  late final String initials;
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
  }) {
    initials = _getInitials();
  }

  String _getInitials() {
    final names = name.split(' ');
    final firstNameInitial = names.first[0];
    final lastNameInitial = names.last[0];
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
}
