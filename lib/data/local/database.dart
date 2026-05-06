import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Games extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cloudId => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get awayTeamName => text()();
  TextColumn get homeTeamName => text()();
  TextColumn get status => text()();
}

class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class GameLineups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId => integer().references(Games, #id)();
  IntColumn get playerId => integer().references(Players, #id)();
  BoolColumn get isHomeTeam => boolean()();
  IntColumn get battingOrder => integer()();
}

class Plays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId => integer().references(Games, #id)();
  IntColumn get inning => integer()();
  BoolColumn get isTop => boolean()();
  TextColumn get result => text()();
  DateTimeColumn get timestamp => dateTime()();
}

@DriftDatabase(tables: [Games, Players, GameLineups, Plays])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'digital_scorebook.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
