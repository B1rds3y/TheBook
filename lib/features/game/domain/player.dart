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

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'name': displayName,
      };
}
