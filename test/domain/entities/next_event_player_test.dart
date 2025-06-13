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
  NextEventPlayer makeSut(String name) =>
      NextEventPlayer(id: '', name: name, isConfirmed: true);

  test('should return the initial of the first and last names', () {
    expect(makeSut('Thierry Oliveira').getInitials(), 'TO');
    expect(makeSut('Lorem Ipsum').getInitials(), 'LI');
    expect(makeSut('Rogerio Mucki Ceni').getInitials(), 'RC');
  });
}
