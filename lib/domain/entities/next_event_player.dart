import 'dart:convert';

final class NextEventPlayer {
  final String id;
  final String name;
  final String initials;
  final String? photo;
  final String? position;
  final bool isConfirmed;
  final DateTime? confirmationDate;

  const NextEventPlayer._({
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
    if (name.trim().isEmpty) return '-';

    final names = name.trim().split(' ');
    final firstChar = names.first[0];
    final lastChar =
        names.last.split('').elementAtOrNull(names.length == 1 ? 1 : 0) ?? '';
    return '$firstChar$lastChar'.toUpperCase();
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'initials': initials});
    if (photo != null) {
      result.addAll({'photo': photo});
    }
    if (position != null) {
      result.addAll({'position': position});
    }
    result.addAll({'isConfirmed': isConfirmed});
    if (confirmationDate != null) {
      result.addAll({
        'confirmationDate': confirmationDate!.millisecondsSinceEpoch,
      });
    }

    return result;
  }

  factory NextEventPlayer.fromJson(String source) {
    final map = json.decode(source);
    return NextEventPlayer.fromMap(map);
  }

  factory NextEventPlayer.fromMap(Map<String, dynamic> map) {
    return NextEventPlayer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      photo: map['photo'],
      position: map['position'],
      isConfirmed: map['isConfirmed'] ?? false,
      confirmationDate: DateTime.tryParse(map['confirmationDate'] ?? ''),
    );
  }
}
