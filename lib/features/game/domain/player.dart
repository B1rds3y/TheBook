class Player {
  const Player({required this.name});

  final String name;

  Map<String, dynamic> toJson() => {'name': name};
}
