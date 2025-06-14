import 'package:advanced_flutter/domain/entities/next_event_player.dart';

import 'package:flutter_test/flutter_test.dart';

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

  test('should return the single char when there is only a char as name', () {
    expect(initialsOf('T'), 'T');
    expect(initialsOf('t'), 'T');
  });

  test('should return - when the name is empty', () {
    expect(initialsOf(''), '-');
  });

  test('should convert to uppercase', () {
    expect(initialsOf('thierry oliveira'), 'TO');
    expect(initialsOf('thierry'), 'TH');
  });

  test('should ignore extra whitespaces', () {
    expect(initialsOf('Thierry Oliveira '), 'TO');
    expect(initialsOf(' Thierry    Oliveira '), 'TO');
    expect(initialsOf('  thierry  '), 'TH');
    expect(initialsOf('  t  '), 'T');
    expect(initialsOf(' '), '-');
  });
}
