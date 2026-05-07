class Player {
  const Player({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;

  /// Logs and runner tiles — `"Given Family"` or a single side when the other is empty.
  String get displayName {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isEmpty) {
      return last.isEmpty ? '' : last;
    }
    if (last.isEmpty) {
      return first;
    }
    return '$first $last';
  }

  /// Temporary jersey number: stable pseudo-random value in [1, 99].
  int get jerseyNumber {
    final key = '${firstName.trim()}|${lastName.trim()}';
    final hash = key.hashCode.abs();
    return (hash % 99) + 1;
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'name': displayName,
      };
}
