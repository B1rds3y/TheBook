// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _awayTeamNameMeta = const VerificationMeta(
    'awayTeamName',
  );
  @override
  late final GeneratedColumn<String> awayTeamName = GeneratedColumn<String>(
    'away_team_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homeTeamNameMeta = const VerificationMeta(
    'homeTeamName',
  );
  @override
  late final GeneratedColumn<String> homeTeamName = GeneratedColumn<String>(
    'home_team_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cloudId,
    date,
    awayTeamName,
    homeTeamName,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('away_team_name')) {
      context.handle(
        _awayTeamNameMeta,
        awayTeamName.isAcceptableOrUnknown(
          data['away_team_name']!,
          _awayTeamNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_awayTeamNameMeta);
    }
    if (data.containsKey('home_team_name')) {
      context.handle(
        _homeTeamNameMeta,
        homeTeamName.isAcceptableOrUnknown(
          data['home_team_name']!,
          _homeTeamNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_homeTeamNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      awayTeamName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}away_team_name'],
      )!,
      homeTeamName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_team_name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class Game extends DataClass implements Insertable<Game> {
  final int id;
  final String? cloudId;
  final DateTime date;
  final String awayTeamName;
  final String homeTeamName;
  final String status;
  const Game({
    required this.id,
    this.cloudId,
    required this.date,
    required this.awayTeamName,
    required this.homeTeamName,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    map['date'] = Variable<DateTime>(date);
    map['away_team_name'] = Variable<String>(awayTeamName);
    map['home_team_name'] = Variable<String>(homeTeamName);
    map['status'] = Variable<String>(status);
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      date: Value(date),
      awayTeamName: Value(awayTeamName),
      homeTeamName: Value(homeTeamName),
      status: Value(status),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<int>(json['id']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      date: serializer.fromJson<DateTime>(json['date']),
      awayTeamName: serializer.fromJson<String>(json['awayTeamName']),
      homeTeamName: serializer.fromJson<String>(json['homeTeamName']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cloudId': serializer.toJson<String?>(cloudId),
      'date': serializer.toJson<DateTime>(date),
      'awayTeamName': serializer.toJson<String>(awayTeamName),
      'homeTeamName': serializer.toJson<String>(homeTeamName),
      'status': serializer.toJson<String>(status),
    };
  }

  Game copyWith({
    int? id,
    Value<String?> cloudId = const Value.absent(),
    DateTime? date,
    String? awayTeamName,
    String? homeTeamName,
    String? status,
  }) => Game(
    id: id ?? this.id,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    date: date ?? this.date,
    awayTeamName: awayTeamName ?? this.awayTeamName,
    homeTeamName: homeTeamName ?? this.homeTeamName,
    status: status ?? this.status,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      date: data.date.present ? data.date.value : this.date,
      awayTeamName: data.awayTeamName.present
          ? data.awayTeamName.value
          : this.awayTeamName,
      homeTeamName: data.homeTeamName.present
          ? data.homeTeamName.value
          : this.homeTeamName,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('date: $date, ')
          ..write('awayTeamName: $awayTeamName, ')
          ..write('homeTeamName: $homeTeamName, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cloudId, date, awayTeamName, homeTeamName, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.cloudId == this.cloudId &&
          other.date == this.date &&
          other.awayTeamName == this.awayTeamName &&
          other.homeTeamName == this.homeTeamName &&
          other.status == this.status);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<int> id;
  final Value<String?> cloudId;
  final Value<DateTime> date;
  final Value<String> awayTeamName;
  final Value<String> homeTeamName;
  final Value<String> status;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.date = const Value.absent(),
    this.awayTeamName = const Value.absent(),
    this.homeTeamName = const Value.absent(),
    this.status = const Value.absent(),
  });
  GamesCompanion.insert({
    this.id = const Value.absent(),
    this.cloudId = const Value.absent(),
    required DateTime date,
    required String awayTeamName,
    required String homeTeamName,
    required String status,
  }) : date = Value(date),
       awayTeamName = Value(awayTeamName),
       homeTeamName = Value(homeTeamName),
       status = Value(status);
  static Insertable<Game> custom({
    Expression<int>? id,
    Expression<String>? cloudId,
    Expression<DateTime>? date,
    Expression<String>? awayTeamName,
    Expression<String>? homeTeamName,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cloudId != null) 'cloud_id': cloudId,
      if (date != null) 'date': date,
      if (awayTeamName != null) 'away_team_name': awayTeamName,
      if (homeTeamName != null) 'home_team_name': homeTeamName,
      if (status != null) 'status': status,
    });
  }

  GamesCompanion copyWith({
    Value<int>? id,
    Value<String?>? cloudId,
    Value<DateTime>? date,
    Value<String>? awayTeamName,
    Value<String>? homeTeamName,
    Value<String>? status,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      cloudId: cloudId ?? this.cloudId,
      date: date ?? this.date,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (awayTeamName.present) {
      map['away_team_name'] = Variable<String>(awayTeamName.value);
    }
    if (homeTeamName.present) {
      map['home_team_name'] = Variable<String>(homeTeamName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('cloudId: $cloudId, ')
          ..write('date: $date, ')
          ..write('awayTeamName: $awayTeamName, ')
          ..write('homeTeamName: $homeTeamName, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final int id;
  final String name;
  const Player({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(id: Value(id), name: Value(name));
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Player copyWith({int? id, String? name}) =>
      Player(id: id ?? this.id, name: name ?? this.name);
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player && other.id == this.id && other.name == this.name);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<int> id;
  final Value<String> name;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  PlayersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Player> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  PlayersCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return PlayersCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $GameLineupsTable extends GameLineups
    with TableInfo<$GameLineupsTable, GameLineup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameLineupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _isHomeTeamMeta = const VerificationMeta(
    'isHomeTeam',
  );
  @override
  late final GeneratedColumn<bool> isHomeTeam = GeneratedColumn<bool>(
    'is_home_team',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_home_team" IN (0, 1))',
    ),
  );
  static const VerificationMeta _battingOrderMeta = const VerificationMeta(
    'battingOrder',
  );
  @override
  late final GeneratedColumn<int> battingOrder = GeneratedColumn<int>(
    'batting_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    playerId,
    isHomeTeam,
    battingOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_lineups';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameLineup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('is_home_team')) {
      context.handle(
        _isHomeTeamMeta,
        isHomeTeam.isAcceptableOrUnknown(
          data['is_home_team']!,
          _isHomeTeamMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isHomeTeamMeta);
    }
    if (data.containsKey('batting_order')) {
      context.handle(
        _battingOrderMeta,
        battingOrder.isAcceptableOrUnknown(
          data['batting_order']!,
          _battingOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_battingOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameLineup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameLineup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      isHomeTeam: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_home_team'],
      )!,
      battingOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batting_order'],
      )!,
    );
  }

  @override
  $GameLineupsTable createAlias(String alias) {
    return $GameLineupsTable(attachedDatabase, alias);
  }
}

class GameLineup extends DataClass implements Insertable<GameLineup> {
  final int id;
  final int gameId;
  final int playerId;
  final bool isHomeTeam;
  final int battingOrder;
  const GameLineup({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.isHomeTeam,
    required this.battingOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['player_id'] = Variable<int>(playerId);
    map['is_home_team'] = Variable<bool>(isHomeTeam);
    map['batting_order'] = Variable<int>(battingOrder);
    return map;
  }

  GameLineupsCompanion toCompanion(bool nullToAbsent) {
    return GameLineupsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      playerId: Value(playerId),
      isHomeTeam: Value(isHomeTeam),
      battingOrder: Value(battingOrder),
    );
  }

  factory GameLineup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameLineup(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      playerId: serializer.fromJson<int>(json['playerId']),
      isHomeTeam: serializer.fromJson<bool>(json['isHomeTeam']),
      battingOrder: serializer.fromJson<int>(json['battingOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'playerId': serializer.toJson<int>(playerId),
      'isHomeTeam': serializer.toJson<bool>(isHomeTeam),
      'battingOrder': serializer.toJson<int>(battingOrder),
    };
  }

  GameLineup copyWith({
    int? id,
    int? gameId,
    int? playerId,
    bool? isHomeTeam,
    int? battingOrder,
  }) => GameLineup(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    playerId: playerId ?? this.playerId,
    isHomeTeam: isHomeTeam ?? this.isHomeTeam,
    battingOrder: battingOrder ?? this.battingOrder,
  );
  GameLineup copyWithCompanion(GameLineupsCompanion data) {
    return GameLineup(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      isHomeTeam: data.isHomeTeam.present
          ? data.isHomeTeam.value
          : this.isHomeTeam,
      battingOrder: data.battingOrder.present
          ? data.battingOrder.value
          : this.battingOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameLineup(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('isHomeTeam: $isHomeTeam, ')
          ..write('battingOrder: $battingOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gameId, playerId, isHomeTeam, battingOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameLineup &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.playerId == this.playerId &&
          other.isHomeTeam == this.isHomeTeam &&
          other.battingOrder == this.battingOrder);
}

class GameLineupsCompanion extends UpdateCompanion<GameLineup> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<int> playerId;
  final Value<bool> isHomeTeam;
  final Value<int> battingOrder;
  const GameLineupsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.isHomeTeam = const Value.absent(),
    this.battingOrder = const Value.absent(),
  });
  GameLineupsCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required int playerId,
    required bool isHomeTeam,
    required int battingOrder,
  }) : gameId = Value(gameId),
       playerId = Value(playerId),
       isHomeTeam = Value(isHomeTeam),
       battingOrder = Value(battingOrder);
  static Insertable<GameLineup> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<int>? playerId,
    Expression<bool>? isHomeTeam,
    Expression<int>? battingOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (playerId != null) 'player_id': playerId,
      if (isHomeTeam != null) 'is_home_team': isHomeTeam,
      if (battingOrder != null) 'batting_order': battingOrder,
    });
  }

  GameLineupsCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<int>? playerId,
    Value<bool>? isHomeTeam,
    Value<int>? battingOrder,
  }) {
    return GameLineupsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      isHomeTeam: isHomeTeam ?? this.isHomeTeam,
      battingOrder: battingOrder ?? this.battingOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (isHomeTeam.present) {
      map['is_home_team'] = Variable<bool>(isHomeTeam.value);
    }
    if (battingOrder.present) {
      map['batting_order'] = Variable<int>(battingOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameLineupsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('isHomeTeam: $isHomeTeam, ')
          ..write('battingOrder: $battingOrder')
          ..write(')'))
        .toString();
  }
}

class $PlaysTable extends Plays with TableInfo<$PlaysTable, Play> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<int> gameId = GeneratedColumn<int>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _inningMeta = const VerificationMeta('inning');
  @override
  late final GeneratedColumn<int> inning = GeneratedColumn<int>(
    'inning',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTopMeta = const VerificationMeta('isTop');
  @override
  late final GeneratedColumn<bool> isTop = GeneratedColumn<bool>(
    'is_top',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_top" IN (0, 1))',
    ),
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    inning,
    isTop,
    result,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plays';
  @override
  VerificationContext validateIntegrity(
    Insertable<Play> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('inning')) {
      context.handle(
        _inningMeta,
        inning.isAcceptableOrUnknown(data['inning']!, _inningMeta),
      );
    } else if (isInserting) {
      context.missing(_inningMeta);
    }
    if (data.containsKey('is_top')) {
      context.handle(
        _isTopMeta,
        isTop.isAcceptableOrUnknown(data['is_top']!, _isTopMeta),
      );
    } else if (isInserting) {
      context.missing(_isTopMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Play map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Play(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_id'],
      )!,
      inning: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inning'],
      )!,
      isTop: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_top'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $PlaysTable createAlias(String alias) {
    return $PlaysTable(attachedDatabase, alias);
  }
}

class Play extends DataClass implements Insertable<Play> {
  final int id;
  final int gameId;
  final int inning;
  final bool isTop;
  final String result;
  final DateTime timestamp;
  const Play({
    required this.id,
    required this.gameId,
    required this.inning,
    required this.isTop,
    required this.result,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<int>(gameId);
    map['inning'] = Variable<int>(inning);
    map['is_top'] = Variable<bool>(isTop);
    map['result'] = Variable<String>(result);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  PlaysCompanion toCompanion(bool nullToAbsent) {
    return PlaysCompanion(
      id: Value(id),
      gameId: Value(gameId),
      inning: Value(inning),
      isTop: Value(isTop),
      result: Value(result),
      timestamp: Value(timestamp),
    );
  }

  factory Play.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Play(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<int>(json['gameId']),
      inning: serializer.fromJson<int>(json['inning']),
      isTop: serializer.fromJson<bool>(json['isTop']),
      result: serializer.fromJson<String>(json['result']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<int>(gameId),
      'inning': serializer.toJson<int>(inning),
      'isTop': serializer.toJson<bool>(isTop),
      'result': serializer.toJson<String>(result),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  Play copyWith({
    int? id,
    int? gameId,
    int? inning,
    bool? isTop,
    String? result,
    DateTime? timestamp,
  }) => Play(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    inning: inning ?? this.inning,
    isTop: isTop ?? this.isTop,
    result: result ?? this.result,
    timestamp: timestamp ?? this.timestamp,
  );
  Play copyWithCompanion(PlaysCompanion data) {
    return Play(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      inning: data.inning.present ? data.inning.value : this.inning,
      isTop: data.isTop.present ? data.isTop.value : this.isTop,
      result: data.result.present ? data.result.value : this.result,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Play(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('inning: $inning, ')
          ..write('isTop: $isTop, ')
          ..write('result: $result, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameId, inning, isTop, result, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Play &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.inning == this.inning &&
          other.isTop == this.isTop &&
          other.result == this.result &&
          other.timestamp == this.timestamp);
}

class PlaysCompanion extends UpdateCompanion<Play> {
  final Value<int> id;
  final Value<int> gameId;
  final Value<int> inning;
  final Value<bool> isTop;
  final Value<String> result;
  final Value<DateTime> timestamp;
  const PlaysCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.inning = const Value.absent(),
    this.isTop = const Value.absent(),
    this.result = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  PlaysCompanion.insert({
    this.id = const Value.absent(),
    required int gameId,
    required int inning,
    required bool isTop,
    required String result,
    required DateTime timestamp,
  }) : gameId = Value(gameId),
       inning = Value(inning),
       isTop = Value(isTop),
       result = Value(result),
       timestamp = Value(timestamp);
  static Insertable<Play> custom({
    Expression<int>? id,
    Expression<int>? gameId,
    Expression<int>? inning,
    Expression<bool>? isTop,
    Expression<String>? result,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (inning != null) 'inning': inning,
      if (isTop != null) 'is_top': isTop,
      if (result != null) 'result': result,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  PlaysCompanion copyWith({
    Value<int>? id,
    Value<int>? gameId,
    Value<int>? inning,
    Value<bool>? isTop,
    Value<String>? result,
    Value<DateTime>? timestamp,
  }) {
    return PlaysCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      inning: inning ?? this.inning,
      isTop: isTop ?? this.isTop,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<int>(gameId.value);
    }
    if (inning.present) {
      map['inning'] = Variable<int>(inning.value);
    }
    if (isTop.present) {
      map['is_top'] = Variable<bool>(isTop.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaysCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('inning: $inning, ')
          ..write('isTop: $isTop, ')
          ..write('result: $result, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GamesTable games = $GamesTable(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $GameLineupsTable gameLineups = $GameLineupsTable(this);
  late final $PlaysTable plays = $PlaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    games,
    players,
    gameLineups,
    plays,
  ];
}

typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      Value<String?> cloudId,
      required DateTime date,
      required String awayTeamName,
      required String homeTeamName,
      required String status,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<int> id,
      Value<String?> cloudId,
      Value<DateTime> date,
      Value<String> awayTeamName,
      Value<String> homeTeamName,
      Value<String> status,
    });

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GameLineupsTable, List<GameLineup>>
  _gameLineupsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameLineups,
    aliasName: $_aliasNameGenerator(db.games.id, db.gameLineups.gameId),
  );

  $$GameLineupsTableProcessedTableManager get gameLineupsRefs {
    final manager = $$GameLineupsTableTableManager(
      $_db,
      $_db.gameLineups,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameLineupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlaysTable, List<Play>> _playsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.plays,
    aliasName: $_aliasNameGenerator(db.games.id, db.plays.gameId),
  );

  $$PlaysTableProcessedTableManager get playsRefs {
    final manager = $$PlaysTableTableManager(
      $_db,
      $_db.plays,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get awayTeamName => $composableBuilder(
    column: $table.awayTeamName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeTeamName => $composableBuilder(
    column: $table.homeTeamName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gameLineupsRefs(
    Expression<bool> Function($$GameLineupsTableFilterComposer f) f,
  ) {
    final $$GameLineupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameLineups,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameLineupsTableFilterComposer(
            $db: $db,
            $table: $db.gameLineups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playsRefs(
    Expression<bool> Function($$PlaysTableFilterComposer f) f,
  ) {
    final $$PlaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plays,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaysTableFilterComposer(
            $db: $db,
            $table: $db.plays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get awayTeamName => $composableBuilder(
    column: $table.awayTeamName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeTeamName => $composableBuilder(
    column: $table.homeTeamName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get awayTeamName => $composableBuilder(
    column: $table.awayTeamName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homeTeamName => $composableBuilder(
    column: $table.homeTeamName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> gameLineupsRefs<T extends Object>(
    Expression<T> Function($$GameLineupsTableAnnotationComposer a) f,
  ) {
    final $$GameLineupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameLineups,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameLineupsTableAnnotationComposer(
            $db: $db,
            $table: $db.gameLineups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playsRefs<T extends Object>(
    Expression<T> Function($$PlaysTableAnnotationComposer a) f,
  ) {
    final $$PlaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plays,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaysTableAnnotationComposer(
            $db: $db,
            $table: $db.plays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, $$GamesTableReferences),
          Game,
          PrefetchHooks Function({bool gameLineupsRefs, bool playsRefs})
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> awayTeamName = const Value.absent(),
                Value<String> homeTeamName = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                cloudId: cloudId,
                date: date,
                awayTeamName: awayTeamName,
                homeTeamName: homeTeamName,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                required DateTime date,
                required String awayTeamName,
                required String homeTeamName,
                required String status,
              }) => GamesCompanion.insert(
                id: id,
                cloudId: cloudId,
                date: date,
                awayTeamName: awayTeamName,
                homeTeamName: homeTeamName,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GamesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({gameLineupsRefs = false, playsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gameLineupsRefs) db.gameLineups,
                    if (playsRefs) db.plays,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gameLineupsRefs)
                        await $_getPrefetchedData<
                          Game,
                          $GamesTable,
                          GameLineup
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._gameLineupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).gameLineupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playsRefs)
                        await $_getPrefetchedData<Game, $GamesTable, Play>(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._playsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(db, table, p0).playsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, $$GamesTableReferences),
      Game,
      PrefetchHooks Function({bool gameLineupsRefs, bool playsRefs})
    >;
typedef $$PlayersTableCreateCompanionBuilder =
    PlayersCompanion Function({Value<int> id, required String name});
typedef $$PlayersTableUpdateCompanionBuilder =
    PlayersCompanion Function({Value<int> id, Value<String> name});

final class $$PlayersTableReferences
    extends BaseReferences<_$AppDatabase, $PlayersTable, Player> {
  $$PlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GameLineupsTable, List<GameLineup>>
  _gameLineupsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gameLineups,
    aliasName: $_aliasNameGenerator(db.players.id, db.gameLineups.playerId),
  );

  $$GameLineupsTableProcessedTableManager get gameLineupsRefs {
    final manager = $$GameLineupsTableTableManager(
      $_db,
      $_db.gameLineups,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameLineupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gameLineupsRefs(
    Expression<bool> Function($$GameLineupsTableFilterComposer f) f,
  ) {
    final $$GameLineupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameLineups,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameLineupsTableFilterComposer(
            $db: $db,
            $table: $db.gameLineups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> gameLineupsRefs<T extends Object>(
    Expression<T> Function($$GameLineupsTableAnnotationComposer a) f,
  ) {
    final $$GameLineupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gameLineups,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameLineupsTableAnnotationComposer(
            $db: $db,
            $table: $db.gameLineups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, $$PlayersTableReferences),
          Player,
          PrefetchHooks Function({bool gameLineupsRefs})
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => PlayersCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  PlayersCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameLineupsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gameLineupsRefs) db.gameLineups],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gameLineupsRefs)
                    await $_getPrefetchedData<
                      Player,
                      $PlayersTable,
                      GameLineup
                    >(
                      currentTable: table,
                      referencedTable: $$PlayersTableReferences
                          ._gameLineupsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PlayersTableReferences(
                        db,
                        table,
                        p0,
                      ).gameLineupsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, $$PlayersTableReferences),
      Player,
      PrefetchHooks Function({bool gameLineupsRefs})
    >;
typedef $$GameLineupsTableCreateCompanionBuilder =
    GameLineupsCompanion Function({
      Value<int> id,
      required int gameId,
      required int playerId,
      required bool isHomeTeam,
      required int battingOrder,
    });
typedef $$GameLineupsTableUpdateCompanionBuilder =
    GameLineupsCompanion Function({
      Value<int> id,
      Value<int> gameId,
      Value<int> playerId,
      Value<bool> isHomeTeam,
      Value<int> battingOrder,
    });

final class $$GameLineupsTableReferences
    extends BaseReferences<_$AppDatabase, $GameLineupsTable, GameLineup> {
  $$GameLineupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) => db.games.createAlias(
    $_aliasNameGenerator(db.gameLineups.gameId, db.games.id),
  );

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias(
        $_aliasNameGenerator(db.gameLineups.playerId, db.players.id),
      );

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameLineupsTableFilterComposer
    extends Composer<_$AppDatabase, $GameLineupsTable> {
  $$GameLineupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHomeTeam => $composableBuilder(
    column: $table.isHomeTeam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get battingOrder => $composableBuilder(
    column: $table.battingOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameLineupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameLineupsTable> {
  $$GameLineupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHomeTeam => $composableBuilder(
    column: $table.isHomeTeam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get battingOrder => $composableBuilder(
    column: $table.battingOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameLineupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameLineupsTable> {
  $$GameLineupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get isHomeTeam => $composableBuilder(
    column: $table.isHomeTeam,
    builder: (column) => column,
  );

  GeneratedColumn<int> get battingOrder => $composableBuilder(
    column: $table.battingOrder,
    builder: (column) => column,
  );

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameLineupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameLineupsTable,
          GameLineup,
          $$GameLineupsTableFilterComposer,
          $$GameLineupsTableOrderingComposer,
          $$GameLineupsTableAnnotationComposer,
          $$GameLineupsTableCreateCompanionBuilder,
          $$GameLineupsTableUpdateCompanionBuilder,
          (GameLineup, $$GameLineupsTableReferences),
          GameLineup,
          PrefetchHooks Function({bool gameId, bool playerId})
        > {
  $$GameLineupsTableTableManager(_$AppDatabase db, $GameLineupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameLineupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameLineupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameLineupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<bool> isHomeTeam = const Value.absent(),
                Value<int> battingOrder = const Value.absent(),
              }) => GameLineupsCompanion(
                id: id,
                gameId: gameId,
                playerId: playerId,
                isHomeTeam: isHomeTeam,
                battingOrder: battingOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required int playerId,
                required bool isHomeTeam,
                required int battingOrder,
              }) => GameLineupsCompanion.insert(
                id: id,
                gameId: gameId,
                playerId: playerId,
                isHomeTeam: isHomeTeam,
                battingOrder: battingOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GameLineupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$GameLineupsTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$GameLineupsTableReferences
                                    ._gameIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (playerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playerId,
                                referencedTable: $$GameLineupsTableReferences
                                    ._playerIdTable(db),
                                referencedColumn: $$GameLineupsTableReferences
                                    ._playerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GameLineupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameLineupsTable,
      GameLineup,
      $$GameLineupsTableFilterComposer,
      $$GameLineupsTableOrderingComposer,
      $$GameLineupsTableAnnotationComposer,
      $$GameLineupsTableCreateCompanionBuilder,
      $$GameLineupsTableUpdateCompanionBuilder,
      (GameLineup, $$GameLineupsTableReferences),
      GameLineup,
      PrefetchHooks Function({bool gameId, bool playerId})
    >;
typedef $$PlaysTableCreateCompanionBuilder =
    PlaysCompanion Function({
      Value<int> id,
      required int gameId,
      required int inning,
      required bool isTop,
      required String result,
      required DateTime timestamp,
    });
typedef $$PlaysTableUpdateCompanionBuilder =
    PlaysCompanion Function({
      Value<int> id,
      Value<int> gameId,
      Value<int> inning,
      Value<bool> isTop,
      Value<String> result,
      Value<DateTime> timestamp,
    });

final class $$PlaysTableReferences
    extends BaseReferences<_$AppDatabase, $PlaysTable, Play> {
  $$PlaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias($_aliasNameGenerator(db.plays.gameId, db.games.id));

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<int>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaysTableFilterComposer extends Composer<_$AppDatabase, $PlaysTable> {
  $$PlaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inning => $composableBuilder(
    column: $table.inning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTop => $composableBuilder(
    column: $table.isTop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaysTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaysTable> {
  $$PlaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inning => $composableBuilder(
    column: $table.inning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTop => $composableBuilder(
    column: $table.isTop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaysTable> {
  $$PlaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get inning =>
      $composableBuilder(column: $table.inning, builder: (column) => column);

  GeneratedColumn<bool> get isTop =>
      $composableBuilder(column: $table.isTop, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaysTable,
          Play,
          $$PlaysTableFilterComposer,
          $$PlaysTableOrderingComposer,
          $$PlaysTableAnnotationComposer,
          $$PlaysTableCreateCompanionBuilder,
          $$PlaysTableUpdateCompanionBuilder,
          (Play, $$PlaysTableReferences),
          Play,
          PrefetchHooks Function({bool gameId})
        > {
  $$PlaysTableTableManager(_$AppDatabase db, $PlaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gameId = const Value.absent(),
                Value<int> inning = const Value.absent(),
                Value<bool> isTop = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => PlaysCompanion(
                id: id,
                gameId: gameId,
                inning: inning,
                isTop: isTop,
                result: result,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gameId,
                required int inning,
                required bool isTop,
                required String result,
                required DateTime timestamp,
              }) => PlaysCompanion.insert(
                id: id,
                gameId: gameId,
                inning: inning,
                isTop: isTop,
                result: result,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlaysTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({gameId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable: $$PlaysTableReferences
                                    ._gameIdTable(db),
                                referencedColumn: $$PlaysTableReferences
                                    ._gameIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaysTable,
      Play,
      $$PlaysTableFilterComposer,
      $$PlaysTableOrderingComposer,
      $$PlaysTableAnnotationComposer,
      $$PlaysTableCreateCompanionBuilder,
      $$PlaysTableUpdateCompanionBuilder,
      (Play, $$PlaysTableReferences),
      Play,
      PrefetchHooks Function({bool gameId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$GameLineupsTableTableManager get gameLineups =>
      $$GameLineupsTableTableManager(_db, _db.gameLineups);
  $$PlaysTableTableManager get plays =>
      $$PlaysTableTableManager(_db, _db.plays);
}
