// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BackupConfigurationsTable extends BackupConfigurations
    with TableInfo<$BackupConfigurationsTable, BackupConfiguration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupConfigurationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _providerTypeMeta = const VerificationMeta(
    'providerType',
  );
  @override
  late final GeneratedColumn<String> providerType = GeneratedColumn<String>(
    'provider_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bucketOrPathMeta = const VerificationMeta(
    'bucketOrPath',
  );
  @override
  late final GeneratedColumn<String> bucketOrPath = GeneratedColumn<String>(
    'bucket_or_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerType,
    displayName,
    endpoint,
    bucketOrPath,
    region,
    isDefault,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_configurations';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupConfiguration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider_type')) {
      context.handle(
        _providerTypeMeta,
        providerType.isAcceptableOrUnknown(
          data['provider_type']!,
          _providerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerTypeMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('bucket_or_path')) {
      context.handle(
        _bucketOrPathMeta,
        bucketOrPath.isAcceptableOrUnknown(
          data['bucket_or_path']!,
          _bucketOrPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bucketOrPathMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupConfiguration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupConfiguration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      providerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_type'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      bucketOrPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket_or_path'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BackupConfigurationsTable createAlias(String alias) {
    return $BackupConfigurationsTable(attachedDatabase, alias);
  }
}

class BackupConfiguration extends DataClass
    implements Insertable<BackupConfiguration> {
  /// 主键ID
  final int id;

  /// 提供者类型：webdav, s3
  final String providerType;

  /// 显示名称
  final String displayName;

  /// 服务端点 URL
  final String endpoint;

  /// 存储桶或路径
  final String bucketOrPath;

  /// 区域（S3 适用）
  final String? region;

  /// 是否为默认配置
  final bool isDefault;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;
  const BackupConfiguration({
    required this.id,
    required this.providerType,
    required this.displayName,
    required this.endpoint,
    required this.bucketOrPath,
    this.region,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider_type'] = Variable<String>(providerType);
    map['display_name'] = Variable<String>(displayName);
    map['endpoint'] = Variable<String>(endpoint);
    map['bucket_or_path'] = Variable<String>(bucketOrPath);
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BackupConfigurationsCompanion toCompanion(bool nullToAbsent) {
    return BackupConfigurationsCompanion(
      id: Value(id),
      providerType: Value(providerType),
      displayName: Value(displayName),
      endpoint: Value(endpoint),
      bucketOrPath: Value(bucketOrPath),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BackupConfiguration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupConfiguration(
      id: serializer.fromJson<int>(json['id']),
      providerType: serializer.fromJson<String>(json['providerType']),
      displayName: serializer.fromJson<String>(json['displayName']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      bucketOrPath: serializer.fromJson<String>(json['bucketOrPath']),
      region: serializer.fromJson<String?>(json['region']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerType': serializer.toJson<String>(providerType),
      'displayName': serializer.toJson<String>(displayName),
      'endpoint': serializer.toJson<String>(endpoint),
      'bucketOrPath': serializer.toJson<String>(bucketOrPath),
      'region': serializer.toJson<String?>(region),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BackupConfiguration copyWith({
    int? id,
    String? providerType,
    String? displayName,
    String? endpoint,
    String? bucketOrPath,
    Value<String?> region = const Value.absent(),
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BackupConfiguration(
    id: id ?? this.id,
    providerType: providerType ?? this.providerType,
    displayName: displayName ?? this.displayName,
    endpoint: endpoint ?? this.endpoint,
    bucketOrPath: bucketOrPath ?? this.bucketOrPath,
    region: region.present ? region.value : this.region,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BackupConfiguration copyWithCompanion(BackupConfigurationsCompanion data) {
    return BackupConfiguration(
      id: data.id.present ? data.id.value : this.id,
      providerType: data.providerType.present
          ? data.providerType.value
          : this.providerType,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      bucketOrPath: data.bucketOrPath.present
          ? data.bucketOrPath.value
          : this.bucketOrPath,
      region: data.region.present ? data.region.value : this.region,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupConfiguration(')
          ..write('id: $id, ')
          ..write('providerType: $providerType, ')
          ..write('displayName: $displayName, ')
          ..write('endpoint: $endpoint, ')
          ..write('bucketOrPath: $bucketOrPath, ')
          ..write('region: $region, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerType,
    displayName,
    endpoint,
    bucketOrPath,
    region,
    isDefault,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupConfiguration &&
          other.id == this.id &&
          other.providerType == this.providerType &&
          other.displayName == this.displayName &&
          other.endpoint == this.endpoint &&
          other.bucketOrPath == this.bucketOrPath &&
          other.region == this.region &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BackupConfigurationsCompanion
    extends UpdateCompanion<BackupConfiguration> {
  final Value<int> id;
  final Value<String> providerType;
  final Value<String> displayName;
  final Value<String> endpoint;
  final Value<String> bucketOrPath;
  final Value<String?> region;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BackupConfigurationsCompanion({
    this.id = const Value.absent(),
    this.providerType = const Value.absent(),
    this.displayName = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.bucketOrPath = const Value.absent(),
    this.region = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BackupConfigurationsCompanion.insert({
    this.id = const Value.absent(),
    required String providerType,
    required String displayName,
    required String endpoint,
    required String bucketOrPath,
    this.region = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : providerType = Value(providerType),
       displayName = Value(displayName),
       endpoint = Value(endpoint),
       bucketOrPath = Value(bucketOrPath);
  static Insertable<BackupConfiguration> custom({
    Expression<int>? id,
    Expression<String>? providerType,
    Expression<String>? displayName,
    Expression<String>? endpoint,
    Expression<String>? bucketOrPath,
    Expression<String>? region,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerType != null) 'provider_type': providerType,
      if (displayName != null) 'display_name': displayName,
      if (endpoint != null) 'endpoint': endpoint,
      if (bucketOrPath != null) 'bucket_or_path': bucketOrPath,
      if (region != null) 'region': region,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BackupConfigurationsCompanion copyWith({
    Value<int>? id,
    Value<String>? providerType,
    Value<String>? displayName,
    Value<String>? endpoint,
    Value<String>? bucketOrPath,
    Value<String?>? region,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BackupConfigurationsCompanion(
      id: id ?? this.id,
      providerType: providerType ?? this.providerType,
      displayName: displayName ?? this.displayName,
      endpoint: endpoint ?? this.endpoint,
      bucketOrPath: bucketOrPath ?? this.bucketOrPath,
      region: region ?? this.region,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (providerType.present) {
      map['provider_type'] = Variable<String>(providerType.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (bucketOrPath.present) {
      map['bucket_or_path'] = Variable<String>(bucketOrPath.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupConfigurationsCompanion(')
          ..write('id: $id, ')
          ..write('providerType: $providerType, ')
          ..write('displayName: $displayName, ')
          ..write('endpoint: $endpoint, ')
          ..write('bucketOrPath: $bucketOrPath, ')
          ..write('region: $region, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _weeklyWorkoutDaysGoalMeta =
      const VerificationMeta('weeklyWorkoutDaysGoal');
  @override
  late final GeneratedColumn<int> weeklyWorkoutDaysGoal = GeneratedColumn<int>(
    'weekly_workout_days_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _weeklyWorkoutMinutesGoalMeta =
      const VerificationMeta('weeklyWorkoutMinutesGoal');
  @override
  late final GeneratedColumn<int> weeklyWorkoutMinutesGoal =
      GeneratedColumn<int>(
        'weekly_workout_minutes_goal',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(150),
      );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _weightUnitMeta = const VerificationMeta(
    'weightUnit',
  );
  @override
  late final GeneratedColumn<String> weightUnit = GeneratedColumn<String>(
    'weight_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('kg'),
  );
  static const VerificationMeta _distanceUnitMeta = const VerificationMeta(
    'distanceUnit',
  );
  @override
  late final GeneratedColumn<String> distanceUnit = GeneratedColumn<String>(
    'distance_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('km'),
  );
  static const VerificationMeta _lanServiceEnabledMeta = const VerificationMeta(
    'lanServiceEnabled',
  );
  @override
  late final GeneratedColumn<bool> lanServiceEnabled = GeneratedColumn<bool>(
    'lan_service_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lan_service_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lanServicePortMeta = const VerificationMeta(
    'lanServicePort',
  );
  @override
  late final GeneratedColumn<int> lanServicePort = GeneratedColumn<int>(
    'lan_service_port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8080),
  );
  static const VerificationMeta _lanServiceTokenEnabledMeta =
      const VerificationMeta('lanServiceTokenEnabled');
  @override
  late final GeneratedColumn<bool> lanServiceTokenEnabled =
      GeneratedColumn<bool>(
        'lan_service_token_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("lan_service_token_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _defaultBackupConfigIdMeta =
      const VerificationMeta('defaultBackupConfigId');
  @override
  late final GeneratedColumn<int> defaultBackupConfigId = GeneratedColumn<int>(
    'default_backup_config_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES backup_configurations (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weeklyWorkoutDaysGoal,
    weeklyWorkoutMinutesGoal,
    themeMode,
    weightUnit,
    distanceUnit,
    lanServiceEnabled,
    lanServicePort,
    lanServiceTokenEnabled,
    defaultBackupConfigId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weekly_workout_days_goal')) {
      context.handle(
        _weeklyWorkoutDaysGoalMeta,
        weeklyWorkoutDaysGoal.isAcceptableOrUnknown(
          data['weekly_workout_days_goal']!,
          _weeklyWorkoutDaysGoalMeta,
        ),
      );
    }
    if (data.containsKey('weekly_workout_minutes_goal')) {
      context.handle(
        _weeklyWorkoutMinutesGoalMeta,
        weeklyWorkoutMinutesGoal.isAcceptableOrUnknown(
          data['weekly_workout_minutes_goal']!,
          _weeklyWorkoutMinutesGoalMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('weight_unit')) {
      context.handle(
        _weightUnitMeta,
        weightUnit.isAcceptableOrUnknown(data['weight_unit']!, _weightUnitMeta),
      );
    }
    if (data.containsKey('distance_unit')) {
      context.handle(
        _distanceUnitMeta,
        distanceUnit.isAcceptableOrUnknown(
          data['distance_unit']!,
          _distanceUnitMeta,
        ),
      );
    }
    if (data.containsKey('lan_service_enabled')) {
      context.handle(
        _lanServiceEnabledMeta,
        lanServiceEnabled.isAcceptableOrUnknown(
          data['lan_service_enabled']!,
          _lanServiceEnabledMeta,
        ),
      );
    }
    if (data.containsKey('lan_service_port')) {
      context.handle(
        _lanServicePortMeta,
        lanServicePort.isAcceptableOrUnknown(
          data['lan_service_port']!,
          _lanServicePortMeta,
        ),
      );
    }
    if (data.containsKey('lan_service_token_enabled')) {
      context.handle(
        _lanServiceTokenEnabledMeta,
        lanServiceTokenEnabled.isAcceptableOrUnknown(
          data['lan_service_token_enabled']!,
          _lanServiceTokenEnabledMeta,
        ),
      );
    }
    if (data.containsKey('default_backup_config_id')) {
      context.handle(
        _defaultBackupConfigIdMeta,
        defaultBackupConfigId.isAcceptableOrUnknown(
          data['default_backup_config_id']!,
          _defaultBackupConfigIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weeklyWorkoutDaysGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_workout_days_goal'],
      )!,
      weeklyWorkoutMinutesGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_workout_minutes_goal'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      weightUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_unit'],
      )!,
      distanceUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distance_unit'],
      )!,
      lanServiceEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lan_service_enabled'],
      )!,
      lanServicePort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lan_service_port'],
      )!,
      lanServiceTokenEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lan_service_token_enabled'],
      )!,
      defaultBackupConfigId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_backup_config_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  /// 主键ID
  final int id;

  /// 每周运动天数目标（默认3天）
  final int weeklyWorkoutDaysGoal;

  /// 每周运动分钟数目标（默认150分钟）
  final int weeklyWorkoutMinutesGoal;

  /// 主题模式：system, dark, light
  final String themeMode;

  /// 重量单位：kg, lbs
  final String weightUnit;

  /// 距离单位：km, mi
  final String distanceUnit;

  /// 局域网服务是否启用
  final bool lanServiceEnabled;

  /// 局域网服务端口号（默认8080）
  final int lanServicePort;

  /// 局域网服务访问令牌是否启用（默认关闭）
  final bool lanServiceTokenEnabled;

  /// 默认备份配置ID
  /// 配置删除时自动清空默认配置引用
  final int? defaultBackupConfigId;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;
  const UserSetting({
    required this.id,
    required this.weeklyWorkoutDaysGoal,
    required this.weeklyWorkoutMinutesGoal,
    required this.themeMode,
    required this.weightUnit,
    required this.distanceUnit,
    required this.lanServiceEnabled,
    required this.lanServicePort,
    required this.lanServiceTokenEnabled,
    this.defaultBackupConfigId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['weekly_workout_days_goal'] = Variable<int>(weeklyWorkoutDaysGoal);
    map['weekly_workout_minutes_goal'] = Variable<int>(
      weeklyWorkoutMinutesGoal,
    );
    map['theme_mode'] = Variable<String>(themeMode);
    map['weight_unit'] = Variable<String>(weightUnit);
    map['distance_unit'] = Variable<String>(distanceUnit);
    map['lan_service_enabled'] = Variable<bool>(lanServiceEnabled);
    map['lan_service_port'] = Variable<int>(lanServicePort);
    map['lan_service_token_enabled'] = Variable<bool>(lanServiceTokenEnabled);
    if (!nullToAbsent || defaultBackupConfigId != null) {
      map['default_backup_config_id'] = Variable<int>(defaultBackupConfigId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      weeklyWorkoutDaysGoal: Value(weeklyWorkoutDaysGoal),
      weeklyWorkoutMinutesGoal: Value(weeklyWorkoutMinutesGoal),
      themeMode: Value(themeMode),
      weightUnit: Value(weightUnit),
      distanceUnit: Value(distanceUnit),
      lanServiceEnabled: Value(lanServiceEnabled),
      lanServicePort: Value(lanServicePort),
      lanServiceTokenEnabled: Value(lanServiceTokenEnabled),
      defaultBackupConfigId: defaultBackupConfigId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultBackupConfigId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      id: serializer.fromJson<int>(json['id']),
      weeklyWorkoutDaysGoal: serializer.fromJson<int>(
        json['weeklyWorkoutDaysGoal'],
      ),
      weeklyWorkoutMinutesGoal: serializer.fromJson<int>(
        json['weeklyWorkoutMinutesGoal'],
      ),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      weightUnit: serializer.fromJson<String>(json['weightUnit']),
      distanceUnit: serializer.fromJson<String>(json['distanceUnit']),
      lanServiceEnabled: serializer.fromJson<bool>(json['lanServiceEnabled']),
      lanServicePort: serializer.fromJson<int>(json['lanServicePort']),
      lanServiceTokenEnabled: serializer.fromJson<bool>(
        json['lanServiceTokenEnabled'],
      ),
      defaultBackupConfigId: serializer.fromJson<int?>(
        json['defaultBackupConfigId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weeklyWorkoutDaysGoal': serializer.toJson<int>(weeklyWorkoutDaysGoal),
      'weeklyWorkoutMinutesGoal': serializer.toJson<int>(
        weeklyWorkoutMinutesGoal,
      ),
      'themeMode': serializer.toJson<String>(themeMode),
      'weightUnit': serializer.toJson<String>(weightUnit),
      'distanceUnit': serializer.toJson<String>(distanceUnit),
      'lanServiceEnabled': serializer.toJson<bool>(lanServiceEnabled),
      'lanServicePort': serializer.toJson<int>(lanServicePort),
      'lanServiceTokenEnabled': serializer.toJson<bool>(lanServiceTokenEnabled),
      'defaultBackupConfigId': serializer.toJson<int?>(defaultBackupConfigId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSetting copyWith({
    int? id,
    int? weeklyWorkoutDaysGoal,
    int? weeklyWorkoutMinutesGoal,
    String? themeMode,
    String? weightUnit,
    String? distanceUnit,
    bool? lanServiceEnabled,
    int? lanServicePort,
    bool? lanServiceTokenEnabled,
    Value<int?> defaultBackupConfigId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserSetting(
    id: id ?? this.id,
    weeklyWorkoutDaysGoal: weeklyWorkoutDaysGoal ?? this.weeklyWorkoutDaysGoal,
    weeklyWorkoutMinutesGoal:
        weeklyWorkoutMinutesGoal ?? this.weeklyWorkoutMinutesGoal,
    themeMode: themeMode ?? this.themeMode,
    weightUnit: weightUnit ?? this.weightUnit,
    distanceUnit: distanceUnit ?? this.distanceUnit,
    lanServiceEnabled: lanServiceEnabled ?? this.lanServiceEnabled,
    lanServicePort: lanServicePort ?? this.lanServicePort,
    lanServiceTokenEnabled:
        lanServiceTokenEnabled ?? this.lanServiceTokenEnabled,
    defaultBackupConfigId: defaultBackupConfigId.present
        ? defaultBackupConfigId.value
        : this.defaultBackupConfigId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      id: data.id.present ? data.id.value : this.id,
      weeklyWorkoutDaysGoal: data.weeklyWorkoutDaysGoal.present
          ? data.weeklyWorkoutDaysGoal.value
          : this.weeklyWorkoutDaysGoal,
      weeklyWorkoutMinutesGoal: data.weeklyWorkoutMinutesGoal.present
          ? data.weeklyWorkoutMinutesGoal.value
          : this.weeklyWorkoutMinutesGoal,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
      distanceUnit: data.distanceUnit.present
          ? data.distanceUnit.value
          : this.distanceUnit,
      lanServiceEnabled: data.lanServiceEnabled.present
          ? data.lanServiceEnabled.value
          : this.lanServiceEnabled,
      lanServicePort: data.lanServicePort.present
          ? data.lanServicePort.value
          : this.lanServicePort,
      lanServiceTokenEnabled: data.lanServiceTokenEnabled.present
          ? data.lanServiceTokenEnabled.value
          : this.lanServiceTokenEnabled,
      defaultBackupConfigId: data.defaultBackupConfigId.present
          ? data.defaultBackupConfigId.value
          : this.defaultBackupConfigId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('id: $id, ')
          ..write('weeklyWorkoutDaysGoal: $weeklyWorkoutDaysGoal, ')
          ..write('weeklyWorkoutMinutesGoal: $weeklyWorkoutMinutesGoal, ')
          ..write('themeMode: $themeMode, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('lanServiceEnabled: $lanServiceEnabled, ')
          ..write('lanServicePort: $lanServicePort, ')
          ..write('lanServiceTokenEnabled: $lanServiceTokenEnabled, ')
          ..write('defaultBackupConfigId: $defaultBackupConfigId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weeklyWorkoutDaysGoal,
    weeklyWorkoutMinutesGoal,
    themeMode,
    weightUnit,
    distanceUnit,
    lanServiceEnabled,
    lanServicePort,
    lanServiceTokenEnabled,
    defaultBackupConfigId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.id == this.id &&
          other.weeklyWorkoutDaysGoal == this.weeklyWorkoutDaysGoal &&
          other.weeklyWorkoutMinutesGoal == this.weeklyWorkoutMinutesGoal &&
          other.themeMode == this.themeMode &&
          other.weightUnit == this.weightUnit &&
          other.distanceUnit == this.distanceUnit &&
          other.lanServiceEnabled == this.lanServiceEnabled &&
          other.lanServicePort == this.lanServicePort &&
          other.lanServiceTokenEnabled == this.lanServiceTokenEnabled &&
          other.defaultBackupConfigId == this.defaultBackupConfigId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<int> id;
  final Value<int> weeklyWorkoutDaysGoal;
  final Value<int> weeklyWorkoutMinutesGoal;
  final Value<String> themeMode;
  final Value<String> weightUnit;
  final Value<String> distanceUnit;
  final Value<bool> lanServiceEnabled;
  final Value<int> lanServicePort;
  final Value<bool> lanServiceTokenEnabled;
  final Value<int?> defaultBackupConfigId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.weeklyWorkoutDaysGoal = const Value.absent(),
    this.weeklyWorkoutMinutesGoal = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.lanServiceEnabled = const Value.absent(),
    this.lanServicePort = const Value.absent(),
    this.lanServiceTokenEnabled = const Value.absent(),
    this.defaultBackupConfigId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.weeklyWorkoutDaysGoal = const Value.absent(),
    this.weeklyWorkoutMinutesGoal = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.lanServiceEnabled = const Value.absent(),
    this.lanServicePort = const Value.absent(),
    this.lanServiceTokenEnabled = const Value.absent(),
    this.defaultBackupConfigId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<UserSetting> custom({
    Expression<int>? id,
    Expression<int>? weeklyWorkoutDaysGoal,
    Expression<int>? weeklyWorkoutMinutesGoal,
    Expression<String>? themeMode,
    Expression<String>? weightUnit,
    Expression<String>? distanceUnit,
    Expression<bool>? lanServiceEnabled,
    Expression<int>? lanServicePort,
    Expression<bool>? lanServiceTokenEnabled,
    Expression<int>? defaultBackupConfigId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weeklyWorkoutDaysGoal != null)
        'weekly_workout_days_goal': weeklyWorkoutDaysGoal,
      if (weeklyWorkoutMinutesGoal != null)
        'weekly_workout_minutes_goal': weeklyWorkoutMinutesGoal,
      if (themeMode != null) 'theme_mode': themeMode,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (lanServiceEnabled != null) 'lan_service_enabled': lanServiceEnabled,
      if (lanServicePort != null) 'lan_service_port': lanServicePort,
      if (lanServiceTokenEnabled != null)
        'lan_service_token_enabled': lanServiceTokenEnabled,
      if (defaultBackupConfigId != null)
        'default_backup_config_id': defaultBackupConfigId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? weeklyWorkoutDaysGoal,
    Value<int>? weeklyWorkoutMinutesGoal,
    Value<String>? themeMode,
    Value<String>? weightUnit,
    Value<String>? distanceUnit,
    Value<bool>? lanServiceEnabled,
    Value<int>? lanServicePort,
    Value<bool>? lanServiceTokenEnabled,
    Value<int?>? defaultBackupConfigId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      weeklyWorkoutDaysGoal:
          weeklyWorkoutDaysGoal ?? this.weeklyWorkoutDaysGoal,
      weeklyWorkoutMinutesGoal:
          weeklyWorkoutMinutesGoal ?? this.weeklyWorkoutMinutesGoal,
      themeMode: themeMode ?? this.themeMode,
      weightUnit: weightUnit ?? this.weightUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      lanServiceEnabled: lanServiceEnabled ?? this.lanServiceEnabled,
      lanServicePort: lanServicePort ?? this.lanServicePort,
      lanServiceTokenEnabled:
          lanServiceTokenEnabled ?? this.lanServiceTokenEnabled,
      defaultBackupConfigId:
          defaultBackupConfigId ?? this.defaultBackupConfigId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weeklyWorkoutDaysGoal.present) {
      map['weekly_workout_days_goal'] = Variable<int>(
        weeklyWorkoutDaysGoal.value,
      );
    }
    if (weeklyWorkoutMinutesGoal.present) {
      map['weekly_workout_minutes_goal'] = Variable<int>(
        weeklyWorkoutMinutesGoal.value,
      );
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(weightUnit.value);
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(distanceUnit.value);
    }
    if (lanServiceEnabled.present) {
      map['lan_service_enabled'] = Variable<bool>(lanServiceEnabled.value);
    }
    if (lanServicePort.present) {
      map['lan_service_port'] = Variable<int>(lanServicePort.value);
    }
    if (lanServiceTokenEnabled.present) {
      map['lan_service_token_enabled'] = Variable<bool>(
        lanServiceTokenEnabled.value,
      );
    }
    if (defaultBackupConfigId.present) {
      map['default_backup_config_id'] = Variable<int>(
        defaultBackupConfigId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('weeklyWorkoutDaysGoal: $weeklyWorkoutDaysGoal, ')
          ..write('weeklyWorkoutMinutesGoal: $weeklyWorkoutMinutesGoal, ')
          ..write('themeMode: $themeMode, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('lanServiceEnabled: $lanServiceEnabled, ')
          ..write('lanServicePort: $lanServicePort, ')
          ..write('lanServiceTokenEnabled: $lanServiceTokenEnabled, ')
          ..write('defaultBackupConfigId: $defaultBackupConfigId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WorkoutTemplatesTable extends WorkoutTemplates
    with TableInfo<$WorkoutTemplatesTable, WorkoutTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutTemplatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    description,
    isDefault,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutTemplate> instance, {
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkoutTemplatesTable createAlias(String alias) {
    return $WorkoutTemplatesTable(attachedDatabase, alias);
  }
}

class WorkoutTemplate extends DataClass implements Insertable<WorkoutTemplate> {
  /// 主键ID
  final int id;

  /// 模板名称
  final String name;

  /// 模板类型：strength(健身), running(跑步), swimming(游泳)
  final String type;

  /// 模板描述
  final String? description;

  /// 是否为默认模板
  final bool isDefault;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;
  const WorkoutTemplate({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkoutTemplatesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkoutTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutTemplate(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String?>(description),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkoutTemplate copyWith({
    int? id,
    String? name,
    String? type,
    Value<String?> description = const Value.absent(),
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkoutTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    description: description.present ? description.value : this.description,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkoutTemplate copyWithCompanion(WorkoutTemplatesCompanion data) {
    return WorkoutTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, description, isDefault, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.description == this.description &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkoutTemplatesCompanion extends UpdateCompanion<WorkoutTemplate> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> description;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WorkoutTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WorkoutTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.description = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<WorkoutTemplate> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? description,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WorkoutTemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? description,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WorkoutTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TrainingSessionsTable extends TrainingSessions
    with TableInfo<$TrainingSessionsTable, TrainingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _datetimeMeta = const VerificationMeta(
    'datetime',
  );
  @override
  late final GeneratedColumn<DateTime> datetime = GeneratedColumn<DateTime>(
    'datetime',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intensityMeta = const VerificationMeta(
    'intensity',
  );
  @override
  late final GeneratedColumn<String> intensity = GeneratedColumn<String>(
    'intensity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGoalCompletedMeta = const VerificationMeta(
    'isGoalCompleted',
  );
  @override
  late final GeneratedColumn<bool> isGoalCompleted = GeneratedColumn<bool>(
    'is_goal_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_goal_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<int> templateId = GeneratedColumn<int>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_templates (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    datetime,
    type,
    durationMinutes,
    intensity,
    note,
    isGoalCompleted,
    templateId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('datetime')) {
      context.handle(
        _datetimeMeta,
        datetime.isAcceptableOrUnknown(data['datetime']!, _datetimeMeta),
      );
    } else if (isInserting) {
      context.missing(_datetimeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('intensity')) {
      context.handle(
        _intensityMeta,
        intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta),
      );
    } else if (isInserting) {
      context.missing(_intensityMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_goal_completed')) {
      context.handle(
        _isGoalCompletedMeta,
        isGoalCompleted.isAcceptableOrUnknown(
          data['is_goal_completed']!,
          _isGoalCompletedMeta,
        ),
      );
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      datetime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}datetime'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      intensity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intensity'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isGoalCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_goal_completed'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TrainingSessionsTable createAlias(String alias) {
    return $TrainingSessionsTable(attachedDatabase, alias);
  }
}

class TrainingSession extends DataClass implements Insertable<TrainingSession> {
  /// 主键ID
  final int id;

  /// 会话日期时间
  final DateTime datetime;

  /// 运动类型：strength, running, swimming, cycling, jump_rope, walking, yoga, stretching, custom
  final String type;

  /// 运动时长（分钟）
  final int durationMinutes;

  /// 运动强度：light, moderate, high
  final String intensity;

  /// 备注
  final String? note;

  /// 是否完成目标
  final bool isGoalCompleted;

  /// 使用的模板ID（可选）
  /// 模板删除时自动设为 NULL
  final int? templateId;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;
  const TrainingSession({
    required this.id,
    required this.datetime,
    required this.type,
    required this.durationMinutes,
    required this.intensity,
    this.note,
    required this.isGoalCompleted,
    this.templateId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['datetime'] = Variable<DateTime>(datetime);
    map['type'] = Variable<String>(type);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['intensity'] = Variable<String>(intensity);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_goal_completed'] = Variable<bool>(isGoalCompleted);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<int>(templateId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrainingSessionsCompanion toCompanion(bool nullToAbsent) {
    return TrainingSessionsCompanion(
      id: Value(id),
      datetime: Value(datetime),
      type: Value(type),
      durationMinutes: Value(durationMinutes),
      intensity: Value(intensity),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isGoalCompleted: Value(isGoalCompleted),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TrainingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingSession(
      id: serializer.fromJson<int>(json['id']),
      datetime: serializer.fromJson<DateTime>(json['datetime']),
      type: serializer.fromJson<String>(json['type']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      intensity: serializer.fromJson<String>(json['intensity']),
      note: serializer.fromJson<String?>(json['note']),
      isGoalCompleted: serializer.fromJson<bool>(json['isGoalCompleted']),
      templateId: serializer.fromJson<int?>(json['templateId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'datetime': serializer.toJson<DateTime>(datetime),
      'type': serializer.toJson<String>(type),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'intensity': serializer.toJson<String>(intensity),
      'note': serializer.toJson<String?>(note),
      'isGoalCompleted': serializer.toJson<bool>(isGoalCompleted),
      'templateId': serializer.toJson<int?>(templateId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TrainingSession copyWith({
    int? id,
    DateTime? datetime,
    String? type,
    int? durationMinutes,
    String? intensity,
    Value<String?> note = const Value.absent(),
    bool? isGoalCompleted,
    Value<int?> templateId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TrainingSession(
    id: id ?? this.id,
    datetime: datetime ?? this.datetime,
    type: type ?? this.type,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    intensity: intensity ?? this.intensity,
    note: note.present ? note.value : this.note,
    isGoalCompleted: isGoalCompleted ?? this.isGoalCompleted,
    templateId: templateId.present ? templateId.value : this.templateId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TrainingSession copyWithCompanion(TrainingSessionsCompanion data) {
    return TrainingSession(
      id: data.id.present ? data.id.value : this.id,
      datetime: data.datetime.present ? data.datetime.value : this.datetime,
      type: data.type.present ? data.type.value : this.type,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      note: data.note.present ? data.note.value : this.note,
      isGoalCompleted: data.isGoalCompleted.present
          ? data.isGoalCompleted.value
          : this.isGoalCompleted,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingSession(')
          ..write('id: $id, ')
          ..write('datetime: $datetime, ')
          ..write('type: $type, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('intensity: $intensity, ')
          ..write('note: $note, ')
          ..write('isGoalCompleted: $isGoalCompleted, ')
          ..write('templateId: $templateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    datetime,
    type,
    durationMinutes,
    intensity,
    note,
    isGoalCompleted,
    templateId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingSession &&
          other.id == this.id &&
          other.datetime == this.datetime &&
          other.type == this.type &&
          other.durationMinutes == this.durationMinutes &&
          other.intensity == this.intensity &&
          other.note == this.note &&
          other.isGoalCompleted == this.isGoalCompleted &&
          other.templateId == this.templateId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TrainingSessionsCompanion extends UpdateCompanion<TrainingSession> {
  final Value<int> id;
  final Value<DateTime> datetime;
  final Value<String> type;
  final Value<int> durationMinutes;
  final Value<String> intensity;
  final Value<String?> note;
  final Value<bool> isGoalCompleted;
  final Value<int?> templateId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TrainingSessionsCompanion({
    this.id = const Value.absent(),
    this.datetime = const Value.absent(),
    this.type = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.intensity = const Value.absent(),
    this.note = const Value.absent(),
    this.isGoalCompleted = const Value.absent(),
    this.templateId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TrainingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime datetime,
    required String type,
    required int durationMinutes,
    required String intensity,
    this.note = const Value.absent(),
    this.isGoalCompleted = const Value.absent(),
    this.templateId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : datetime = Value(datetime),
       type = Value(type),
       durationMinutes = Value(durationMinutes),
       intensity = Value(intensity);
  static Insertable<TrainingSession> custom({
    Expression<int>? id,
    Expression<DateTime>? datetime,
    Expression<String>? type,
    Expression<int>? durationMinutes,
    Expression<String>? intensity,
    Expression<String>? note,
    Expression<bool>? isGoalCompleted,
    Expression<int>? templateId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (datetime != null) 'datetime': datetime,
      if (type != null) 'type': type,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (intensity != null) 'intensity': intensity,
      if (note != null) 'note': note,
      if (isGoalCompleted != null) 'is_goal_completed': isGoalCompleted,
      if (templateId != null) 'template_id': templateId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TrainingSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? datetime,
    Value<String>? type,
    Value<int>? durationMinutes,
    Value<String>? intensity,
    Value<String?>? note,
    Value<bool>? isGoalCompleted,
    Value<int?>? templateId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TrainingSessionsCompanion(
      id: id ?? this.id,
      datetime: datetime ?? this.datetime,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      isGoalCompleted: isGoalCompleted ?? this.isGoalCompleted,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (datetime.present) {
      map['datetime'] = Variable<DateTime>(datetime.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<String>(intensity.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isGoalCompleted.present) {
      map['is_goal_completed'] = Variable<bool>(isGoalCompleted.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<int>(templateId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('datetime: $datetime, ')
          ..write('type: $type, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('intensity: $intensity, ')
          ..write('note: $note, ')
          ..write('isGoalCompleted: $isGoalCompleted, ')
          ..write('templateId: $templateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementTypeMeta = const VerificationMeta(
    'movementType',
  );
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('compound'),
  );
  static const VerificationMeta _primaryMusclesMeta = const VerificationMeta(
    'primaryMuscles',
  );
  @override
  late final GeneratedColumn<String> primaryMuscles = GeneratedColumn<String>(
    'primary_muscles',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondaryMusclesMeta = const VerificationMeta(
    'secondaryMuscles',
  );
  @override
  late final GeneratedColumn<String> secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultSetsMeta = const VerificationMeta(
    'defaultSets',
  );
  @override
  late final GeneratedColumn<int> defaultSets = GeneratedColumn<int>(
    'default_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _defaultRepsMeta = const VerificationMeta(
    'defaultReps',
  );
  @override
  late final GeneratedColumn<int> defaultReps = GeneratedColumn<int>(
    'default_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _defaultWeightMeta = const VerificationMeta(
    'defaultWeight',
  );
  @override
  late final GeneratedColumn<double> defaultWeight = GeneratedColumn<double>(
    'default_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    movementType,
    primaryMuscles,
    secondaryMuscles,
    defaultSets,
    defaultReps,
    defaultWeight,
    isCustom,
    isEnabled,
    description,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
        _movementTypeMeta,
        movementType.isAcceptableOrUnknown(
          data['movement_type']!,
          _movementTypeMeta,
        ),
      );
    }
    if (data.containsKey('primary_muscles')) {
      context.handle(
        _primaryMusclesMeta,
        primaryMuscles.isAcceptableOrUnknown(
          data['primary_muscles']!,
          _primaryMusclesMeta,
        ),
      );
    }
    if (data.containsKey('secondary_muscles')) {
      context.handle(
        _secondaryMusclesMeta,
        secondaryMuscles.isAcceptableOrUnknown(
          data['secondary_muscles']!,
          _secondaryMusclesMeta,
        ),
      );
    }
    if (data.containsKey('default_sets')) {
      context.handle(
        _defaultSetsMeta,
        defaultSets.isAcceptableOrUnknown(
          data['default_sets']!,
          _defaultSetsMeta,
        ),
      );
    }
    if (data.containsKey('default_reps')) {
      context.handle(
        _defaultRepsMeta,
        defaultReps.isAcceptableOrUnknown(
          data['default_reps']!,
          _defaultRepsMeta,
        ),
      );
    }
    if (data.containsKey('default_weight')) {
      context.handle(
        _defaultWeightMeta,
        defaultWeight.isAcceptableOrUnknown(
          data['default_weight']!,
          _defaultWeightMeta,
        ),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      movementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_type'],
      )!,
      primaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_muscles'],
      ),
      secondaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_muscles'],
      ),
      defaultSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_sets'],
      )!,
      defaultReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_reps'],
      )!,
      defaultWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_weight'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  /// 主键ID
  final int id;

  /// 动作名称
  final String name;

  /// 动作分类：chest(胸), back(背), shoulders(肩), arms(臂), legs(腿), core(核心), full_body(全身), cardio(有氧)
  final String category;

  /// 动作类型：compound(复合动作), isolation(孤立动作)
  final String movementType;

  /// 主要肌群（逗号分隔）
  final String? primaryMuscles;

  /// 次要肌群（逗号分隔）
  final String? secondaryMuscles;

  /// 默认组数
  final int defaultSets;

  /// 默认次数
  final int defaultReps;

  /// 默认重量（可选）
  final double? defaultWeight;

  /// 是否为用户自定义动作
  final bool isCustom;

  /// 是否启用
  final bool isEnabled;

  /// 动作描述/说明
  final String? description;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.movementType,
    this.primaryMuscles,
    this.secondaryMuscles,
    required this.defaultSets,
    required this.defaultReps,
    this.defaultWeight,
    required this.isCustom,
    required this.isEnabled,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['movement_type'] = Variable<String>(movementType);
    if (!nullToAbsent || primaryMuscles != null) {
      map['primary_muscles'] = Variable<String>(primaryMuscles);
    }
    if (!nullToAbsent || secondaryMuscles != null) {
      map['secondary_muscles'] = Variable<String>(secondaryMuscles);
    }
    map['default_sets'] = Variable<int>(defaultSets);
    map['default_reps'] = Variable<int>(defaultReps);
    if (!nullToAbsent || defaultWeight != null) {
      map['default_weight'] = Variable<double>(defaultWeight);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['is_enabled'] = Variable<bool>(isEnabled);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      movementType: Value(movementType),
      primaryMuscles: primaryMuscles == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryMuscles),
      secondaryMuscles: secondaryMuscles == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryMuscles),
      defaultSets: Value(defaultSets),
      defaultReps: Value(defaultReps),
      defaultWeight: defaultWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultWeight),
      isCustom: Value(isCustom),
      isEnabled: Value(isEnabled),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      movementType: serializer.fromJson<String>(json['movementType']),
      primaryMuscles: serializer.fromJson<String?>(json['primaryMuscles']),
      secondaryMuscles: serializer.fromJson<String?>(json['secondaryMuscles']),
      defaultSets: serializer.fromJson<int>(json['defaultSets']),
      defaultReps: serializer.fromJson<int>(json['defaultReps']),
      defaultWeight: serializer.fromJson<double?>(json['defaultWeight']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'movementType': serializer.toJson<String>(movementType),
      'primaryMuscles': serializer.toJson<String?>(primaryMuscles),
      'secondaryMuscles': serializer.toJson<String?>(secondaryMuscles),
      'defaultSets': serializer.toJson<int>(defaultSets),
      'defaultReps': serializer.toJson<int>(defaultReps),
      'defaultWeight': serializer.toJson<double?>(defaultWeight),
      'isCustom': serializer.toJson<bool>(isCustom),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? category,
    String? movementType,
    Value<String?> primaryMuscles = const Value.absent(),
    Value<String?> secondaryMuscles = const Value.absent(),
    int? defaultSets,
    int? defaultReps,
    Value<double?> defaultWeight = const Value.absent(),
    bool? isCustom,
    bool? isEnabled,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    movementType: movementType ?? this.movementType,
    primaryMuscles: primaryMuscles.present
        ? primaryMuscles.value
        : this.primaryMuscles,
    secondaryMuscles: secondaryMuscles.present
        ? secondaryMuscles.value
        : this.secondaryMuscles,
    defaultSets: defaultSets ?? this.defaultSets,
    defaultReps: defaultReps ?? this.defaultReps,
    defaultWeight: defaultWeight.present
        ? defaultWeight.value
        : this.defaultWeight,
    isCustom: isCustom ?? this.isCustom,
    isEnabled: isEnabled ?? this.isEnabled,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      primaryMuscles: data.primaryMuscles.present
          ? data.primaryMuscles.value
          : this.primaryMuscles,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      defaultSets: data.defaultSets.present
          ? data.defaultSets.value
          : this.defaultSets,
      defaultReps: data.defaultReps.present
          ? data.defaultReps.value
          : this.defaultReps,
      defaultWeight: data.defaultWeight.present
          ? data.defaultWeight.value
          : this.defaultWeight,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('movementType: $movementType, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('defaultSets: $defaultSets, ')
          ..write('defaultReps: $defaultReps, ')
          ..write('defaultWeight: $defaultWeight, ')
          ..write('isCustom: $isCustom, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    movementType,
    primaryMuscles,
    secondaryMuscles,
    defaultSets,
    defaultReps,
    defaultWeight,
    isCustom,
    isEnabled,
    description,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.movementType == this.movementType &&
          other.primaryMuscles == this.primaryMuscles &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.defaultSets == this.defaultSets &&
          other.defaultReps == this.defaultReps &&
          other.defaultWeight == this.defaultWeight &&
          other.isCustom == this.isCustom &&
          other.isEnabled == this.isEnabled &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> movementType;
  final Value<String?> primaryMuscles;
  final Value<String?> secondaryMuscles;
  final Value<int> defaultSets;
  final Value<int> defaultReps;
  final Value<double?> defaultWeight;
  final Value<bool> isCustom;
  final Value<bool> isEnabled;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.movementType = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.defaultSets = const Value.absent(),
    this.defaultReps = const Value.absent(),
    this.defaultWeight = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String category,
    this.movementType = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.defaultSets = const Value.absent(),
    this.defaultReps = const Value.absent(),
    this.defaultWeight = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       category = Value(category);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? movementType,
    Expression<String>? primaryMuscles,
    Expression<String>? secondaryMuscles,
    Expression<int>? defaultSets,
    Expression<int>? defaultReps,
    Expression<double>? defaultWeight,
    Expression<bool>? isCustom,
    Expression<bool>? isEnabled,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (movementType != null) 'movement_type': movementType,
      if (primaryMuscles != null) 'primary_muscles': primaryMuscles,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (defaultSets != null) 'default_sets': defaultSets,
      if (defaultReps != null) 'default_reps': defaultReps,
      if (defaultWeight != null) 'default_weight': defaultWeight,
      if (isCustom != null) 'is_custom': isCustom,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? category,
    Value<String>? movementType,
    Value<String?>? primaryMuscles,
    Value<String?>? secondaryMuscles,
    Value<int>? defaultSets,
    Value<int>? defaultReps,
    Value<double?>? defaultWeight,
    Value<bool>? isCustom,
    Value<bool>? isEnabled,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      movementType: movementType ?? this.movementType,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      isCustom: isCustom ?? this.isCustom,
      isEnabled: isEnabled ?? this.isEnabled,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (primaryMuscles.present) {
      map['primary_muscles'] = Variable<String>(primaryMuscles.value);
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(secondaryMuscles.value);
    }
    if (defaultSets.present) {
      map['default_sets'] = Variable<int>(defaultSets.value);
    }
    if (defaultReps.present) {
      map['default_reps'] = Variable<int>(defaultReps.value);
    }
    if (defaultWeight.present) {
      map['default_weight'] = Variable<double>(defaultWeight.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('movementType: $movementType, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('defaultSets: $defaultSets, ')
          ..write('defaultReps: $defaultReps, ')
          ..write('defaultWeight: $defaultWeight, ')
          ..write('isCustom: $isCustom, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $StrengthExerciseEntriesTable extends StrengthExerciseEntries
    with TableInfo<$StrengthExerciseEntriesTable, StrengthExerciseEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrengthExerciseEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES training_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultRepsMeta = const VerificationMeta(
    'defaultReps',
  );
  @override
  late final GeneratedColumn<int> defaultReps = GeneratedColumn<int>(
    'default_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultWeightMeta = const VerificationMeta(
    'defaultWeight',
  );
  @override
  late final GeneratedColumn<double> defaultWeight = GeneratedColumn<double>(
    'default_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsPerSetMeta = const VerificationMeta(
    'repsPerSet',
  );
  @override
  late final GeneratedColumn<String> repsPerSet = GeneratedColumn<String>(
    'reps_per_set',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightPerSetMeta = const VerificationMeta(
    'weightPerSet',
  );
  @override
  late final GeneratedColumn<String> weightPerSet = GeneratedColumn<String>(
    'weight_per_set',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setCompletedMeta = const VerificationMeta(
    'setCompleted',
  );
  @override
  late final GeneratedColumn<String> setCompleted = GeneratedColumn<String>(
    'set_completed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isWarmupMeta = const VerificationMeta(
    'isWarmup',
  );
  @override
  late final GeneratedColumn<bool> isWarmup = GeneratedColumn<bool>(
    'is_warmup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_warmup" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    exerciseName,
    sets,
    defaultReps,
    defaultWeight,
    repsPerSet,
    weightPerSet,
    setCompleted,
    isWarmup,
    rpe,
    restSeconds,
    sortOrder,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strength_exercise_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrengthExerciseEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    } else if (isInserting) {
      context.missing(_setsMeta);
    }
    if (data.containsKey('default_reps')) {
      context.handle(
        _defaultRepsMeta,
        defaultReps.isAcceptableOrUnknown(
          data['default_reps']!,
          _defaultRepsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultRepsMeta);
    }
    if (data.containsKey('default_weight')) {
      context.handle(
        _defaultWeightMeta,
        defaultWeight.isAcceptableOrUnknown(
          data['default_weight']!,
          _defaultWeightMeta,
        ),
      );
    }
    if (data.containsKey('reps_per_set')) {
      context.handle(
        _repsPerSetMeta,
        repsPerSet.isAcceptableOrUnknown(
          data['reps_per_set']!,
          _repsPerSetMeta,
        ),
      );
    }
    if (data.containsKey('weight_per_set')) {
      context.handle(
        _weightPerSetMeta,
        weightPerSet.isAcceptableOrUnknown(
          data['weight_per_set']!,
          _weightPerSetMeta,
        ),
      );
    }
    if (data.containsKey('set_completed')) {
      context.handle(
        _setCompletedMeta,
        setCompleted.isAcceptableOrUnknown(
          data['set_completed']!,
          _setCompletedMeta,
        ),
      );
    }
    if (data.containsKey('is_warmup')) {
      context.handle(
        _isWarmupMeta,
        isWarmup.isAcceptableOrUnknown(data['is_warmup']!, _isWarmupMeta),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrengthExerciseEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrengthExerciseEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      ),
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets'],
      )!,
      defaultReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_reps'],
      )!,
      defaultWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_weight'],
      ),
      repsPerSet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reps_per_set'],
      ),
      weightPerSet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_per_set'],
      ),
      setCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_completed'],
      ),
      isWarmup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_warmup'],
      )!,
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $StrengthExerciseEntriesTable createAlias(String alias) {
    return $StrengthExerciseEntriesTable(attachedDatabase, alias);
  }
}

class StrengthExerciseEntry extends DataClass
    implements Insertable<StrengthExerciseEntry> {
  /// 主键ID
  final int id;

  /// 关联的训练会话ID（原名 workoutRecordId）
  /// 会话删除时级联删除力量条目
  final int sessionId;

  /// 关联的动作库ID（可选）
  /// 动作删除受限，避免破坏历史训练数据
  final int? exerciseId;

  /// 练习名称（保留以兼容手动输入）
  final String exerciseName;

  /// 组数
  final int sets;

  /// 默认次数
  final int defaultReps;

  /// 默认重量（可选）
  final double? defaultWeight;

  /// 每组次数（JSON 数组，支持不同次数，如 "[10, 8, 6]"）
  final String? repsPerSet;

  /// 每组重量（JSON 数组，如 "[60.0, 65.0, 70.0]"）
  final String? weightPerSet;

  /// 每组完成状态（JSON 数组，如 "[true, true, false]"）
  final String? setCompleted;

  /// 是否为热身组
  final bool isWarmup;

  /// RPE（主观强度感受，1-10）
  final int? rpe;

  /// 休息时间（秒）
  final int? restSeconds;

  /// 排序顺序
  final int sortOrder;

  /// 备注
  final String? note;
  const StrengthExerciseEntry({
    required this.id,
    required this.sessionId,
    this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.defaultReps,
    this.defaultWeight,
    this.repsPerSet,
    this.weightPerSet,
    this.setCompleted,
    required this.isWarmup,
    this.rpe,
    this.restSeconds,
    required this.sortOrder,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<int>(exerciseId);
    }
    map['exercise_name'] = Variable<String>(exerciseName);
    map['sets'] = Variable<int>(sets);
    map['default_reps'] = Variable<int>(defaultReps);
    if (!nullToAbsent || defaultWeight != null) {
      map['default_weight'] = Variable<double>(defaultWeight);
    }
    if (!nullToAbsent || repsPerSet != null) {
      map['reps_per_set'] = Variable<String>(repsPerSet);
    }
    if (!nullToAbsent || weightPerSet != null) {
      map['weight_per_set'] = Variable<String>(weightPerSet);
    }
    if (!nullToAbsent || setCompleted != null) {
      map['set_completed'] = Variable<String>(setCompleted);
    }
    map['is_warmup'] = Variable<bool>(isWarmup);
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  StrengthExerciseEntriesCompanion toCompanion(bool nullToAbsent) {
    return StrengthExerciseEntriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: exerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseId),
      exerciseName: Value(exerciseName),
      sets: Value(sets),
      defaultReps: Value(defaultReps),
      defaultWeight: defaultWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultWeight),
      repsPerSet: repsPerSet == null && nullToAbsent
          ? const Value.absent()
          : Value(repsPerSet),
      weightPerSet: weightPerSet == null && nullToAbsent
          ? const Value.absent()
          : Value(weightPerSet),
      setCompleted: setCompleted == null && nullToAbsent
          ? const Value.absent()
          : Value(setCompleted),
      isWarmup: Value(isWarmup),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      restSeconds: restSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restSeconds),
      sortOrder: Value(sortOrder),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory StrengthExerciseEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrengthExerciseEntry(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseId: serializer.fromJson<int?>(json['exerciseId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      sets: serializer.fromJson<int>(json['sets']),
      defaultReps: serializer.fromJson<int>(json['defaultReps']),
      defaultWeight: serializer.fromJson<double?>(json['defaultWeight']),
      repsPerSet: serializer.fromJson<String?>(json['repsPerSet']),
      weightPerSet: serializer.fromJson<String?>(json['weightPerSet']),
      setCompleted: serializer.fromJson<String?>(json['setCompleted']),
      isWarmup: serializer.fromJson<bool>(json['isWarmup']),
      rpe: serializer.fromJson<int?>(json['rpe']),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseId': serializer.toJson<int?>(exerciseId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'sets': serializer.toJson<int>(sets),
      'defaultReps': serializer.toJson<int>(defaultReps),
      'defaultWeight': serializer.toJson<double?>(defaultWeight),
      'repsPerSet': serializer.toJson<String?>(repsPerSet),
      'weightPerSet': serializer.toJson<String?>(weightPerSet),
      'setCompleted': serializer.toJson<String?>(setCompleted),
      'isWarmup': serializer.toJson<bool>(isWarmup),
      'rpe': serializer.toJson<int?>(rpe),
      'restSeconds': serializer.toJson<int?>(restSeconds),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'note': serializer.toJson<String?>(note),
    };
  }

  StrengthExerciseEntry copyWith({
    int? id,
    int? sessionId,
    Value<int?> exerciseId = const Value.absent(),
    String? exerciseName,
    int? sets,
    int? defaultReps,
    Value<double?> defaultWeight = const Value.absent(),
    Value<String?> repsPerSet = const Value.absent(),
    Value<String?> weightPerSet = const Value.absent(),
    Value<String?> setCompleted = const Value.absent(),
    bool? isWarmup,
    Value<int?> rpe = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
    int? sortOrder,
    Value<String?> note = const Value.absent(),
  }) => StrengthExerciseEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    exerciseName: exerciseName ?? this.exerciseName,
    sets: sets ?? this.sets,
    defaultReps: defaultReps ?? this.defaultReps,
    defaultWeight: defaultWeight.present
        ? defaultWeight.value
        : this.defaultWeight,
    repsPerSet: repsPerSet.present ? repsPerSet.value : this.repsPerSet,
    weightPerSet: weightPerSet.present ? weightPerSet.value : this.weightPerSet,
    setCompleted: setCompleted.present ? setCompleted.value : this.setCompleted,
    isWarmup: isWarmup ?? this.isWarmup,
    rpe: rpe.present ? rpe.value : this.rpe,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
    sortOrder: sortOrder ?? this.sortOrder,
    note: note.present ? note.value : this.note,
  );
  StrengthExerciseEntry copyWithCompanion(
    StrengthExerciseEntriesCompanion data,
  ) {
    return StrengthExerciseEntry(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      sets: data.sets.present ? data.sets.value : this.sets,
      defaultReps: data.defaultReps.present
          ? data.defaultReps.value
          : this.defaultReps,
      defaultWeight: data.defaultWeight.present
          ? data.defaultWeight.value
          : this.defaultWeight,
      repsPerSet: data.repsPerSet.present
          ? data.repsPerSet.value
          : this.repsPerSet,
      weightPerSet: data.weightPerSet.present
          ? data.weightPerSet.value
          : this.weightPerSet,
      setCompleted: data.setCompleted.present
          ? data.setCompleted.value
          : this.setCompleted,
      isWarmup: data.isWarmup.present ? data.isWarmup.value : this.isWarmup,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrengthExerciseEntry(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('sets: $sets, ')
          ..write('defaultReps: $defaultReps, ')
          ..write('defaultWeight: $defaultWeight, ')
          ..write('repsPerSet: $repsPerSet, ')
          ..write('weightPerSet: $weightPerSet, ')
          ..write('setCompleted: $setCompleted, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('rpe: $rpe, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    exerciseId,
    exerciseName,
    sets,
    defaultReps,
    defaultWeight,
    repsPerSet,
    weightPerSet,
    setCompleted,
    isWarmup,
    rpe,
    restSeconds,
    sortOrder,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrengthExerciseEntry &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.exerciseName == this.exerciseName &&
          other.sets == this.sets &&
          other.defaultReps == this.defaultReps &&
          other.defaultWeight == this.defaultWeight &&
          other.repsPerSet == this.repsPerSet &&
          other.weightPerSet == this.weightPerSet &&
          other.setCompleted == this.setCompleted &&
          other.isWarmup == this.isWarmup &&
          other.rpe == this.rpe &&
          other.restSeconds == this.restSeconds &&
          other.sortOrder == this.sortOrder &&
          other.note == this.note);
}

class StrengthExerciseEntriesCompanion
    extends UpdateCompanion<StrengthExerciseEntry> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int?> exerciseId;
  final Value<String> exerciseName;
  final Value<int> sets;
  final Value<int> defaultReps;
  final Value<double?> defaultWeight;
  final Value<String?> repsPerSet;
  final Value<String?> weightPerSet;
  final Value<String?> setCompleted;
  final Value<bool> isWarmup;
  final Value<int?> rpe;
  final Value<int?> restSeconds;
  final Value<int> sortOrder;
  final Value<String?> note;
  const StrengthExerciseEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.sets = const Value.absent(),
    this.defaultReps = const Value.absent(),
    this.defaultWeight = const Value.absent(),
    this.repsPerSet = const Value.absent(),
    this.weightPerSet = const Value.absent(),
    this.setCompleted = const Value.absent(),
    this.isWarmup = const Value.absent(),
    this.rpe = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.note = const Value.absent(),
  });
  StrengthExerciseEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.exerciseId = const Value.absent(),
    required String exerciseName,
    required int sets,
    required int defaultReps,
    this.defaultWeight = const Value.absent(),
    this.repsPerSet = const Value.absent(),
    this.weightPerSet = const Value.absent(),
    this.setCompleted = const Value.absent(),
    this.isWarmup = const Value.absent(),
    this.rpe = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.note = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseName = Value(exerciseName),
       sets = Value(sets),
       defaultReps = Value(defaultReps);
  static Insertable<StrengthExerciseEntry> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? exerciseId,
    Expression<String>? exerciseName,
    Expression<int>? sets,
    Expression<int>? defaultReps,
    Expression<double>? defaultWeight,
    Expression<String>? repsPerSet,
    Expression<String>? weightPerSet,
    Expression<String>? setCompleted,
    Expression<bool>? isWarmup,
    Expression<int>? rpe,
    Expression<int>? restSeconds,
    Expression<int>? sortOrder,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (sets != null) 'sets': sets,
      if (defaultReps != null) 'default_reps': defaultReps,
      if (defaultWeight != null) 'default_weight': defaultWeight,
      if (repsPerSet != null) 'reps_per_set': repsPerSet,
      if (weightPerSet != null) 'weight_per_set': weightPerSet,
      if (setCompleted != null) 'set_completed': setCompleted,
      if (isWarmup != null) 'is_warmup': isWarmup,
      if (rpe != null) 'rpe': rpe,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (note != null) 'note': note,
    });
  }

  StrengthExerciseEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int?>? exerciseId,
    Value<String>? exerciseName,
    Value<int>? sets,
    Value<int>? defaultReps,
    Value<double?>? defaultWeight,
    Value<String?>? repsPerSet,
    Value<String?>? weightPerSet,
    Value<String?>? setCompleted,
    Value<bool>? isWarmup,
    Value<int?>? rpe,
    Value<int?>? restSeconds,
    Value<int>? sortOrder,
    Value<String?>? note,
  }) {
    return StrengthExerciseEntriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      weightPerSet: weightPerSet ?? this.weightPerSet,
      setCompleted: setCompleted ?? this.setCompleted,
      isWarmup: isWarmup ?? this.isWarmup,
      rpe: rpe ?? this.rpe,
      restSeconds: restSeconds ?? this.restSeconds,
      sortOrder: sortOrder ?? this.sortOrder,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (defaultReps.present) {
      map['default_reps'] = Variable<int>(defaultReps.value);
    }
    if (defaultWeight.present) {
      map['default_weight'] = Variable<double>(defaultWeight.value);
    }
    if (repsPerSet.present) {
      map['reps_per_set'] = Variable<String>(repsPerSet.value);
    }
    if (weightPerSet.present) {
      map['weight_per_set'] = Variable<String>(weightPerSet.value);
    }
    if (setCompleted.present) {
      map['set_completed'] = Variable<String>(setCompleted.value);
    }
    if (isWarmup.present) {
      map['is_warmup'] = Variable<bool>(isWarmup.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrengthExerciseEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('sets: $sets, ')
          ..write('defaultReps: $defaultReps, ')
          ..write('defaultWeight: $defaultWeight, ')
          ..write('repsPerSet: $repsPerSet, ')
          ..write('weightPerSet: $weightPerSet, ')
          ..write('setCompleted: $setCompleted, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('rpe: $rpe, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $BackupRecordsTable extends BackupRecords
    with TableInfo<$BackupRecordsTable, BackupRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _configIdMeta = const VerificationMeta(
    'configId',
  );
  @override
  late final GeneratedColumn<int> configId = GeneratedColumn<int>(
    'config_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES backup_configurations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _providerTypeMeta = const VerificationMeta(
    'providerType',
  );
  @override
  late final GeneratedColumn<String> providerType = GeneratedColumn<String>(
    'provider_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetPathMeta = const VerificationMeta(
    'targetPath',
  );
  @override
  late final GeneratedColumn<String> targetPath = GeneratedColumn<String>(
    'target_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    configId,
    providerType,
    targetPath,
    createdAt,
    status,
    checksum,
    metadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('config_id')) {
      context.handle(
        _configIdMeta,
        configId.isAcceptableOrUnknown(data['config_id']!, _configIdMeta),
      );
    } else if (isInserting) {
      context.missing(_configIdMeta);
    }
    if (data.containsKey('provider_type')) {
      context.handle(
        _providerTypeMeta,
        providerType.isAcceptableOrUnknown(
          data['provider_type']!,
          _providerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerTypeMeta);
    }
    if (data.containsKey('target_path')) {
      context.handle(
        _targetPathMeta,
        targetPath.isAcceptableOrUnknown(data['target_path']!, _targetPathMeta),
      );
    } else if (isInserting) {
      context.missing(_targetPathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      configId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}config_id'],
      )!,
      providerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_type'],
      )!,
      targetPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
    );
  }

  @override
  $BackupRecordsTable createAlias(String alias) {
    return $BackupRecordsTable(attachedDatabase, alias);
  }
}

class BackupRecord extends DataClass implements Insertable<BackupRecord> {
  /// 主键ID
  final int id;

  /// 关联的备份配置ID
  /// 配置删除时级联删除历史记录
  final int configId;

  /// 提供者类型：webdav, s3
  final String providerType;

  /// 目标路径
  final String targetPath;

  /// 创建时间
  final DateTime createdAt;

  /// 状态：pending, completed, failed
  final String status;

  /// SHA256 校验和
  final String? checksum;

  /// 元数据 JSON
  final String? metadataJson;
  const BackupRecord({
    required this.id,
    required this.configId,
    required this.providerType,
    required this.targetPath,
    required this.createdAt,
    required this.status,
    this.checksum,
    this.metadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['config_id'] = Variable<int>(configId);
    map['provider_type'] = Variable<String>(providerType);
    map['target_path'] = Variable<String>(targetPath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    return map;
  }

  BackupRecordsCompanion toCompanion(bool nullToAbsent) {
    return BackupRecordsCompanion(
      id: Value(id),
      configId: Value(configId),
      providerType: Value(providerType),
      targetPath: Value(targetPath),
      createdAt: Value(createdAt),
      status: Value(status),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
    );
  }

  factory BackupRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupRecord(
      id: serializer.fromJson<int>(json['id']),
      configId: serializer.fromJson<int>(json['configId']),
      providerType: serializer.fromJson<String>(json['providerType']),
      targetPath: serializer.fromJson<String>(json['targetPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'configId': serializer.toJson<int>(configId),
      'providerType': serializer.toJson<String>(providerType),
      'targetPath': serializer.toJson<String>(targetPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
      'checksum': serializer.toJson<String?>(checksum),
      'metadataJson': serializer.toJson<String?>(metadataJson),
    };
  }

  BackupRecord copyWith({
    int? id,
    int? configId,
    String? providerType,
    String? targetPath,
    DateTime? createdAt,
    String? status,
    Value<String?> checksum = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
  }) => BackupRecord(
    id: id ?? this.id,
    configId: configId ?? this.configId,
    providerType: providerType ?? this.providerType,
    targetPath: targetPath ?? this.targetPath,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    checksum: checksum.present ? checksum.value : this.checksum,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
  );
  BackupRecord copyWithCompanion(BackupRecordsCompanion data) {
    return BackupRecord(
      id: data.id.present ? data.id.value : this.id,
      configId: data.configId.present ? data.configId.value : this.configId,
      providerType: data.providerType.present
          ? data.providerType.value
          : this.providerType,
      targetPath: data.targetPath.present
          ? data.targetPath.value
          : this.targetPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupRecord(')
          ..write('id: $id, ')
          ..write('configId: $configId, ')
          ..write('providerType: $providerType, ')
          ..write('targetPath: $targetPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('checksum: $checksum, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    configId,
    providerType,
    targetPath,
    createdAt,
    status,
    checksum,
    metadataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupRecord &&
          other.id == this.id &&
          other.configId == this.configId &&
          other.providerType == this.providerType &&
          other.targetPath == this.targetPath &&
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.checksum == this.checksum &&
          other.metadataJson == this.metadataJson);
}

class BackupRecordsCompanion extends UpdateCompanion<BackupRecord> {
  final Value<int> id;
  final Value<int> configId;
  final Value<String> providerType;
  final Value<String> targetPath;
  final Value<DateTime> createdAt;
  final Value<String> status;
  final Value<String?> checksum;
  final Value<String?> metadataJson;
  const BackupRecordsCompanion({
    this.id = const Value.absent(),
    this.configId = const Value.absent(),
    this.providerType = const Value.absent(),
    this.targetPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.checksum = const Value.absent(),
    this.metadataJson = const Value.absent(),
  });
  BackupRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int configId,
    required String providerType,
    required String targetPath,
    this.createdAt = const Value.absent(),
    required String status,
    this.checksum = const Value.absent(),
    this.metadataJson = const Value.absent(),
  }) : configId = Value(configId),
       providerType = Value(providerType),
       targetPath = Value(targetPath),
       status = Value(status);
  static Insertable<BackupRecord> custom({
    Expression<int>? id,
    Expression<int>? configId,
    Expression<String>? providerType,
    Expression<String>? targetPath,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
    Expression<String>? checksum,
    Expression<String>? metadataJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (configId != null) 'config_id': configId,
      if (providerType != null) 'provider_type': providerType,
      if (targetPath != null) 'target_path': targetPath,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (checksum != null) 'checksum': checksum,
      if (metadataJson != null) 'metadata_json': metadataJson,
    });
  }

  BackupRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? configId,
    Value<String>? providerType,
    Value<String>? targetPath,
    Value<DateTime>? createdAt,
    Value<String>? status,
    Value<String?>? checksum,
    Value<String?>? metadataJson,
  }) {
    return BackupRecordsCompanion(
      id: id ?? this.id,
      configId: configId ?? this.configId,
      providerType: providerType ?? this.providerType,
      targetPath: targetPath ?? this.targetPath,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      checksum: checksum ?? this.checksum,
      metadataJson: metadataJson ?? this.metadataJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (configId.present) {
      map['config_id'] = Variable<int>(configId.value);
    }
    if (providerType.present) {
      map['provider_type'] = Variable<String>(providerType.value);
    }
    if (targetPath.present) {
      map['target_path'] = Variable<String>(targetPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupRecordsCompanion(')
          ..write('id: $id, ')
          ..write('configId: $configId, ')
          ..write('providerType: $providerType, ')
          ..write('targetPath: $targetPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('checksum: $checksum, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }
}

class $RunningEntriesTable extends RunningEntries
    with TableInfo<$RunningEntriesTable, RunningEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunningEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES training_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _runTypeMeta = const VerificationMeta(
    'runType',
  );
  @override
  late final GeneratedColumn<String> runType = GeneratedColumn<String>(
    'run_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgPaceSecondsMeta = const VerificationMeta(
    'avgPaceSeconds',
  );
  @override
  late final GeneratedColumn<int> avgPaceSeconds = GeneratedColumn<int>(
    'avg_pace_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestPaceSecondsMeta = const VerificationMeta(
    'bestPaceSeconds',
  );
  @override
  late final GeneratedColumn<int> bestPaceSeconds = GeneratedColumn<int>(
    'best_pace_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
    'avg_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHeartRateMeta = const VerificationMeta(
    'maxHeartRate',
  );
  @override
  late final GeneratedColumn<int> maxHeartRate = GeneratedColumn<int>(
    'max_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgCadenceMeta = const VerificationMeta(
    'avgCadence',
  );
  @override
  late final GeneratedColumn<int> avgCadence = GeneratedColumn<int>(
    'avg_cadence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxCadenceMeta = const VerificationMeta(
    'maxCadence',
  );
  @override
  late final GeneratedColumn<int> maxCadence = GeneratedColumn<int>(
    'max_cadence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationGainMeta = const VerificationMeta(
    'elevationGain',
  );
  @override
  late final GeneratedColumn<double> elevationGain = GeneratedColumn<double>(
    'elevation_gain',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationLossMeta = const VerificationMeta(
    'elevationLoss',
  );
  @override
  late final GeneratedColumn<double> elevationLoss = GeneratedColumn<double>(
    'elevation_loss',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _footwearMeta = const VerificationMeta(
    'footwear',
  );
  @override
  late final GeneratedColumn<String> footwear = GeneratedColumn<String>(
    'footwear',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherJsonMeta = const VerificationMeta(
    'weatherJson',
  );
  @override
  late final GeneratedColumn<String> weatherJson = GeneratedColumn<String>(
    'weather_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    runType,
    distanceMeters,
    durationSeconds,
    avgPaceSeconds,
    bestPaceSeconds,
    avgHeartRate,
    maxHeartRate,
    avgCadence,
    maxCadence,
    elevationGain,
    elevationLoss,
    footwear,
    weatherJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'running_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunningEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('run_type')) {
      context.handle(
        _runTypeMeta,
        runType.isAcceptableOrUnknown(data['run_type']!, _runTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_runTypeMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('avg_pace_seconds')) {
      context.handle(
        _avgPaceSecondsMeta,
        avgPaceSeconds.isAcceptableOrUnknown(
          data['avg_pace_seconds']!,
          _avgPaceSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgPaceSecondsMeta);
    }
    if (data.containsKey('best_pace_seconds')) {
      context.handle(
        _bestPaceSecondsMeta,
        bestPaceSeconds.isAcceptableOrUnknown(
          data['best_pace_seconds']!,
          _bestPaceSecondsMeta,
        ),
      );
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avg_heart_rate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('max_heart_rate')) {
      context.handle(
        _maxHeartRateMeta,
        maxHeartRate.isAcceptableOrUnknown(
          data['max_heart_rate']!,
          _maxHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('avg_cadence')) {
      context.handle(
        _avgCadenceMeta,
        avgCadence.isAcceptableOrUnknown(data['avg_cadence']!, _avgCadenceMeta),
      );
    }
    if (data.containsKey('max_cadence')) {
      context.handle(
        _maxCadenceMeta,
        maxCadence.isAcceptableOrUnknown(data['max_cadence']!, _maxCadenceMeta),
      );
    }
    if (data.containsKey('elevation_gain')) {
      context.handle(
        _elevationGainMeta,
        elevationGain.isAcceptableOrUnknown(
          data['elevation_gain']!,
          _elevationGainMeta,
        ),
      );
    }
    if (data.containsKey('elevation_loss')) {
      context.handle(
        _elevationLossMeta,
        elevationLoss.isAcceptableOrUnknown(
          data['elevation_loss']!,
          _elevationLossMeta,
        ),
      );
    }
    if (data.containsKey('footwear')) {
      context.handle(
        _footwearMeta,
        footwear.isAcceptableOrUnknown(data['footwear']!, _footwearMeta),
      );
    }
    if (data.containsKey('weather_json')) {
      context.handle(
        _weatherJsonMeta,
        weatherJson.isAcceptableOrUnknown(
          data['weather_json']!,
          _weatherJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunningEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunningEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      runType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_type'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      avgPaceSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_pace_seconds'],
      )!,
      bestPaceSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_pace_seconds'],
      ),
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_heart_rate'],
      ),
      maxHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_heart_rate'],
      ),
      avgCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_cadence'],
      ),
      maxCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_cadence'],
      ),
      elevationGain: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain'],
      ),
      elevationLoss: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_loss'],
      ),
      footwear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}footwear'],
      ),
      weatherJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_json'],
      ),
    );
  }

  @override
  $RunningEntriesTable createAlias(String alias) {
    return $RunningEntriesTable(attachedDatabase, alias);
  }
}

class RunningEntry extends DataClass implements Insertable<RunningEntry> {
  /// 主键ID
  final int id;

  /// 关联的训练会话ID
  /// 会话删除时级联删除跑步明细
  final int sessionId;

  /// 跑步类型：easy(轻松跑), tempo(节奏跑), interval(间歇跑), lsd(长距离慢跑), recovery(恢复跑), race(比赛)
  final String runType;

  /// 总距离（米）
  final double distanceMeters;

  /// 总时长（秒）
  final int durationSeconds;

  /// 平均配速（秒/公里）
  final int avgPaceSeconds;

  /// 最快配速（秒/公里）
  final int? bestPaceSeconds;

  /// 平均心率（可选）
  final int? avgHeartRate;

  /// 最大心率（可选）
  final int? maxHeartRate;

  /// 平均步频（可选）
  final int? avgCadence;

  /// 最大步频（可选）
  final int? maxCadence;

  /// 总爬升（米，可选）
  final double? elevationGain;

  /// 总下降（米，可选）
  final double? elevationLoss;

  /// 跑鞋/装备（可选）
  final String? footwear;

  /// 天气数据JSON（可选）
  final String? weatherJson;
  const RunningEntry({
    required this.id,
    required this.sessionId,
    required this.runType,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.avgPaceSeconds,
    this.bestPaceSeconds,
    this.avgHeartRate,
    this.maxHeartRate,
    this.avgCadence,
    this.maxCadence,
    this.elevationGain,
    this.elevationLoss,
    this.footwear,
    this.weatherJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['run_type'] = Variable<String>(runType);
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['avg_pace_seconds'] = Variable<int>(avgPaceSeconds);
    if (!nullToAbsent || bestPaceSeconds != null) {
      map['best_pace_seconds'] = Variable<int>(bestPaceSeconds);
    }
    if (!nullToAbsent || avgHeartRate != null) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate);
    }
    if (!nullToAbsent || maxHeartRate != null) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate);
    }
    if (!nullToAbsent || avgCadence != null) {
      map['avg_cadence'] = Variable<int>(avgCadence);
    }
    if (!nullToAbsent || maxCadence != null) {
      map['max_cadence'] = Variable<int>(maxCadence);
    }
    if (!nullToAbsent || elevationGain != null) {
      map['elevation_gain'] = Variable<double>(elevationGain);
    }
    if (!nullToAbsent || elevationLoss != null) {
      map['elevation_loss'] = Variable<double>(elevationLoss);
    }
    if (!nullToAbsent || footwear != null) {
      map['footwear'] = Variable<String>(footwear);
    }
    if (!nullToAbsent || weatherJson != null) {
      map['weather_json'] = Variable<String>(weatherJson);
    }
    return map;
  }

  RunningEntriesCompanion toCompanion(bool nullToAbsent) {
    return RunningEntriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      runType: Value(runType),
      distanceMeters: Value(distanceMeters),
      durationSeconds: Value(durationSeconds),
      avgPaceSeconds: Value(avgPaceSeconds),
      bestPaceSeconds: bestPaceSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(bestPaceSeconds),
      avgHeartRate: avgHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHeartRate),
      maxHeartRate: maxHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHeartRate),
      avgCadence: avgCadence == null && nullToAbsent
          ? const Value.absent()
          : Value(avgCadence),
      maxCadence: maxCadence == null && nullToAbsent
          ? const Value.absent()
          : Value(maxCadence),
      elevationGain: elevationGain == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGain),
      elevationLoss: elevationLoss == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationLoss),
      footwear: footwear == null && nullToAbsent
          ? const Value.absent()
          : Value(footwear),
      weatherJson: weatherJson == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherJson),
    );
  }

  factory RunningEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunningEntry(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      runType: serializer.fromJson<String>(json['runType']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      avgPaceSeconds: serializer.fromJson<int>(json['avgPaceSeconds']),
      bestPaceSeconds: serializer.fromJson<int?>(json['bestPaceSeconds']),
      avgHeartRate: serializer.fromJson<int?>(json['avgHeartRate']),
      maxHeartRate: serializer.fromJson<int?>(json['maxHeartRate']),
      avgCadence: serializer.fromJson<int?>(json['avgCadence']),
      maxCadence: serializer.fromJson<int?>(json['maxCadence']),
      elevationGain: serializer.fromJson<double?>(json['elevationGain']),
      elevationLoss: serializer.fromJson<double?>(json['elevationLoss']),
      footwear: serializer.fromJson<String?>(json['footwear']),
      weatherJson: serializer.fromJson<String?>(json['weatherJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'runType': serializer.toJson<String>(runType),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'avgPaceSeconds': serializer.toJson<int>(avgPaceSeconds),
      'bestPaceSeconds': serializer.toJson<int?>(bestPaceSeconds),
      'avgHeartRate': serializer.toJson<int?>(avgHeartRate),
      'maxHeartRate': serializer.toJson<int?>(maxHeartRate),
      'avgCadence': serializer.toJson<int?>(avgCadence),
      'maxCadence': serializer.toJson<int?>(maxCadence),
      'elevationGain': serializer.toJson<double?>(elevationGain),
      'elevationLoss': serializer.toJson<double?>(elevationLoss),
      'footwear': serializer.toJson<String?>(footwear),
      'weatherJson': serializer.toJson<String?>(weatherJson),
    };
  }

  RunningEntry copyWith({
    int? id,
    int? sessionId,
    String? runType,
    double? distanceMeters,
    int? durationSeconds,
    int? avgPaceSeconds,
    Value<int?> bestPaceSeconds = const Value.absent(),
    Value<int?> avgHeartRate = const Value.absent(),
    Value<int?> maxHeartRate = const Value.absent(),
    Value<int?> avgCadence = const Value.absent(),
    Value<int?> maxCadence = const Value.absent(),
    Value<double?> elevationGain = const Value.absent(),
    Value<double?> elevationLoss = const Value.absent(),
    Value<String?> footwear = const Value.absent(),
    Value<String?> weatherJson = const Value.absent(),
  }) => RunningEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    runType: runType ?? this.runType,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    avgPaceSeconds: avgPaceSeconds ?? this.avgPaceSeconds,
    bestPaceSeconds: bestPaceSeconds.present
        ? bestPaceSeconds.value
        : this.bestPaceSeconds,
    avgHeartRate: avgHeartRate.present ? avgHeartRate.value : this.avgHeartRate,
    maxHeartRate: maxHeartRate.present ? maxHeartRate.value : this.maxHeartRate,
    avgCadence: avgCadence.present ? avgCadence.value : this.avgCadence,
    maxCadence: maxCadence.present ? maxCadence.value : this.maxCadence,
    elevationGain: elevationGain.present
        ? elevationGain.value
        : this.elevationGain,
    elevationLoss: elevationLoss.present
        ? elevationLoss.value
        : this.elevationLoss,
    footwear: footwear.present ? footwear.value : this.footwear,
    weatherJson: weatherJson.present ? weatherJson.value : this.weatherJson,
  );
  RunningEntry copyWithCompanion(RunningEntriesCompanion data) {
    return RunningEntry(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      runType: data.runType.present ? data.runType.value : this.runType,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      avgPaceSeconds: data.avgPaceSeconds.present
          ? data.avgPaceSeconds.value
          : this.avgPaceSeconds,
      bestPaceSeconds: data.bestPaceSeconds.present
          ? data.bestPaceSeconds.value
          : this.bestPaceSeconds,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      maxHeartRate: data.maxHeartRate.present
          ? data.maxHeartRate.value
          : this.maxHeartRate,
      avgCadence: data.avgCadence.present
          ? data.avgCadence.value
          : this.avgCadence,
      maxCadence: data.maxCadence.present
          ? data.maxCadence.value
          : this.maxCadence,
      elevationGain: data.elevationGain.present
          ? data.elevationGain.value
          : this.elevationGain,
      elevationLoss: data.elevationLoss.present
          ? data.elevationLoss.value
          : this.elevationLoss,
      footwear: data.footwear.present ? data.footwear.value : this.footwear,
      weatherJson: data.weatherJson.present
          ? data.weatherJson.value
          : this.weatherJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunningEntry(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('runType: $runType, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('avgPaceSeconds: $avgPaceSeconds, ')
          ..write('bestPaceSeconds: $bestPaceSeconds, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('maxCadence: $maxCadence, ')
          ..write('elevationGain: $elevationGain, ')
          ..write('elevationLoss: $elevationLoss, ')
          ..write('footwear: $footwear, ')
          ..write('weatherJson: $weatherJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    runType,
    distanceMeters,
    durationSeconds,
    avgPaceSeconds,
    bestPaceSeconds,
    avgHeartRate,
    maxHeartRate,
    avgCadence,
    maxCadence,
    elevationGain,
    elevationLoss,
    footwear,
    weatherJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunningEntry &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.runType == this.runType &&
          other.distanceMeters == this.distanceMeters &&
          other.durationSeconds == this.durationSeconds &&
          other.avgPaceSeconds == this.avgPaceSeconds &&
          other.bestPaceSeconds == this.bestPaceSeconds &&
          other.avgHeartRate == this.avgHeartRate &&
          other.maxHeartRate == this.maxHeartRate &&
          other.avgCadence == this.avgCadence &&
          other.maxCadence == this.maxCadence &&
          other.elevationGain == this.elevationGain &&
          other.elevationLoss == this.elevationLoss &&
          other.footwear == this.footwear &&
          other.weatherJson == this.weatherJson);
}

class RunningEntriesCompanion extends UpdateCompanion<RunningEntry> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> runType;
  final Value<double> distanceMeters;
  final Value<int> durationSeconds;
  final Value<int> avgPaceSeconds;
  final Value<int?> bestPaceSeconds;
  final Value<int?> avgHeartRate;
  final Value<int?> maxHeartRate;
  final Value<int?> avgCadence;
  final Value<int?> maxCadence;
  final Value<double?> elevationGain;
  final Value<double?> elevationLoss;
  final Value<String?> footwear;
  final Value<String?> weatherJson;
  const RunningEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.runType = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.avgPaceSeconds = const Value.absent(),
    this.bestPaceSeconds = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.maxCadence = const Value.absent(),
    this.elevationGain = const Value.absent(),
    this.elevationLoss = const Value.absent(),
    this.footwear = const Value.absent(),
    this.weatherJson = const Value.absent(),
  });
  RunningEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String runType,
    required double distanceMeters,
    required int durationSeconds,
    required int avgPaceSeconds,
    this.bestPaceSeconds = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.maxCadence = const Value.absent(),
    this.elevationGain = const Value.absent(),
    this.elevationLoss = const Value.absent(),
    this.footwear = const Value.absent(),
    this.weatherJson = const Value.absent(),
  }) : sessionId = Value(sessionId),
       runType = Value(runType),
       distanceMeters = Value(distanceMeters),
       durationSeconds = Value(durationSeconds),
       avgPaceSeconds = Value(avgPaceSeconds);
  static Insertable<RunningEntry> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? runType,
    Expression<double>? distanceMeters,
    Expression<int>? durationSeconds,
    Expression<int>? avgPaceSeconds,
    Expression<int>? bestPaceSeconds,
    Expression<int>? avgHeartRate,
    Expression<int>? maxHeartRate,
    Expression<int>? avgCadence,
    Expression<int>? maxCadence,
    Expression<double>? elevationGain,
    Expression<double>? elevationLoss,
    Expression<String>? footwear,
    Expression<String>? weatherJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (runType != null) 'run_type': runType,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (avgPaceSeconds != null) 'avg_pace_seconds': avgPaceSeconds,
      if (bestPaceSeconds != null) 'best_pace_seconds': bestPaceSeconds,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (maxHeartRate != null) 'max_heart_rate': maxHeartRate,
      if (avgCadence != null) 'avg_cadence': avgCadence,
      if (maxCadence != null) 'max_cadence': maxCadence,
      if (elevationGain != null) 'elevation_gain': elevationGain,
      if (elevationLoss != null) 'elevation_loss': elevationLoss,
      if (footwear != null) 'footwear': footwear,
      if (weatherJson != null) 'weather_json': weatherJson,
    });
  }

  RunningEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? runType,
    Value<double>? distanceMeters,
    Value<int>? durationSeconds,
    Value<int>? avgPaceSeconds,
    Value<int?>? bestPaceSeconds,
    Value<int?>? avgHeartRate,
    Value<int?>? maxHeartRate,
    Value<int?>? avgCadence,
    Value<int?>? maxCadence,
    Value<double?>? elevationGain,
    Value<double?>? elevationLoss,
    Value<String?>? footwear,
    Value<String?>? weatherJson,
  }) {
    return RunningEntriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      runType: runType ?? this.runType,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      avgPaceSeconds: avgPaceSeconds ?? this.avgPaceSeconds,
      bestPaceSeconds: bestPaceSeconds ?? this.bestPaceSeconds,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      avgCadence: avgCadence ?? this.avgCadence,
      maxCadence: maxCadence ?? this.maxCadence,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      footwear: footwear ?? this.footwear,
      weatherJson: weatherJson ?? this.weatherJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (runType.present) {
      map['run_type'] = Variable<String>(runType.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (avgPaceSeconds.present) {
      map['avg_pace_seconds'] = Variable<int>(avgPaceSeconds.value);
    }
    if (bestPaceSeconds.present) {
      map['best_pace_seconds'] = Variable<int>(bestPaceSeconds.value);
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate.value);
    }
    if (maxHeartRate.present) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate.value);
    }
    if (avgCadence.present) {
      map['avg_cadence'] = Variable<int>(avgCadence.value);
    }
    if (maxCadence.present) {
      map['max_cadence'] = Variable<int>(maxCadence.value);
    }
    if (elevationGain.present) {
      map['elevation_gain'] = Variable<double>(elevationGain.value);
    }
    if (elevationLoss.present) {
      map['elevation_loss'] = Variable<double>(elevationLoss.value);
    }
    if (footwear.present) {
      map['footwear'] = Variable<String>(footwear.value);
    }
    if (weatherJson.present) {
      map['weather_json'] = Variable<String>(weatherJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunningEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('runType: $runType, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('avgPaceSeconds: $avgPaceSeconds, ')
          ..write('bestPaceSeconds: $bestPaceSeconds, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('maxCadence: $maxCadence, ')
          ..write('elevationGain: $elevationGain, ')
          ..write('elevationLoss: $elevationLoss, ')
          ..write('footwear: $footwear, ')
          ..write('weatherJson: $weatherJson')
          ..write(')'))
        .toString();
  }
}

class $RunningSplitsTable extends RunningSplits
    with TableInfo<$RunningSplitsTable, RunningSplit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunningSplitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _runningEntryIdMeta = const VerificationMeta(
    'runningEntryId',
  );
  @override
  late final GeneratedColumn<int> runningEntryId = GeneratedColumn<int>(
    'running_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES running_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _splitNumberMeta = const VerificationMeta(
    'splitNumber',
  );
  @override
  late final GeneratedColumn<int> splitNumber = GeneratedColumn<int>(
    'split_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paceSecondsMeta = const VerificationMeta(
    'paceSeconds',
  );
  @override
  late final GeneratedColumn<int> paceSeconds = GeneratedColumn<int>(
    'pace_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
    'avg_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cadenceMeta = const VerificationMeta(
    'cadence',
  );
  @override
  late final GeneratedColumn<int> cadence = GeneratedColumn<int>(
    'cadence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationGainMeta = const VerificationMeta(
    'elevationGain',
  );
  @override
  late final GeneratedColumn<double> elevationGain = GeneratedColumn<double>(
    'elevation_gain',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isManualMeta = const VerificationMeta(
    'isManual',
  );
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
    'is_manual',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_manual" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runningEntryId,
    splitNumber,
    distanceMeters,
    durationSeconds,
    paceSeconds,
    avgHeartRate,
    cadence,
    elevationGain,
    isManual,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'running_splits';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunningSplit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('running_entry_id')) {
      context.handle(
        _runningEntryIdMeta,
        runningEntryId.isAcceptableOrUnknown(
          data['running_entry_id']!,
          _runningEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_runningEntryIdMeta);
    }
    if (data.containsKey('split_number')) {
      context.handle(
        _splitNumberMeta,
        splitNumber.isAcceptableOrUnknown(
          data['split_number']!,
          _splitNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_splitNumberMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('pace_seconds')) {
      context.handle(
        _paceSecondsMeta,
        paceSeconds.isAcceptableOrUnknown(
          data['pace_seconds']!,
          _paceSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paceSecondsMeta);
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avg_heart_rate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('cadence')) {
      context.handle(
        _cadenceMeta,
        cadence.isAcceptableOrUnknown(data['cadence']!, _cadenceMeta),
      );
    }
    if (data.containsKey('elevation_gain')) {
      context.handle(
        _elevationGainMeta,
        elevationGain.isAcceptableOrUnknown(
          data['elevation_gain']!,
          _elevationGainMeta,
        ),
      );
    }
    if (data.containsKey('is_manual')) {
      context.handle(
        _isManualMeta,
        isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunningSplit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunningSplit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      runningEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}running_entry_id'],
      )!,
      splitNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}split_number'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      paceSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pace_seconds'],
      )!,
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_heart_rate'],
      ),
      cadence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cadence'],
      ),
      elevationGain: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain'],
      ),
      isManual: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_manual'],
      )!,
    );
  }

  @override
  $RunningSplitsTable createAlias(String alias) {
    return $RunningSplitsTable(attachedDatabase, alias);
  }
}

class RunningSplit extends DataClass implements Insertable<RunningSplit> {
  /// 主键ID
  final int id;

  /// 关联的跑步记录ID
  /// 跑步记录删除时级联删除
  final int runningEntryId;

  /// 分段序号
  final int splitNumber;

  /// 分段距离（米）
  final double distanceMeters;

  /// 分段时长（秒）
  final int durationSeconds;

  /// 分段配速（秒/公里）
  final int paceSeconds;

  /// 该段平均心率（可选）
  final int? avgHeartRate;

  /// 该段步频（可选）
  final int? cadence;

  /// 该段爬升（米，可选）
  final double? elevationGain;

  /// 是否为手动标记
  final bool isManual;
  const RunningSplit({
    required this.id,
    required this.runningEntryId,
    required this.splitNumber,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.paceSeconds,
    this.avgHeartRate,
    this.cadence,
    this.elevationGain,
    required this.isManual,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['running_entry_id'] = Variable<int>(runningEntryId);
    map['split_number'] = Variable<int>(splitNumber);
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['pace_seconds'] = Variable<int>(paceSeconds);
    if (!nullToAbsent || avgHeartRate != null) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate);
    }
    if (!nullToAbsent || cadence != null) {
      map['cadence'] = Variable<int>(cadence);
    }
    if (!nullToAbsent || elevationGain != null) {
      map['elevation_gain'] = Variable<double>(elevationGain);
    }
    map['is_manual'] = Variable<bool>(isManual);
    return map;
  }

  RunningSplitsCompanion toCompanion(bool nullToAbsent) {
    return RunningSplitsCompanion(
      id: Value(id),
      runningEntryId: Value(runningEntryId),
      splitNumber: Value(splitNumber),
      distanceMeters: Value(distanceMeters),
      durationSeconds: Value(durationSeconds),
      paceSeconds: Value(paceSeconds),
      avgHeartRate: avgHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHeartRate),
      cadence: cadence == null && nullToAbsent
          ? const Value.absent()
          : Value(cadence),
      elevationGain: elevationGain == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGain),
      isManual: Value(isManual),
    );
  }

  factory RunningSplit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunningSplit(
      id: serializer.fromJson<int>(json['id']),
      runningEntryId: serializer.fromJson<int>(json['runningEntryId']),
      splitNumber: serializer.fromJson<int>(json['splitNumber']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      paceSeconds: serializer.fromJson<int>(json['paceSeconds']),
      avgHeartRate: serializer.fromJson<int?>(json['avgHeartRate']),
      cadence: serializer.fromJson<int?>(json['cadence']),
      elevationGain: serializer.fromJson<double?>(json['elevationGain']),
      isManual: serializer.fromJson<bool>(json['isManual']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runningEntryId': serializer.toJson<int>(runningEntryId),
      'splitNumber': serializer.toJson<int>(splitNumber),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'paceSeconds': serializer.toJson<int>(paceSeconds),
      'avgHeartRate': serializer.toJson<int?>(avgHeartRate),
      'cadence': serializer.toJson<int?>(cadence),
      'elevationGain': serializer.toJson<double?>(elevationGain),
      'isManual': serializer.toJson<bool>(isManual),
    };
  }

  RunningSplit copyWith({
    int? id,
    int? runningEntryId,
    int? splitNumber,
    double? distanceMeters,
    int? durationSeconds,
    int? paceSeconds,
    Value<int?> avgHeartRate = const Value.absent(),
    Value<int?> cadence = const Value.absent(),
    Value<double?> elevationGain = const Value.absent(),
    bool? isManual,
  }) => RunningSplit(
    id: id ?? this.id,
    runningEntryId: runningEntryId ?? this.runningEntryId,
    splitNumber: splitNumber ?? this.splitNumber,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    paceSeconds: paceSeconds ?? this.paceSeconds,
    avgHeartRate: avgHeartRate.present ? avgHeartRate.value : this.avgHeartRate,
    cadence: cadence.present ? cadence.value : this.cadence,
    elevationGain: elevationGain.present
        ? elevationGain.value
        : this.elevationGain,
    isManual: isManual ?? this.isManual,
  );
  RunningSplit copyWithCompanion(RunningSplitsCompanion data) {
    return RunningSplit(
      id: data.id.present ? data.id.value : this.id,
      runningEntryId: data.runningEntryId.present
          ? data.runningEntryId.value
          : this.runningEntryId,
      splitNumber: data.splitNumber.present
          ? data.splitNumber.value
          : this.splitNumber,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      paceSeconds: data.paceSeconds.present
          ? data.paceSeconds.value
          : this.paceSeconds,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      cadence: data.cadence.present ? data.cadence.value : this.cadence,
      elevationGain: data.elevationGain.present
          ? data.elevationGain.value
          : this.elevationGain,
      isManual: data.isManual.present ? data.isManual.value : this.isManual,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunningSplit(')
          ..write('id: $id, ')
          ..write('runningEntryId: $runningEntryId, ')
          ..write('splitNumber: $splitNumber, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('paceSeconds: $paceSeconds, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('cadence: $cadence, ')
          ..write('elevationGain: $elevationGain, ')
          ..write('isManual: $isManual')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    runningEntryId,
    splitNumber,
    distanceMeters,
    durationSeconds,
    paceSeconds,
    avgHeartRate,
    cadence,
    elevationGain,
    isManual,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunningSplit &&
          other.id == this.id &&
          other.runningEntryId == this.runningEntryId &&
          other.splitNumber == this.splitNumber &&
          other.distanceMeters == this.distanceMeters &&
          other.durationSeconds == this.durationSeconds &&
          other.paceSeconds == this.paceSeconds &&
          other.avgHeartRate == this.avgHeartRate &&
          other.cadence == this.cadence &&
          other.elevationGain == this.elevationGain &&
          other.isManual == this.isManual);
}

class RunningSplitsCompanion extends UpdateCompanion<RunningSplit> {
  final Value<int> id;
  final Value<int> runningEntryId;
  final Value<int> splitNumber;
  final Value<double> distanceMeters;
  final Value<int> durationSeconds;
  final Value<int> paceSeconds;
  final Value<int?> avgHeartRate;
  final Value<int?> cadence;
  final Value<double?> elevationGain;
  final Value<bool> isManual;
  const RunningSplitsCompanion({
    this.id = const Value.absent(),
    this.runningEntryId = const Value.absent(),
    this.splitNumber = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.paceSeconds = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.cadence = const Value.absent(),
    this.elevationGain = const Value.absent(),
    this.isManual = const Value.absent(),
  });
  RunningSplitsCompanion.insert({
    this.id = const Value.absent(),
    required int runningEntryId,
    required int splitNumber,
    required double distanceMeters,
    required int durationSeconds,
    required int paceSeconds,
    this.avgHeartRate = const Value.absent(),
    this.cadence = const Value.absent(),
    this.elevationGain = const Value.absent(),
    this.isManual = const Value.absent(),
  }) : runningEntryId = Value(runningEntryId),
       splitNumber = Value(splitNumber),
       distanceMeters = Value(distanceMeters),
       durationSeconds = Value(durationSeconds),
       paceSeconds = Value(paceSeconds);
  static Insertable<RunningSplit> custom({
    Expression<int>? id,
    Expression<int>? runningEntryId,
    Expression<int>? splitNumber,
    Expression<double>? distanceMeters,
    Expression<int>? durationSeconds,
    Expression<int>? paceSeconds,
    Expression<int>? avgHeartRate,
    Expression<int>? cadence,
    Expression<double>? elevationGain,
    Expression<bool>? isManual,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runningEntryId != null) 'running_entry_id': runningEntryId,
      if (splitNumber != null) 'split_number': splitNumber,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (paceSeconds != null) 'pace_seconds': paceSeconds,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (cadence != null) 'cadence': cadence,
      if (elevationGain != null) 'elevation_gain': elevationGain,
      if (isManual != null) 'is_manual': isManual,
    });
  }

  RunningSplitsCompanion copyWith({
    Value<int>? id,
    Value<int>? runningEntryId,
    Value<int>? splitNumber,
    Value<double>? distanceMeters,
    Value<int>? durationSeconds,
    Value<int>? paceSeconds,
    Value<int?>? avgHeartRate,
    Value<int?>? cadence,
    Value<double?>? elevationGain,
    Value<bool>? isManual,
  }) {
    return RunningSplitsCompanion(
      id: id ?? this.id,
      runningEntryId: runningEntryId ?? this.runningEntryId,
      splitNumber: splitNumber ?? this.splitNumber,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      paceSeconds: paceSeconds ?? this.paceSeconds,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      cadence: cadence ?? this.cadence,
      elevationGain: elevationGain ?? this.elevationGain,
      isManual: isManual ?? this.isManual,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runningEntryId.present) {
      map['running_entry_id'] = Variable<int>(runningEntryId.value);
    }
    if (splitNumber.present) {
      map['split_number'] = Variable<int>(splitNumber.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (paceSeconds.present) {
      map['pace_seconds'] = Variable<int>(paceSeconds.value);
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate.value);
    }
    if (cadence.present) {
      map['cadence'] = Variable<int>(cadence.value);
    }
    if (elevationGain.present) {
      map['elevation_gain'] = Variable<double>(elevationGain.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunningSplitsCompanion(')
          ..write('id: $id, ')
          ..write('runningEntryId: $runningEntryId, ')
          ..write('splitNumber: $splitNumber, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('paceSeconds: $paceSeconds, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('cadence: $cadence, ')
          ..write('elevationGain: $elevationGain, ')
          ..write('isManual: $isManual')
          ..write(')'))
        .toString();
  }
}

class $SwimmingEntriesTable extends SwimmingEntries
    with TableInfo<$SwimmingEntriesTable, SwimmingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SwimmingEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES training_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _environmentMeta = const VerificationMeta(
    'environment',
  );
  @override
  late final GeneratedColumn<String> environment = GeneratedColumn<String>(
    'environment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poolLengthMetersMeta = const VerificationMeta(
    'poolLengthMeters',
  );
  @override
  late final GeneratedColumn<int> poolLengthMeters = GeneratedColumn<int>(
    'pool_length_meters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryStrokeMeta = const VerificationMeta(
    'primaryStroke',
  );
  @override
  late final GeneratedColumn<String> primaryStroke = GeneratedColumn<String>(
    'primary_stroke',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pacePer100mMeta = const VerificationMeta(
    'pacePer100m',
  );
  @override
  late final GeneratedColumn<int> pacePer100m = GeneratedColumn<int>(
    'pace_per100m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trainingTypeMeta = const VerificationMeta(
    'trainingType',
  );
  @override
  late final GeneratedColumn<String> trainingType = GeneratedColumn<String>(
    'training_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    environment,
    poolLengthMeters,
    primaryStroke,
    distanceMeters,
    durationSeconds,
    pacePer100m,
    trainingType,
    equipment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'swimming_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SwimmingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('environment')) {
      context.handle(
        _environmentMeta,
        environment.isAcceptableOrUnknown(
          data['environment']!,
          _environmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_environmentMeta);
    }
    if (data.containsKey('pool_length_meters')) {
      context.handle(
        _poolLengthMetersMeta,
        poolLengthMeters.isAcceptableOrUnknown(
          data['pool_length_meters']!,
          _poolLengthMetersMeta,
        ),
      );
    }
    if (data.containsKey('primary_stroke')) {
      context.handle(
        _primaryStrokeMeta,
        primaryStroke.isAcceptableOrUnknown(
          data['primary_stroke']!,
          _primaryStrokeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryStrokeMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('pace_per100m')) {
      context.handle(
        _pacePer100mMeta,
        pacePer100m.isAcceptableOrUnknown(
          data['pace_per100m']!,
          _pacePer100mMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pacePer100mMeta);
    }
    if (data.containsKey('training_type')) {
      context.handle(
        _trainingTypeMeta,
        trainingType.isAcceptableOrUnknown(
          data['training_type']!,
          _trainingTypeMeta,
        ),
      );
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SwimmingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SwimmingEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      environment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environment'],
      )!,
      poolLengthMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pool_length_meters'],
      ),
      primaryStroke: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_stroke'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      pacePer100m: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pace_per100m'],
      )!,
      trainingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_type'],
      ),
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      ),
    );
  }

  @override
  $SwimmingEntriesTable createAlias(String alias) {
    return $SwimmingEntriesTable(attachedDatabase, alias);
  }
}

class SwimmingEntry extends DataClass implements Insertable<SwimmingEntry> {
  /// 主键ID
  final int id;

  /// 关联的训练会话ID
  /// 会话删除时级联删除游泳明细
  final int sessionId;

  /// 训练环境：pool(泳池), open_water(开放水域)
  final String environment;

  /// 泳池长度（米），开放水域可为空
  final int? poolLengthMeters;

  /// 主要泳姿：freestyle(自由泳), breaststroke(蛙泳), backstroke(仰泳), butterfly(蝶泳), mixed(混合)
  final String primaryStroke;

  /// 总距离（米）
  final double distanceMeters;

  /// 总时长（秒）
  final int durationSeconds;

  /// 每100米配速（秒）
  final int pacePer100m;

  /// 训练类型：technique(技术), endurance(耐力), speed(速度), recovery(恢复)
  final String? trainingType;

  /// 使用的装备（JSON数组）：fins(脚蹼), pull_buoy(浮板), paddles(划水掌), kickboard(打水板), snorkel(呼吸管)
  final String? equipment;
  const SwimmingEntry({
    required this.id,
    required this.sessionId,
    required this.environment,
    this.poolLengthMeters,
    required this.primaryStroke,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.pacePer100m,
    this.trainingType,
    this.equipment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['environment'] = Variable<String>(environment);
    if (!nullToAbsent || poolLengthMeters != null) {
      map['pool_length_meters'] = Variable<int>(poolLengthMeters);
    }
    map['primary_stroke'] = Variable<String>(primaryStroke);
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['pace_per100m'] = Variable<int>(pacePer100m);
    if (!nullToAbsent || trainingType != null) {
      map['training_type'] = Variable<String>(trainingType);
    }
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    return map;
  }

  SwimmingEntriesCompanion toCompanion(bool nullToAbsent) {
    return SwimmingEntriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      environment: Value(environment),
      poolLengthMeters: poolLengthMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(poolLengthMeters),
      primaryStroke: Value(primaryStroke),
      distanceMeters: Value(distanceMeters),
      durationSeconds: Value(durationSeconds),
      pacePer100m: Value(pacePer100m),
      trainingType: trainingType == null && nullToAbsent
          ? const Value.absent()
          : Value(trainingType),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
    );
  }

  factory SwimmingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SwimmingEntry(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      environment: serializer.fromJson<String>(json['environment']),
      poolLengthMeters: serializer.fromJson<int?>(json['poolLengthMeters']),
      primaryStroke: serializer.fromJson<String>(json['primaryStroke']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      pacePer100m: serializer.fromJson<int>(json['pacePer100m']),
      trainingType: serializer.fromJson<String?>(json['trainingType']),
      equipment: serializer.fromJson<String?>(json['equipment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'environment': serializer.toJson<String>(environment),
      'poolLengthMeters': serializer.toJson<int?>(poolLengthMeters),
      'primaryStroke': serializer.toJson<String>(primaryStroke),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'pacePer100m': serializer.toJson<int>(pacePer100m),
      'trainingType': serializer.toJson<String?>(trainingType),
      'equipment': serializer.toJson<String?>(equipment),
    };
  }

  SwimmingEntry copyWith({
    int? id,
    int? sessionId,
    String? environment,
    Value<int?> poolLengthMeters = const Value.absent(),
    String? primaryStroke,
    double? distanceMeters,
    int? durationSeconds,
    int? pacePer100m,
    Value<String?> trainingType = const Value.absent(),
    Value<String?> equipment = const Value.absent(),
  }) => SwimmingEntry(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    environment: environment ?? this.environment,
    poolLengthMeters: poolLengthMeters.present
        ? poolLengthMeters.value
        : this.poolLengthMeters,
    primaryStroke: primaryStroke ?? this.primaryStroke,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    pacePer100m: pacePer100m ?? this.pacePer100m,
    trainingType: trainingType.present ? trainingType.value : this.trainingType,
    equipment: equipment.present ? equipment.value : this.equipment,
  );
  SwimmingEntry copyWithCompanion(SwimmingEntriesCompanion data) {
    return SwimmingEntry(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      environment: data.environment.present
          ? data.environment.value
          : this.environment,
      poolLengthMeters: data.poolLengthMeters.present
          ? data.poolLengthMeters.value
          : this.poolLengthMeters,
      primaryStroke: data.primaryStroke.present
          ? data.primaryStroke.value
          : this.primaryStroke,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      pacePer100m: data.pacePer100m.present
          ? data.pacePer100m.value
          : this.pacePer100m,
      trainingType: data.trainingType.present
          ? data.trainingType.value
          : this.trainingType,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SwimmingEntry(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('environment: $environment, ')
          ..write('poolLengthMeters: $poolLengthMeters, ')
          ..write('primaryStroke: $primaryStroke, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pacePer100m: $pacePer100m, ')
          ..write('trainingType: $trainingType, ')
          ..write('equipment: $equipment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    environment,
    poolLengthMeters,
    primaryStroke,
    distanceMeters,
    durationSeconds,
    pacePer100m,
    trainingType,
    equipment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SwimmingEntry &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.environment == this.environment &&
          other.poolLengthMeters == this.poolLengthMeters &&
          other.primaryStroke == this.primaryStroke &&
          other.distanceMeters == this.distanceMeters &&
          other.durationSeconds == this.durationSeconds &&
          other.pacePer100m == this.pacePer100m &&
          other.trainingType == this.trainingType &&
          other.equipment == this.equipment);
}

class SwimmingEntriesCompanion extends UpdateCompanion<SwimmingEntry> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> environment;
  final Value<int?> poolLengthMeters;
  final Value<String> primaryStroke;
  final Value<double> distanceMeters;
  final Value<int> durationSeconds;
  final Value<int> pacePer100m;
  final Value<String?> trainingType;
  final Value<String?> equipment;
  const SwimmingEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.environment = const Value.absent(),
    this.poolLengthMeters = const Value.absent(),
    this.primaryStroke = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.pacePer100m = const Value.absent(),
    this.trainingType = const Value.absent(),
    this.equipment = const Value.absent(),
  });
  SwimmingEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String environment,
    this.poolLengthMeters = const Value.absent(),
    required String primaryStroke,
    required double distanceMeters,
    required int durationSeconds,
    required int pacePer100m,
    this.trainingType = const Value.absent(),
    this.equipment = const Value.absent(),
  }) : sessionId = Value(sessionId),
       environment = Value(environment),
       primaryStroke = Value(primaryStroke),
       distanceMeters = Value(distanceMeters),
       durationSeconds = Value(durationSeconds),
       pacePer100m = Value(pacePer100m);
  static Insertable<SwimmingEntry> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? environment,
    Expression<int>? poolLengthMeters,
    Expression<String>? primaryStroke,
    Expression<double>? distanceMeters,
    Expression<int>? durationSeconds,
    Expression<int>? pacePer100m,
    Expression<String>? trainingType,
    Expression<String>? equipment,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (environment != null) 'environment': environment,
      if (poolLengthMeters != null) 'pool_length_meters': poolLengthMeters,
      if (primaryStroke != null) 'primary_stroke': primaryStroke,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (pacePer100m != null) 'pace_per100m': pacePer100m,
      if (trainingType != null) 'training_type': trainingType,
      if (equipment != null) 'equipment': equipment,
    });
  }

  SwimmingEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? environment,
    Value<int?>? poolLengthMeters,
    Value<String>? primaryStroke,
    Value<double>? distanceMeters,
    Value<int>? durationSeconds,
    Value<int>? pacePer100m,
    Value<String?>? trainingType,
    Value<String?>? equipment,
  }) {
    return SwimmingEntriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      environment: environment ?? this.environment,
      poolLengthMeters: poolLengthMeters ?? this.poolLengthMeters,
      primaryStroke: primaryStroke ?? this.primaryStroke,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      pacePer100m: pacePer100m ?? this.pacePer100m,
      trainingType: trainingType ?? this.trainingType,
      equipment: equipment ?? this.equipment,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (environment.present) {
      map['environment'] = Variable<String>(environment.value);
    }
    if (poolLengthMeters.present) {
      map['pool_length_meters'] = Variable<int>(poolLengthMeters.value);
    }
    if (primaryStroke.present) {
      map['primary_stroke'] = Variable<String>(primaryStroke.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (pacePer100m.present) {
      map['pace_per100m'] = Variable<int>(pacePer100m.value);
    }
    if (trainingType.present) {
      map['training_type'] = Variable<String>(trainingType.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SwimmingEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('environment: $environment, ')
          ..write('poolLengthMeters: $poolLengthMeters, ')
          ..write('primaryStroke: $primaryStroke, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pacePer100m: $pacePer100m, ')
          ..write('trainingType: $trainingType, ')
          ..write('equipment: $equipment')
          ..write(')'))
        .toString();
  }
}

class $SwimmingSetsTable extends SwimmingSets
    with TableInfo<$SwimmingSetsTable, SwimmingSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SwimmingSetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _swimmingEntryIdMeta = const VerificationMeta(
    'swimmingEntryId',
  );
  @override
  late final GeneratedColumn<int> swimmingEntryId = GeneratedColumn<int>(
    'swimming_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES swimming_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _setTypeMeta = const VerificationMeta(
    'setType',
  );
  @override
  late final GeneratedColumn<String> setType = GeneratedColumn<String>(
    'set_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    swimmingEntryId,
    setType,
    description,
    distanceMeters,
    durationSeconds,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'swimming_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SwimmingSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('swimming_entry_id')) {
      context.handle(
        _swimmingEntryIdMeta,
        swimmingEntryId.isAcceptableOrUnknown(
          data['swimming_entry_id']!,
          _swimmingEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_swimmingEntryIdMeta);
    }
    if (data.containsKey('set_type')) {
      context.handle(
        _setTypeMeta,
        setType.isAcceptableOrUnknown(data['set_type']!, _setTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_setTypeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SwimmingSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SwimmingSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      swimmingEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}swimming_entry_id'],
      )!,
      setType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SwimmingSetsTable createAlias(String alias) {
    return $SwimmingSetsTable(attachedDatabase, alias);
  }
}

class SwimmingSet extends DataClass implements Insertable<SwimmingSet> {
  /// 主键ID
  final int id;

  /// 关联的游泳记录ID
  /// 游泳记录删除时级联删除
  final int swimmingEntryId;

  /// 分组类型：warmup(热身), main(主训练), cooldown(放松)
  final String setType;

  /// 分组描述
  final String? description;

  /// 分组距离（米）
  final double distanceMeters;

  /// 分组时长（秒）
  final int durationSeconds;

  /// 排序顺序
  final int sortOrder;
  const SwimmingSet({
    required this.id,
    required this.swimmingEntryId,
    required this.setType,
    this.description,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['swimming_entry_id'] = Variable<int>(swimmingEntryId);
    map['set_type'] = Variable<String>(setType);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SwimmingSetsCompanion toCompanion(bool nullToAbsent) {
    return SwimmingSetsCompanion(
      id: Value(id),
      swimmingEntryId: Value(swimmingEntryId),
      setType: Value(setType),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      distanceMeters: Value(distanceMeters),
      durationSeconds: Value(durationSeconds),
      sortOrder: Value(sortOrder),
    );
  }

  factory SwimmingSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SwimmingSet(
      id: serializer.fromJson<int>(json['id']),
      swimmingEntryId: serializer.fromJson<int>(json['swimmingEntryId']),
      setType: serializer.fromJson<String>(json['setType']),
      description: serializer.fromJson<String?>(json['description']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'swimmingEntryId': serializer.toJson<int>(swimmingEntryId),
      'setType': serializer.toJson<String>(setType),
      'description': serializer.toJson<String?>(description),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  SwimmingSet copyWith({
    int? id,
    int? swimmingEntryId,
    String? setType,
    Value<String?> description = const Value.absent(),
    double? distanceMeters,
    int? durationSeconds,
    int? sortOrder,
  }) => SwimmingSet(
    id: id ?? this.id,
    swimmingEntryId: swimmingEntryId ?? this.swimmingEntryId,
    setType: setType ?? this.setType,
    description: description.present ? description.value : this.description,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  SwimmingSet copyWithCompanion(SwimmingSetsCompanion data) {
    return SwimmingSet(
      id: data.id.present ? data.id.value : this.id,
      swimmingEntryId: data.swimmingEntryId.present
          ? data.swimmingEntryId.value
          : this.swimmingEntryId,
      setType: data.setType.present ? data.setType.value : this.setType,
      description: data.description.present
          ? data.description.value
          : this.description,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SwimmingSet(')
          ..write('id: $id, ')
          ..write('swimmingEntryId: $swimmingEntryId, ')
          ..write('setType: $setType, ')
          ..write('description: $description, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    swimmingEntryId,
    setType,
    description,
    distanceMeters,
    durationSeconds,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SwimmingSet &&
          other.id == this.id &&
          other.swimmingEntryId == this.swimmingEntryId &&
          other.setType == this.setType &&
          other.description == this.description &&
          other.distanceMeters == this.distanceMeters &&
          other.durationSeconds == this.durationSeconds &&
          other.sortOrder == this.sortOrder);
}

class SwimmingSetsCompanion extends UpdateCompanion<SwimmingSet> {
  final Value<int> id;
  final Value<int> swimmingEntryId;
  final Value<String> setType;
  final Value<String?> description;
  final Value<double> distanceMeters;
  final Value<int> durationSeconds;
  final Value<int> sortOrder;
  const SwimmingSetsCompanion({
    this.id = const Value.absent(),
    this.swimmingEntryId = const Value.absent(),
    this.setType = const Value.absent(),
    this.description = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SwimmingSetsCompanion.insert({
    this.id = const Value.absent(),
    required int swimmingEntryId,
    required String setType,
    this.description = const Value.absent(),
    required double distanceMeters,
    required int durationSeconds,
    this.sortOrder = const Value.absent(),
  }) : swimmingEntryId = Value(swimmingEntryId),
       setType = Value(setType),
       distanceMeters = Value(distanceMeters),
       durationSeconds = Value(durationSeconds);
  static Insertable<SwimmingSet> custom({
    Expression<int>? id,
    Expression<int>? swimmingEntryId,
    Expression<String>? setType,
    Expression<String>? description,
    Expression<double>? distanceMeters,
    Expression<int>? durationSeconds,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (swimmingEntryId != null) 'swimming_entry_id': swimmingEntryId,
      if (setType != null) 'set_type': setType,
      if (description != null) 'description': description,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SwimmingSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? swimmingEntryId,
    Value<String>? setType,
    Value<String?>? description,
    Value<double>? distanceMeters,
    Value<int>? durationSeconds,
    Value<int>? sortOrder,
  }) {
    return SwimmingSetsCompanion(
      id: id ?? this.id,
      swimmingEntryId: swimmingEntryId ?? this.swimmingEntryId,
      setType: setType ?? this.setType,
      description: description ?? this.description,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (swimmingEntryId.present) {
      map['swimming_entry_id'] = Variable<int>(swimmingEntryId.value);
    }
    if (setType.present) {
      map['set_type'] = Variable<String>(setType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SwimmingSetsCompanion(')
          ..write('id: $id, ')
          ..write('swimmingEntryId: $swimmingEntryId, ')
          ..write('setType: $setType, ')
          ..write('description: $description, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TemplateExercisesTable extends TemplateExercises
    with TableInfo<$TemplateExercisesTable, TemplateExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateExercisesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<int> templateId = GeneratedColumn<int>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_templates (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    exerciseId,
    exerciseName,
    sets,
    reps,
    weight,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'template_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    } else if (isInserting) {
      context.missing(_setsMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      ),
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TemplateExercisesTable createAlias(String alias) {
    return $TemplateExercisesTable(attachedDatabase, alias);
  }
}

class TemplateExercise extends DataClass
    implements Insertable<TemplateExercise> {
  /// 主键ID
  final int id;

  /// 关联的模板ID
  /// 模板删除时级联删除模板动作
  final int templateId;

  /// 关联的动作ID（可选）
  /// 动作删除受限，防止模板出现悬空引用
  final int? exerciseId;

  /// 动作名称
  final String exerciseName;

  /// 默认组数
  final int sets;

  /// 默认次数
  final int reps;

  /// 默认重量
  final double? weight;

  /// 排序顺序
  final int sortOrder;
  const TemplateExercise({
    required this.id,
    required this.templateId,
    this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weight,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['template_id'] = Variable<int>(templateId);
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<int>(exerciseId);
    }
    map['exercise_name'] = Variable<String>(exerciseName);
    map['sets'] = Variable<int>(sets);
    map['reps'] = Variable<int>(reps);
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TemplateExercisesCompanion toCompanion(bool nullToAbsent) {
    return TemplateExercisesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      exerciseId: exerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseId),
      exerciseName: Value(exerciseName),
      sets: Value(sets),
      reps: Value(reps),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      sortOrder: Value(sortOrder),
    );
  }

  factory TemplateExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateExercise(
      id: serializer.fromJson<int>(json['id']),
      templateId: serializer.fromJson<int>(json['templateId']),
      exerciseId: serializer.fromJson<int?>(json['exerciseId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      sets: serializer.fromJson<int>(json['sets']),
      reps: serializer.fromJson<int>(json['reps']),
      weight: serializer.fromJson<double?>(json['weight']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'templateId': serializer.toJson<int>(templateId),
      'exerciseId': serializer.toJson<int?>(exerciseId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'sets': serializer.toJson<int>(sets),
      'reps': serializer.toJson<int>(reps),
      'weight': serializer.toJson<double?>(weight),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TemplateExercise copyWith({
    int? id,
    int? templateId,
    Value<int?> exerciseId = const Value.absent(),
    String? exerciseName,
    int? sets,
    int? reps,
    Value<double?> weight = const Value.absent(),
    int? sortOrder,
  }) => TemplateExercise(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    exerciseName: exerciseName ?? this.exerciseName,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    weight: weight.present ? weight.value : this.weight,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TemplateExercise copyWithCompanion(TemplateExercisesCompanion data) {
    return TemplateExercise(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      sets: data.sets.present ? data.sets.value : this.sets,
      reps: data.reps.present ? data.reps.value : this.reps,
      weight: data.weight.present ? data.weight.value : this.weight,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateExercise(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('weight: $weight, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    exerciseId,
    exerciseName,
    sets,
    reps,
    weight,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateExercise &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.exerciseId == this.exerciseId &&
          other.exerciseName == this.exerciseName &&
          other.sets == this.sets &&
          other.reps == this.reps &&
          other.weight == this.weight &&
          other.sortOrder == this.sortOrder);
}

class TemplateExercisesCompanion extends UpdateCompanion<TemplateExercise> {
  final Value<int> id;
  final Value<int> templateId;
  final Value<int?> exerciseId;
  final Value<String> exerciseName;
  final Value<int> sets;
  final Value<int> reps;
  final Value<double?> weight;
  final Value<int> sortOrder;
  const TemplateExercisesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.sets = const Value.absent(),
    this.reps = const Value.absent(),
    this.weight = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  TemplateExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int templateId,
    this.exerciseId = const Value.absent(),
    required String exerciseName,
    required int sets,
    required int reps,
    this.weight = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : templateId = Value(templateId),
       exerciseName = Value(exerciseName),
       sets = Value(sets),
       reps = Value(reps);
  static Insertable<TemplateExercise> custom({
    Expression<int>? id,
    Expression<int>? templateId,
    Expression<int>? exerciseId,
    Expression<String>? exerciseName,
    Expression<int>? sets,
    Expression<int>? reps,
    Expression<double>? weight,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
      if (weight != null) 'weight': weight,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  TemplateExercisesCompanion copyWith({
    Value<int>? id,
    Value<int>? templateId,
    Value<int?>? exerciseId,
    Value<String>? exerciseName,
    Value<int>? sets,
    Value<int>? reps,
    Value<double?>? weight,
    Value<int>? sortOrder,
  }) {
    return TemplateExercisesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<int>(templateId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateExercisesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('sets: $sets, ')
          ..write('reps: $reps, ')
          ..write('weight: $weight, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $PersonalRecordsTable extends PersonalRecords
    with TableInfo<$PersonalRecordsTable, PersonalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES training_sessions (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordType,
    exerciseId,
    value,
    unit,
    achievedAt,
    sessionId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_recordTypeMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PersonalRecordsTable createAlias(String alias) {
    return $PersonalRecordsTable(attachedDatabase, alias);
  }
}

class PersonalRecord extends DataClass implements Insertable<PersonalRecord> {
  /// 主键ID
  final int id;

  /// 记录类型：strength_1rm, strength_volume, running_distance, running_pace, swimming_distance
  final String recordType;

  /// 关联的动作ID（力量训练）
  /// 动作删除受限，避免破坏 PR 归属
  final int? exerciseId;

  /// 记录值
  final double value;

  /// 单位：kg, meters, seconds
  final String unit;

  /// 达成日期
  final DateTime achievedAt;

  /// 关联的训练会话ID
  /// 会话删除时保留 PR，清空来源会话引用
  final int? sessionId;

  /// 创建时间
  final DateTime createdAt;
  const PersonalRecord({
    required this.id,
    required this.recordType,
    this.exerciseId,
    required this.value,
    required this.unit,
    required this.achievedAt,
    this.sessionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['record_type'] = Variable<String>(recordType);
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<int>(exerciseId);
    }
    map['value'] = Variable<double>(value);
    map['unit'] = Variable<String>(unit);
    map['achieved_at'] = Variable<DateTime>(achievedAt);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PersonalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PersonalRecordsCompanion(
      id: Value(id),
      recordType: Value(recordType),
      exerciseId: exerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseId),
      value: Value(value),
      unit: Value(unit),
      achievedAt: Value(achievedAt),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      createdAt: Value(createdAt),
    );
  }

  factory PersonalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalRecord(
      id: serializer.fromJson<int>(json['id']),
      recordType: serializer.fromJson<String>(json['recordType']),
      exerciseId: serializer.fromJson<int?>(json['exerciseId']),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      achievedAt: serializer.fromJson<DateTime>(json['achievedAt']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordType': serializer.toJson<String>(recordType),
      'exerciseId': serializer.toJson<int?>(exerciseId),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(unit),
      'achievedAt': serializer.toJson<DateTime>(achievedAt),
      'sessionId': serializer.toJson<int?>(sessionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PersonalRecord copyWith({
    int? id,
    String? recordType,
    Value<int?> exerciseId = const Value.absent(),
    double? value,
    String? unit,
    DateTime? achievedAt,
    Value<int?> sessionId = const Value.absent(),
    DateTime? createdAt,
  }) => PersonalRecord(
    id: id ?? this.id,
    recordType: recordType ?? this.recordType,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    value: value ?? this.value,
    unit: unit ?? this.unit,
    achievedAt: achievedAt ?? this.achievedAt,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    createdAt: createdAt ?? this.createdAt,
  );
  PersonalRecord copyWithCompanion(PersonalRecordsCompanion data) {
    return PersonalRecord(
      id: data.id.present ? data.id.value : this.id,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecord(')
          ..write('id: $id, ')
          ..write('recordType: $recordType, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordType,
    exerciseId,
    value,
    unit,
    achievedAt,
    sessionId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalRecord &&
          other.id == this.id &&
          other.recordType == this.recordType &&
          other.exerciseId == this.exerciseId &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.achievedAt == this.achievedAt &&
          other.sessionId == this.sessionId &&
          other.createdAt == this.createdAt);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecord> {
  final Value<int> id;
  final Value<String> recordType;
  final Value<int?> exerciseId;
  final Value<double> value;
  final Value<String> unit;
  final Value<DateTime> achievedAt;
  final Value<int?> sessionId;
  final Value<DateTime> createdAt;
  const PersonalRecordsCompanion({
    this.id = const Value.absent(),
    this.recordType = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PersonalRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String recordType,
    this.exerciseId = const Value.absent(),
    required double value,
    required String unit,
    required DateTime achievedAt,
    this.sessionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : recordType = Value(recordType),
       value = Value(value),
       unit = Value(unit),
       achievedAt = Value(achievedAt);
  static Insertable<PersonalRecord> custom({
    Expression<int>? id,
    Expression<String>? recordType,
    Expression<int>? exerciseId,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<DateTime>? achievedAt,
    Expression<int>? sessionId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordType != null) 'record_type': recordType,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (sessionId != null) 'session_id': sessionId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PersonalRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? recordType,
    Value<int?>? exerciseId,
    Value<double>? value,
    Value<String>? unit,
    Value<DateTime>? achievedAt,
    Value<int?>? sessionId,
    Value<DateTime>? createdAt,
  }) {
    return PersonalRecordsCompanion(
      id: id ?? this.id,
      recordType: recordType ?? this.recordType,
      exerciseId: exerciseId ?? this.exerciseId,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      achievedAt: achievedAt ?? this.achievedAt,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('recordType: $recordType, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BackupConfigurationsTable backupConfigurations =
      $BackupConfigurationsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $WorkoutTemplatesTable workoutTemplates = $WorkoutTemplatesTable(
    this,
  );
  late final $TrainingSessionsTable trainingSessions = $TrainingSessionsTable(
    this,
  );
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $StrengthExerciseEntriesTable strengthExerciseEntries =
      $StrengthExerciseEntriesTable(this);
  late final $BackupRecordsTable backupRecords = $BackupRecordsTable(this);
  late final $RunningEntriesTable runningEntries = $RunningEntriesTable(this);
  late final $RunningSplitsTable runningSplits = $RunningSplitsTable(this);
  late final $SwimmingEntriesTable swimmingEntries = $SwimmingEntriesTable(
    this,
  );
  late final $SwimmingSetsTable swimmingSets = $SwimmingSetsTable(this);
  late final $TemplateExercisesTable templateExercises =
      $TemplateExercisesTable(this);
  late final $PersonalRecordsTable personalRecords = $PersonalRecordsTable(
    this,
  );
  late final Index idxSessionsDatetime = Index(
    'idx_sessions_datetime',
    'CREATE INDEX idx_sessions_datetime ON training_sessions (datetime)',
  );
  late final Index idxSessionsType = Index(
    'idx_sessions_type',
    'CREATE INDEX idx_sessions_type ON training_sessions (type)',
  );
  late final Index idxSessionsTypeDatetime = Index(
    'idx_sessions_type_datetime',
    'CREATE INDEX idx_sessions_type_datetime ON training_sessions (type, datetime)',
  );
  late final Index idxStrengthSession = Index(
    'idx_strength_session',
    'CREATE INDEX idx_strength_session ON strength_exercise_entries (session_id)',
  );
  late final Index idxStrengthExercise = Index(
    'idx_strength_exercise',
    'CREATE INDEX idx_strength_exercise ON strength_exercise_entries (exercise_id)',
  );
  late final Index idxBackupConfigsDefault = Index(
    'idx_backup_configs_default',
    'CREATE INDEX idx_backup_configs_default ON backup_configurations (is_default)',
  );
  late final Index idxBackupConfigsProvider = Index(
    'idx_backup_configs_provider',
    'CREATE INDEX idx_backup_configs_provider ON backup_configurations (provider_type)',
  );
  late final Index idxBackupRecordsConfig = Index(
    'idx_backup_records_config',
    'CREATE INDEX idx_backup_records_config ON backup_records (config_id)',
  );
  late final Index idxExercisesCategory = Index(
    'idx_exercises_category',
    'CREATE INDEX idx_exercises_category ON exercises (category)',
  );
  late final Index idxRunningSession = Index(
    'idx_running_session',
    'CREATE INDEX idx_running_session ON running_entries (session_id)',
  );
  late final Index idxSplitsEntry = Index(
    'idx_splits_entry',
    'CREATE INDEX idx_splits_entry ON running_splits (running_entry_id)',
  );
  late final Index idxSwimmingSession = Index(
    'idx_swimming_session',
    'CREATE INDEX idx_swimming_session ON swimming_entries (session_id)',
  );
  late final Index idxSwimmingStroke = Index(
    'idx_swimming_stroke',
    'CREATE INDEX idx_swimming_stroke ON swimming_entries (primary_stroke)',
  );
  late final Index idxSetsEntry = Index(
    'idx_sets_entry',
    'CREATE INDEX idx_sets_entry ON swimming_sets (swimming_entry_id)',
  );
  late final Index idxTemplatesType = Index(
    'idx_templates_type',
    'CREATE INDEX idx_templates_type ON workout_templates (type)',
  );
  late final Index idxTemplateExercisesTemplate = Index(
    'idx_template_exercises_template',
    'CREATE INDEX idx_template_exercises_template ON template_exercises (template_id)',
  );
  late final Index idxTemplateExercisesExercise = Index(
    'idx_template_exercises_exercise',
    'CREATE INDEX idx_template_exercises_exercise ON template_exercises (exercise_id)',
  );
  late final Index idxPrExercise = Index(
    'idx_pr_exercise',
    'CREATE INDEX idx_pr_exercise ON personal_records (exercise_id)',
  );
  late final Index idxPrTypeExercise = Index(
    'idx_pr_type_exercise',
    'CREATE INDEX idx_pr_type_exercise ON personal_records (record_type, exercise_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    backupConfigurations,
    userSettings,
    workoutTemplates,
    trainingSessions,
    exercises,
    strengthExerciseEntries,
    backupRecords,
    runningEntries,
    runningSplits,
    swimmingEntries,
    swimmingSets,
    templateExercises,
    personalRecords,
    idxSessionsDatetime,
    idxSessionsType,
    idxSessionsTypeDatetime,
    idxStrengthSession,
    idxStrengthExercise,
    idxBackupConfigsDefault,
    idxBackupConfigsProvider,
    idxBackupRecordsConfig,
    idxExercisesCategory,
    idxRunningSession,
    idxSplitsEntry,
    idxSwimmingSession,
    idxSwimmingStroke,
    idxSetsEntry,
    idxTemplatesType,
    idxTemplateExercisesTemplate,
    idxTemplateExercisesExercise,
    idxPrExercise,
    idxPrTypeExercise,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'backup_configurations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_settings', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_templates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('training_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'training_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('strength_exercise_entries', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'backup_configurations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('backup_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'training_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('running_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'running_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('running_splits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'training_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('swimming_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'swimming_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('swimming_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_templates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('template_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'training_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('personal_records', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$BackupConfigurationsTableCreateCompanionBuilder =
    BackupConfigurationsCompanion Function({
      Value<int> id,
      required String providerType,
      required String displayName,
      required String endpoint,
      required String bucketOrPath,
      Value<String?> region,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$BackupConfigurationsTableUpdateCompanionBuilder =
    BackupConfigurationsCompanion Function({
      Value<int> id,
      Value<String> providerType,
      Value<String> displayName,
      Value<String> endpoint,
      Value<String> bucketOrPath,
      Value<String?> region,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BackupConfigurationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BackupConfigurationsTable,
          BackupConfiguration
        > {
  $$BackupConfigurationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$UserSettingsTable, List<UserSetting>>
  _userSettingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userSettings,
    aliasName: $_aliasNameGenerator(
      db.backupConfigurations.id,
      db.userSettings.defaultBackupConfigId,
    ),
  );

  $$UserSettingsTableProcessedTableManager get userSettingsRefs {
    final manager = $$UserSettingsTableTableManager($_db, $_db.userSettings)
        .filter(
          (f) => f.defaultBackupConfigId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_userSettingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BackupRecordsTable, List<BackupRecord>>
  _backupRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.backupRecords,
    aliasName: $_aliasNameGenerator(
      db.backupConfigurations.id,
      db.backupRecords.configId,
    ),
  );

  $$BackupRecordsTableProcessedTableManager get backupRecordsRefs {
    final manager = $$BackupRecordsTableTableManager(
      $_db,
      $_db.backupRecords,
    ).filter((f) => f.configId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_backupRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BackupConfigurationsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupConfigurationsTable> {
  $$BackupConfigurationsTableFilterComposer({
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

  ColumnFilters<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucketOrPath => $composableBuilder(
    column: $table.bucketOrPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userSettingsRefs(
    Expression<bool> Function($$UserSettingsTableFilterComposer f) f,
  ) {
    final $$UserSettingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userSettings,
      getReferencedColumn: (t) => t.defaultBackupConfigId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserSettingsTableFilterComposer(
            $db: $db,
            $table: $db.userSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> backupRecordsRefs(
    Expression<bool> Function($$BackupRecordsTableFilterComposer f) f,
  ) {
    final $$BackupRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.backupRecords,
      getReferencedColumn: (t) => t.configId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BackupRecordsTableFilterComposer(
            $db: $db,
            $table: $db.backupRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BackupConfigurationsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupConfigurationsTable> {
  $$BackupConfigurationsTableOrderingComposer({
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

  ColumnOrderings<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucketOrPath => $composableBuilder(
    column: $table.bucketOrPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupConfigurationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupConfigurationsTable> {
  $$BackupConfigurationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get bucketOrPath => $composableBuilder(
    column: $table.bucketOrPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> userSettingsRefs<T extends Object>(
    Expression<T> Function($$UserSettingsTableAnnotationComposer a) f,
  ) {
    final $$UserSettingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userSettings,
      getReferencedColumn: (t) => t.defaultBackupConfigId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserSettingsTableAnnotationComposer(
            $db: $db,
            $table: $db.userSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> backupRecordsRefs<T extends Object>(
    Expression<T> Function($$BackupRecordsTableAnnotationComposer a) f,
  ) {
    final $$BackupRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.backupRecords,
      getReferencedColumn: (t) => t.configId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BackupRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.backupRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BackupConfigurationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupConfigurationsTable,
          BackupConfiguration,
          $$BackupConfigurationsTableFilterComposer,
          $$BackupConfigurationsTableOrderingComposer,
          $$BackupConfigurationsTableAnnotationComposer,
          $$BackupConfigurationsTableCreateCompanionBuilder,
          $$BackupConfigurationsTableUpdateCompanionBuilder,
          (BackupConfiguration, $$BackupConfigurationsTableReferences),
          BackupConfiguration,
          PrefetchHooks Function({
            bool userSettingsRefs,
            bool backupRecordsRefs,
          })
        > {
  $$BackupConfigurationsTableTableManager(
    _$AppDatabase db,
    $BackupConfigurationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupConfigurationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupConfigurationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BackupConfigurationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> providerType = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String> bucketOrPath = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BackupConfigurationsCompanion(
                id: id,
                providerType: providerType,
                displayName: displayName,
                endpoint: endpoint,
                bucketOrPath: bucketOrPath,
                region: region,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String providerType,
                required String displayName,
                required String endpoint,
                required String bucketOrPath,
                Value<String?> region = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BackupConfigurationsCompanion.insert(
                id: id,
                providerType: providerType,
                displayName: displayName,
                endpoint: endpoint,
                bucketOrPath: bucketOrPath,
                region: region,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BackupConfigurationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({userSettingsRefs = false, backupRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (userSettingsRefs) db.userSettings,
                    if (backupRecordsRefs) db.backupRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (userSettingsRefs)
                        await $_getPrefetchedData<
                          BackupConfiguration,
                          $BackupConfigurationsTable,
                          UserSetting
                        >(
                          currentTable: table,
                          referencedTable: $$BackupConfigurationsTableReferences
                              ._userSettingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BackupConfigurationsTableReferences(
                                db,
                                table,
                                p0,
                              ).userSettingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.defaultBackupConfigId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (backupRecordsRefs)
                        await $_getPrefetchedData<
                          BackupConfiguration,
                          $BackupConfigurationsTable,
                          BackupRecord
                        >(
                          currentTable: table,
                          referencedTable: $$BackupConfigurationsTableReferences
                              ._backupRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BackupConfigurationsTableReferences(
                                db,
                                table,
                                p0,
                              ).backupRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.configId == item.id,
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

typedef $$BackupConfigurationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupConfigurationsTable,
      BackupConfiguration,
      $$BackupConfigurationsTableFilterComposer,
      $$BackupConfigurationsTableOrderingComposer,
      $$BackupConfigurationsTableAnnotationComposer,
      $$BackupConfigurationsTableCreateCompanionBuilder,
      $$BackupConfigurationsTableUpdateCompanionBuilder,
      (BackupConfiguration, $$BackupConfigurationsTableReferences),
      BackupConfiguration,
      PrefetchHooks Function({bool userSettingsRefs, bool backupRecordsRefs})
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<int> weeklyWorkoutDaysGoal,
      Value<int> weeklyWorkoutMinutesGoal,
      Value<String> themeMode,
      Value<String> weightUnit,
      Value<String> distanceUnit,
      Value<bool> lanServiceEnabled,
      Value<int> lanServicePort,
      Value<bool> lanServiceTokenEnabled,
      Value<int?> defaultBackupConfigId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<int> weeklyWorkoutDaysGoal,
      Value<int> weeklyWorkoutMinutesGoal,
      Value<String> themeMode,
      Value<String> weightUnit,
      Value<String> distanceUnit,
      Value<bool> lanServiceEnabled,
      Value<int> lanServicePort,
      Value<bool> lanServiceTokenEnabled,
      Value<int?> defaultBackupConfigId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$UserSettingsTableReferences
    extends BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting> {
  $$UserSettingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BackupConfigurationsTable _defaultBackupConfigIdTable(
    _$AppDatabase db,
  ) => db.backupConfigurations.createAlias(
    $_aliasNameGenerator(
      db.userSettings.defaultBackupConfigId,
      db.backupConfigurations.id,
    ),
  );

  $$BackupConfigurationsTableProcessedTableManager? get defaultBackupConfigId {
    final $_column = $_itemColumn<int>('default_backup_config_id');
    if ($_column == null) return null;
    final manager = $$BackupConfigurationsTableTableManager(
      $_db,
      $_db.backupConfigurations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _defaultBackupConfigIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
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

  ColumnFilters<int> get weeklyWorkoutDaysGoal => $composableBuilder(
    column: $table.weeklyWorkoutDaysGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyWorkoutMinutesGoal => $composableBuilder(
    column: $table.weeklyWorkoutMinutesGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lanServiceEnabled => $composableBuilder(
    column: $table.lanServiceEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lanServicePort => $composableBuilder(
    column: $table.lanServicePort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lanServiceTokenEnabled => $composableBuilder(
    column: $table.lanServiceTokenEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BackupConfigurationsTableFilterComposer get defaultBackupConfigId {
    final $$BackupConfigurationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultBackupConfigId,
      referencedTable: $db.backupConfigurations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BackupConfigurationsTableFilterComposer(
            $db: $db,
            $table: $db.backupConfigurations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
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

  ColumnOrderings<int> get weeklyWorkoutDaysGoal => $composableBuilder(
    column: $table.weeklyWorkoutDaysGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyWorkoutMinutesGoal => $composableBuilder(
    column: $table.weeklyWorkoutMinutesGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lanServiceEnabled => $composableBuilder(
    column: $table.lanServiceEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lanServicePort => $composableBuilder(
    column: $table.lanServicePort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lanServiceTokenEnabled => $composableBuilder(
    column: $table.lanServiceTokenEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BackupConfigurationsTableOrderingComposer get defaultBackupConfigId {
    final $$BackupConfigurationsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.defaultBackupConfigId,
          referencedTable: $db.backupConfigurations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BackupConfigurationsTableOrderingComposer(
                $db: $db,
                $table: $db.backupConfigurations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get weeklyWorkoutDaysGoal => $composableBuilder(
    column: $table.weeklyWorkoutDaysGoal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyWorkoutMinutesGoal => $composableBuilder(
    column: $table.weeklyWorkoutMinutesGoal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lanServiceEnabled => $composableBuilder(
    column: $table.lanServiceEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lanServicePort => $composableBuilder(
    column: $table.lanServicePort,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lanServiceTokenEnabled => $composableBuilder(
    column: $table.lanServiceTokenEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BackupConfigurationsTableAnnotationComposer get defaultBackupConfigId {
    final $$BackupConfigurationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.defaultBackupConfigId,
          referencedTable: $db.backupConfigurations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BackupConfigurationsTableAnnotationComposer(
                $db: $db,
                $table: $db.backupConfigurations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSetting,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (UserSetting, $$UserSettingsTableReferences),
          UserSetting,
          PrefetchHooks Function({bool defaultBackupConfigId})
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> weeklyWorkoutDaysGoal = const Value.absent(),
                Value<int> weeklyWorkoutMinutesGoal = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> weightUnit = const Value.absent(),
                Value<String> distanceUnit = const Value.absent(),
                Value<bool> lanServiceEnabled = const Value.absent(),
                Value<int> lanServicePort = const Value.absent(),
                Value<bool> lanServiceTokenEnabled = const Value.absent(),
                Value<int?> defaultBackupConfigId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserSettingsCompanion(
                id: id,
                weeklyWorkoutDaysGoal: weeklyWorkoutDaysGoal,
                weeklyWorkoutMinutesGoal: weeklyWorkoutMinutesGoal,
                themeMode: themeMode,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                lanServiceEnabled: lanServiceEnabled,
                lanServicePort: lanServicePort,
                lanServiceTokenEnabled: lanServiceTokenEnabled,
                defaultBackupConfigId: defaultBackupConfigId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> weeklyWorkoutDaysGoal = const Value.absent(),
                Value<int> weeklyWorkoutMinutesGoal = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> weightUnit = const Value.absent(),
                Value<String> distanceUnit = const Value.absent(),
                Value<bool> lanServiceEnabled = const Value.absent(),
                Value<int> lanServicePort = const Value.absent(),
                Value<bool> lanServiceTokenEnabled = const Value.absent(),
                Value<int?> defaultBackupConfigId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                id: id,
                weeklyWorkoutDaysGoal: weeklyWorkoutDaysGoal,
                weeklyWorkoutMinutesGoal: weeklyWorkoutMinutesGoal,
                themeMode: themeMode,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                lanServiceEnabled: lanServiceEnabled,
                lanServicePort: lanServicePort,
                lanServiceTokenEnabled: lanServiceTokenEnabled,
                defaultBackupConfigId: defaultBackupConfigId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserSettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({defaultBackupConfigId = false}) {
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
                    if (defaultBackupConfigId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.defaultBackupConfigId,
                                referencedTable: $$UserSettingsTableReferences
                                    ._defaultBackupConfigIdTable(db),
                                referencedColumn: $$UserSettingsTableReferences
                                    ._defaultBackupConfigIdTable(db)
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

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSetting,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (UserSetting, $$UserSettingsTableReferences),
      UserSetting,
      PrefetchHooks Function({bool defaultBackupConfigId})
    >;
typedef $$WorkoutTemplatesTableCreateCompanionBuilder =
    WorkoutTemplatesCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      Value<String?> description,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$WorkoutTemplatesTableUpdateCompanionBuilder =
    WorkoutTemplatesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<String?> description,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$WorkoutTemplatesTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutTemplatesTable, WorkoutTemplate> {
  $$WorkoutTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TrainingSessionsTable, List<TrainingSession>>
  _trainingSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trainingSessions,
    aliasName: $_aliasNameGenerator(
      db.workoutTemplates.id,
      db.trainingSessions.templateId,
    ),
  );

  $$TrainingSessionsTableProcessedTableManager get trainingSessionsRefs {
    final manager = $$TrainingSessionsTableTableManager(
      $_db,
      $_db.trainingSessions,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trainingSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TemplateExercisesTable, List<TemplateExercise>>
  _templateExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.templateExercises,
        aliasName: $_aliasNameGenerator(
          db.workoutTemplates.id,
          db.templateExercises.templateId,
        ),
      );

  $$TemplateExercisesTableProcessedTableManager get templateExercisesRefs {
    final manager = $$TemplateExercisesTableTableManager(
      $_db,
      $_db.templateExercises,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _templateExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trainingSessionsRefs(
    Expression<bool> Function($$TrainingSessionsTableFilterComposer f) f,
  ) {
    final $$TrainingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> templateExercisesRefs(
    Expression<bool> Function($$TemplateExercisesTableFilterComposer f) f,
  ) {
    final $$TemplateExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateExercises,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateExercisesTableFilterComposer(
            $db: $db,
            $table: $db.templateExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> trainingSessionsRefs<T extends Object>(
    Expression<T> Function($$TrainingSessionsTableAnnotationComposer a) f,
  ) {
    final $$TrainingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> templateExercisesRefs<T extends Object>(
    Expression<T> Function($$TemplateExercisesTableAnnotationComposer a) f,
  ) {
    final $$TemplateExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.templateExercises,
          getReferencedColumn: (t) => t.templateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.templateExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutTemplatesTable,
          WorkoutTemplate,
          $$WorkoutTemplatesTableFilterComposer,
          $$WorkoutTemplatesTableOrderingComposer,
          $$WorkoutTemplatesTableAnnotationComposer,
          $$WorkoutTemplatesTableCreateCompanionBuilder,
          $$WorkoutTemplatesTableUpdateCompanionBuilder,
          (WorkoutTemplate, $$WorkoutTemplatesTableReferences),
          WorkoutTemplate,
          PrefetchHooks Function({
            bool trainingSessionsRefs,
            bool templateExercisesRefs,
          })
        > {
  $$WorkoutTemplatesTableTableManager(
    _$AppDatabase db,
    $WorkoutTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WorkoutTemplatesCompanion(
                id: id,
                name: name,
                type: type,
                description: description,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                Value<String?> description = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WorkoutTemplatesCompanion.insert(
                id: id,
                name: name,
                type: type,
                description: description,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({trainingSessionsRefs = false, templateExercisesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trainingSessionsRefs) db.trainingSessions,
                    if (templateExercisesRefs) db.templateExercises,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trainingSessionsRefs)
                        await $_getPrefetchedData<
                          WorkoutTemplate,
                          $WorkoutTemplatesTable,
                          TrainingSession
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutTemplatesTableReferences
                              ._trainingSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutTemplatesTableReferences(
                                db,
                                table,
                                p0,
                              ).trainingSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.templateId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (templateExercisesRefs)
                        await $_getPrefetchedData<
                          WorkoutTemplate,
                          $WorkoutTemplatesTable,
                          TemplateExercise
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutTemplatesTableReferences
                              ._templateExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutTemplatesTableReferences(
                                db,
                                table,
                                p0,
                              ).templateExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.templateId == item.id,
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

typedef $$WorkoutTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutTemplatesTable,
      WorkoutTemplate,
      $$WorkoutTemplatesTableFilterComposer,
      $$WorkoutTemplatesTableOrderingComposer,
      $$WorkoutTemplatesTableAnnotationComposer,
      $$WorkoutTemplatesTableCreateCompanionBuilder,
      $$WorkoutTemplatesTableUpdateCompanionBuilder,
      (WorkoutTemplate, $$WorkoutTemplatesTableReferences),
      WorkoutTemplate,
      PrefetchHooks Function({
        bool trainingSessionsRefs,
        bool templateExercisesRefs,
      })
    >;
typedef $$TrainingSessionsTableCreateCompanionBuilder =
    TrainingSessionsCompanion Function({
      Value<int> id,
      required DateTime datetime,
      required String type,
      required int durationMinutes,
      required String intensity,
      Value<String?> note,
      Value<bool> isGoalCompleted,
      Value<int?> templateId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TrainingSessionsTableUpdateCompanionBuilder =
    TrainingSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> datetime,
      Value<String> type,
      Value<int> durationMinutes,
      Value<String> intensity,
      Value<String?> note,
      Value<bool> isGoalCompleted,
      Value<int?> templateId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TrainingSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TrainingSessionsTable, TrainingSession> {
  $$TrainingSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutTemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.workoutTemplates.createAlias(
        $_aliasNameGenerator(
          db.trainingSessions.templateId,
          db.workoutTemplates.id,
        ),
      );

  $$WorkoutTemplatesTableProcessedTableManager? get templateId {
    final $_column = $_itemColumn<int>('template_id');
    if ($_column == null) return null;
    final manager = $$WorkoutTemplatesTableTableManager(
      $_db,
      $_db.workoutTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $StrengthExerciseEntriesTable,
    List<StrengthExerciseEntry>
  >
  _strengthExerciseEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.strengthExerciseEntries,
        aliasName: $_aliasNameGenerator(
          db.trainingSessions.id,
          db.strengthExerciseEntries.sessionId,
        ),
      );

  $$StrengthExerciseEntriesTableProcessedTableManager
  get strengthExerciseEntriesRefs {
    final manager = $$StrengthExerciseEntriesTableTableManager(
      $_db,
      $_db.strengthExerciseEntries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _strengthExerciseEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RunningEntriesTable, List<RunningEntry>>
  _runningEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.runningEntries,
    aliasName: $_aliasNameGenerator(
      db.trainingSessions.id,
      db.runningEntries.sessionId,
    ),
  );

  $$RunningEntriesTableProcessedTableManager get runningEntriesRefs {
    final manager = $$RunningEntriesTableTableManager(
      $_db,
      $_db.runningEntries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_runningEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SwimmingEntriesTable, List<SwimmingEntry>>
  _swimmingEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.swimmingEntries,
    aliasName: $_aliasNameGenerator(
      db.trainingSessions.id,
      db.swimmingEntries.sessionId,
    ),
  );

  $$SwimmingEntriesTableProcessedTableManager get swimmingEntriesRefs {
    final manager = $$SwimmingEntriesTableTableManager(
      $_db,
      $_db.swimmingEntries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _swimmingEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecord>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: $_aliasNameGenerator(
      db.trainingSessions.id,
      db.personalRecords.sessionId,
    ),
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrainingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingSessionsTable> {
  $$TrainingSessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get datetime => $composableBuilder(
    column: $table.datetime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGoalCompleted => $composableBuilder(
    column: $table.isGoalCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutTemplatesTableFilterComposer get templateId {
    final $$WorkoutTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> strengthExerciseEntriesRefs(
    Expression<bool> Function($$StrengthExerciseEntriesTableFilterComposer f) f,
  ) {
    final $$StrengthExerciseEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strengthExerciseEntries,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrengthExerciseEntriesTableFilterComposer(
                $db: $db,
                $table: $db.strengthExerciseEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> runningEntriesRefs(
    Expression<bool> Function($$RunningEntriesTableFilterComposer f) f,
  ) {
    final $$RunningEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runningEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunningEntriesTableFilterComposer(
            $db: $db,
            $table: $db.runningEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> swimmingEntriesRefs(
    Expression<bool> Function($$SwimmingEntriesTableFilterComposer f) f,
  ) {
    final $$SwimmingEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.swimmingEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SwimmingEntriesTableFilterComposer(
            $db: $db,
            $table: $db.swimmingEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingSessionsTable> {
  $$TrainingSessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get datetime => $composableBuilder(
    column: $table.datetime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGoalCompleted => $composableBuilder(
    column: $table.isGoalCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutTemplatesTableOrderingComposer get templateId {
    final $$WorkoutTemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrainingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingSessionsTable> {
  $$TrainingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get datetime =>
      $composableBuilder(column: $table.datetime, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isGoalCompleted => $composableBuilder(
    column: $table.isGoalCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkoutTemplatesTableAnnotationComposer get templateId {
    final $$WorkoutTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> strengthExerciseEntriesRefs<T extends Object>(
    Expression<T> Function($$StrengthExerciseEntriesTableAnnotationComposer a)
    f,
  ) {
    final $$StrengthExerciseEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strengthExerciseEntries,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrengthExerciseEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.strengthExerciseEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> runningEntriesRefs<T extends Object>(
    Expression<T> Function($$RunningEntriesTableAnnotationComposer a) f,
  ) {
    final $$RunningEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runningEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunningEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.runningEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> swimmingEntriesRefs<T extends Object>(
    Expression<T> Function($$SwimmingEntriesTableAnnotationComposer a) f,
  ) {
    final $$SwimmingEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.swimmingEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SwimmingEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.swimmingEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrainingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingSessionsTable,
          TrainingSession,
          $$TrainingSessionsTableFilterComposer,
          $$TrainingSessionsTableOrderingComposer,
          $$TrainingSessionsTableAnnotationComposer,
          $$TrainingSessionsTableCreateCompanionBuilder,
          $$TrainingSessionsTableUpdateCompanionBuilder,
          (TrainingSession, $$TrainingSessionsTableReferences),
          TrainingSession,
          PrefetchHooks Function({
            bool templateId,
            bool strengthExerciseEntriesRefs,
            bool runningEntriesRefs,
            bool swimmingEntriesRefs,
            bool personalRecordsRefs,
          })
        > {
  $$TrainingSessionsTableTableManager(
    _$AppDatabase db,
    $TrainingSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> datetime = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String> intensity = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isGoalCompleted = const Value.absent(),
                Value<int?> templateId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TrainingSessionsCompanion(
                id: id,
                datetime: datetime,
                type: type,
                durationMinutes: durationMinutes,
                intensity: intensity,
                note: note,
                isGoalCompleted: isGoalCompleted,
                templateId: templateId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime datetime,
                required String type,
                required int durationMinutes,
                required String intensity,
                Value<String?> note = const Value.absent(),
                Value<bool> isGoalCompleted = const Value.absent(),
                Value<int?> templateId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TrainingSessionsCompanion.insert(
                id: id,
                datetime: datetime,
                type: type,
                durationMinutes: durationMinutes,
                intensity: intensity,
                note: note,
                isGoalCompleted: isGoalCompleted,
                templateId: templateId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrainingSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                templateId = false,
                strengthExerciseEntriesRefs = false,
                runningEntriesRefs = false,
                swimmingEntriesRefs = false,
                personalRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (strengthExerciseEntriesRefs) db.strengthExerciseEntries,
                    if (runningEntriesRefs) db.runningEntries,
                    if (swimmingEntriesRefs) db.swimmingEntries,
                    if (personalRecordsRefs) db.personalRecords,
                  ],
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
                        if (templateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.templateId,
                                    referencedTable:
                                        $$TrainingSessionsTableReferences
                                            ._templateIdTable(db),
                                    referencedColumn:
                                        $$TrainingSessionsTableReferences
                                            ._templateIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (strengthExerciseEntriesRefs)
                        await $_getPrefetchedData<
                          TrainingSession,
                          $TrainingSessionsTable,
                          StrengthExerciseEntry
                        >(
                          currentTable: table,
                          referencedTable: $$TrainingSessionsTableReferences
                              ._strengthExerciseEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrainingSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).strengthExerciseEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (runningEntriesRefs)
                        await $_getPrefetchedData<
                          TrainingSession,
                          $TrainingSessionsTable,
                          RunningEntry
                        >(
                          currentTable: table,
                          referencedTable: $$TrainingSessionsTableReferences
                              ._runningEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrainingSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).runningEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (swimmingEntriesRefs)
                        await $_getPrefetchedData<
                          TrainingSession,
                          $TrainingSessionsTable,
                          SwimmingEntry
                        >(
                          currentTable: table,
                          referencedTable: $$TrainingSessionsTableReferences
                              ._swimmingEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrainingSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).swimmingEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          TrainingSession,
                          $TrainingSessionsTable,
                          PersonalRecord
                        >(
                          currentTable: table,
                          referencedTable: $$TrainingSessionsTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrainingSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
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

typedef $$TrainingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingSessionsTable,
      TrainingSession,
      $$TrainingSessionsTableFilterComposer,
      $$TrainingSessionsTableOrderingComposer,
      $$TrainingSessionsTableAnnotationComposer,
      $$TrainingSessionsTableCreateCompanionBuilder,
      $$TrainingSessionsTableUpdateCompanionBuilder,
      (TrainingSession, $$TrainingSessionsTableReferences),
      TrainingSession,
      PrefetchHooks Function({
        bool templateId,
        bool strengthExerciseEntriesRefs,
        bool runningEntriesRefs,
        bool swimmingEntriesRefs,
        bool personalRecordsRefs,
      })
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required String name,
      required String category,
      Value<String> movementType,
      Value<String?> primaryMuscles,
      Value<String?> secondaryMuscles,
      Value<int> defaultSets,
      Value<int> defaultReps,
      Value<double?> defaultWeight,
      Value<bool> isCustom,
      Value<bool> isEnabled,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> category,
      Value<String> movementType,
      Value<String?> primaryMuscles,
      Value<String?> secondaryMuscles,
      Value<int> defaultSets,
      Value<int> defaultReps,
      Value<double?> defaultWeight,
      Value<bool> isCustom,
      Value<bool> isEnabled,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $StrengthExerciseEntriesTable,
    List<StrengthExerciseEntry>
  >
  _strengthExerciseEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.strengthExerciseEntries,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.strengthExerciseEntries.exerciseId,
        ),
      );

  $$StrengthExerciseEntriesTableProcessedTableManager
  get strengthExerciseEntriesRefs {
    final manager = $$StrengthExerciseEntriesTableTableManager(
      $_db,
      $_db.strengthExerciseEntries,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _strengthExerciseEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TemplateExercisesTable, List<TemplateExercise>>
  _templateExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.templateExercises,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.templateExercises.exerciseId,
        ),
      );

  $$TemplateExercisesTableProcessedTableManager get templateExercisesRefs {
    final manager = $$TemplateExercisesTableTableManager(
      $_db,
      $_db.templateExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _templateExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecord>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: $_aliasNameGenerator(
      db.exercises.id,
      db.personalRecords.exerciseId,
    ),
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultSets => $composableBuilder(
    column: $table.defaultSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultReps => $composableBuilder(
    column: $table.defaultReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultWeight => $composableBuilder(
    column: $table.defaultWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> strengthExerciseEntriesRefs(
    Expression<bool> Function($$StrengthExerciseEntriesTableFilterComposer f) f,
  ) {
    final $$StrengthExerciseEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strengthExerciseEntries,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrengthExerciseEntriesTableFilterComposer(
                $db: $db,
                $table: $db.strengthExerciseEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> templateExercisesRefs(
    Expression<bool> Function($$TemplateExercisesTableFilterComposer f) f,
  ) {
    final $$TemplateExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateExercisesTableFilterComposer(
            $db: $db,
            $table: $db.templateExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultSets => $composableBuilder(
    column: $table.defaultSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultReps => $composableBuilder(
    column: $table.defaultReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultWeight => $composableBuilder(
    column: $table.defaultWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultSets => $composableBuilder(
    column: $table.defaultSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultReps => $composableBuilder(
    column: $table.defaultReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultWeight => $composableBuilder(
    column: $table.defaultWeight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> strengthExerciseEntriesRefs<T extends Object>(
    Expression<T> Function($$StrengthExerciseEntriesTableAnnotationComposer a)
    f,
  ) {
    final $$StrengthExerciseEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.strengthExerciseEntries,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StrengthExerciseEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.strengthExerciseEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> templateExercisesRefs<T extends Object>(
    Expression<T> Function($$TemplateExercisesTableAnnotationComposer a) f,
  ) {
    final $$TemplateExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.templateExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.templateExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool strengthExerciseEntriesRefs,
            bool templateExercisesRefs,
            bool personalRecordsRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> movementType = const Value.absent(),
                Value<String?> primaryMuscles = const Value.absent(),
                Value<String?> secondaryMuscles = const Value.absent(),
                Value<int> defaultSets = const Value.absent(),
                Value<int> defaultReps = const Value.absent(),
                Value<double?> defaultWeight = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                category: category,
                movementType: movementType,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                defaultSets: defaultSets,
                defaultReps: defaultReps,
                defaultWeight: defaultWeight,
                isCustom: isCustom,
                isEnabled: isEnabled,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String category,
                Value<String> movementType = const Value.absent(),
                Value<String?> primaryMuscles = const Value.absent(),
                Value<String?> secondaryMuscles = const Value.absent(),
                Value<int> defaultSets = const Value.absent(),
                Value<int> defaultReps = const Value.absent(),
                Value<double?> defaultWeight = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                category: category,
                movementType: movementType,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                defaultSets: defaultSets,
                defaultReps: defaultReps,
                defaultWeight: defaultWeight,
                isCustom: isCustom,
                isEnabled: isEnabled,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                strengthExerciseEntriesRefs = false,
                templateExercisesRefs = false,
                personalRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (strengthExerciseEntriesRefs) db.strengthExerciseEntries,
                    if (templateExercisesRefs) db.templateExercises,
                    if (personalRecordsRefs) db.personalRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (strengthExerciseEntriesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          StrengthExerciseEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._strengthExerciseEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).strengthExerciseEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (templateExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          TemplateExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._templateExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).templateExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          PersonalRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
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

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool strengthExerciseEntriesRefs,
        bool templateExercisesRefs,
        bool personalRecordsRefs,
      })
    >;
typedef $$StrengthExerciseEntriesTableCreateCompanionBuilder =
    StrengthExerciseEntriesCompanion Function({
      Value<int> id,
      required int sessionId,
      Value<int?> exerciseId,
      required String exerciseName,
      required int sets,
      required int defaultReps,
      Value<double?> defaultWeight,
      Value<String?> repsPerSet,
      Value<String?> weightPerSet,
      Value<String?> setCompleted,
      Value<bool> isWarmup,
      Value<int?> rpe,
      Value<int?> restSeconds,
      Value<int> sortOrder,
      Value<String?> note,
    });
typedef $$StrengthExerciseEntriesTableUpdateCompanionBuilder =
    StrengthExerciseEntriesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int?> exerciseId,
      Value<String> exerciseName,
      Value<int> sets,
      Value<int> defaultReps,
      Value<double?> defaultWeight,
      Value<String?> repsPerSet,
      Value<String?> weightPerSet,
      Value<String?> setCompleted,
      Value<bool> isWarmup,
      Value<int?> rpe,
      Value<int?> restSeconds,
      Value<int> sortOrder,
      Value<String?> note,
    });

final class $$StrengthExerciseEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StrengthExerciseEntriesTable,
          StrengthExerciseEntry
        > {
  $$StrengthExerciseEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrainingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.trainingSessions.createAlias(
        $_aliasNameGenerator(
          db.strengthExerciseEntries.sessionId,
          db.trainingSessions.id,
        ),
      );

  $$TrainingSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$TrainingSessionsTableTableManager(
      $_db,
      $_db.trainingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(
          db.strengthExerciseEntries.exerciseId,
          db.exercises.id,
        ),
      );

  $$ExercisesTableProcessedTableManager? get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id');
    if ($_column == null) return null;
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StrengthExerciseEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $StrengthExerciseEntriesTable> {
  $$StrengthExerciseEntriesTableFilterComposer({
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

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultReps => $composableBuilder(
    column: $table.defaultReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultWeight => $composableBuilder(
    column: $table.defaultWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repsPerSet => $composableBuilder(
    column: $table.repsPerSet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightPerSet => $composableBuilder(
    column: $table.weightPerSet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setCompleted => $composableBuilder(
    column: $table.setCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$TrainingSessionsTableFilterComposer get sessionId {
    final $$TrainingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrengthExerciseEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrengthExerciseEntriesTable> {
  $$StrengthExerciseEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultReps => $composableBuilder(
    column: $table.defaultReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultWeight => $composableBuilder(
    column: $table.defaultWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repsPerSet => $composableBuilder(
    column: $table.repsPerSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightPerSet => $composableBuilder(
    column: $table.weightPerSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setCompleted => $composableBuilder(
    column: $table.setCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrainingSessionsTableOrderingComposer get sessionId {
    final $$TrainingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrengthExerciseEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrengthExerciseEntriesTable> {
  $$StrengthExerciseEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<int> get defaultReps => $composableBuilder(
    column: $table.defaultReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultWeight => $composableBuilder(
    column: $table.defaultWeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repsPerSet => $composableBuilder(
    column: $table.repsPerSet,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weightPerSet => $composableBuilder(
    column: $table.weightPerSet,
    builder: (column) => column,
  );

  GeneratedColumn<String> get setCompleted => $composableBuilder(
    column: $table.setCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWarmup =>
      $composableBuilder(column: $table.isWarmup, builder: (column) => column);

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$TrainingSessionsTableAnnotationComposer get sessionId {
    final $$TrainingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrengthExerciseEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrengthExerciseEntriesTable,
          StrengthExerciseEntry,
          $$StrengthExerciseEntriesTableFilterComposer,
          $$StrengthExerciseEntriesTableOrderingComposer,
          $$StrengthExerciseEntriesTableAnnotationComposer,
          $$StrengthExerciseEntriesTableCreateCompanionBuilder,
          $$StrengthExerciseEntriesTableUpdateCompanionBuilder,
          (StrengthExerciseEntry, $$StrengthExerciseEntriesTableReferences),
          StrengthExerciseEntry,
          PrefetchHooks Function({bool sessionId, bool exerciseId})
        > {
  $$StrengthExerciseEntriesTableTableManager(
    _$AppDatabase db,
    $StrengthExerciseEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrengthExerciseEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StrengthExerciseEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StrengthExerciseEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int?> exerciseId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<int> sets = const Value.absent(),
                Value<int> defaultReps = const Value.absent(),
                Value<double?> defaultWeight = const Value.absent(),
                Value<String?> repsPerSet = const Value.absent(),
                Value<String?> weightPerSet = const Value.absent(),
                Value<String?> setCompleted = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => StrengthExerciseEntriesCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                sets: sets,
                defaultReps: defaultReps,
                defaultWeight: defaultWeight,
                repsPerSet: repsPerSet,
                weightPerSet: weightPerSet,
                setCompleted: setCompleted,
                isWarmup: isWarmup,
                rpe: rpe,
                restSeconds: restSeconds,
                sortOrder: sortOrder,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                Value<int?> exerciseId = const Value.absent(),
                required String exerciseName,
                required int sets,
                required int defaultReps,
                Value<double?> defaultWeight = const Value.absent(),
                Value<String?> repsPerSet = const Value.absent(),
                Value<String?> weightPerSet = const Value.absent(),
                Value<String?> setCompleted = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => StrengthExerciseEntriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                sets: sets,
                defaultReps: defaultReps,
                defaultWeight: defaultWeight,
                repsPerSet: repsPerSet,
                weightPerSet: weightPerSet,
                setCompleted: setCompleted,
                isWarmup: isWarmup,
                rpe: rpe,
                restSeconds: restSeconds,
                sortOrder: sortOrder,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrengthExerciseEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, exerciseId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$StrengthExerciseEntriesTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$StrengthExerciseEntriesTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$StrengthExerciseEntriesTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$StrengthExerciseEntriesTableReferences
                                        ._exerciseIdTable(db)
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

typedef $$StrengthExerciseEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrengthExerciseEntriesTable,
      StrengthExerciseEntry,
      $$StrengthExerciseEntriesTableFilterComposer,
      $$StrengthExerciseEntriesTableOrderingComposer,
      $$StrengthExerciseEntriesTableAnnotationComposer,
      $$StrengthExerciseEntriesTableCreateCompanionBuilder,
      $$StrengthExerciseEntriesTableUpdateCompanionBuilder,
      (StrengthExerciseEntry, $$StrengthExerciseEntriesTableReferences),
      StrengthExerciseEntry,
      PrefetchHooks Function({bool sessionId, bool exerciseId})
    >;
typedef $$BackupRecordsTableCreateCompanionBuilder =
    BackupRecordsCompanion Function({
      Value<int> id,
      required int configId,
      required String providerType,
      required String targetPath,
      Value<DateTime> createdAt,
      required String status,
      Value<String?> checksum,
      Value<String?> metadataJson,
    });
typedef $$BackupRecordsTableUpdateCompanionBuilder =
    BackupRecordsCompanion Function({
      Value<int> id,
      Value<int> configId,
      Value<String> providerType,
      Value<String> targetPath,
      Value<DateTime> createdAt,
      Value<String> status,
      Value<String?> checksum,
      Value<String?> metadataJson,
    });

final class $$BackupRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $BackupRecordsTable, BackupRecord> {
  $$BackupRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BackupConfigurationsTable _configIdTable(_$AppDatabase db) =>
      db.backupConfigurations.createAlias(
        $_aliasNameGenerator(
          db.backupRecords.configId,
          db.backupConfigurations.id,
        ),
      );

  $$BackupConfigurationsTableProcessedTableManager get configId {
    final $_column = $_itemColumn<int>('config_id')!;

    final manager = $$BackupConfigurationsTableTableManager(
      $_db,
      $_db.backupConfigurations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_configIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BackupRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableFilterComposer({
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

  ColumnFilters<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetPath => $composableBuilder(
    column: $table.targetPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  $$BackupConfigurationsTableFilterComposer get configId {
    final $$BackupConfigurationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.configId,
      referencedTable: $db.backupConfigurations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BackupConfigurationsTableFilterComposer(
            $db: $db,
            $table: $db.backupConfigurations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BackupRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetPath => $composableBuilder(
    column: $table.targetPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$BackupConfigurationsTableOrderingComposer get configId {
    final $$BackupConfigurationsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.configId,
          referencedTable: $db.backupConfigurations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BackupConfigurationsTableOrderingComposer(
                $db: $db,
                $table: $db.backupConfigurations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$BackupRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupRecordsTable> {
  $$BackupRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetPath => $composableBuilder(
    column: $table.targetPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  $$BackupConfigurationsTableAnnotationComposer get configId {
    final $$BackupConfigurationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.configId,
          referencedTable: $db.backupConfigurations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BackupConfigurationsTableAnnotationComposer(
                $db: $db,
                $table: $db.backupConfigurations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$BackupRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupRecordsTable,
          BackupRecord,
          $$BackupRecordsTableFilterComposer,
          $$BackupRecordsTableOrderingComposer,
          $$BackupRecordsTableAnnotationComposer,
          $$BackupRecordsTableCreateCompanionBuilder,
          $$BackupRecordsTableUpdateCompanionBuilder,
          (BackupRecord, $$BackupRecordsTableReferences),
          BackupRecord,
          PrefetchHooks Function({bool configId})
        > {
  $$BackupRecordsTableTableManager(_$AppDatabase db, $BackupRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> configId = const Value.absent(),
                Value<String> providerType = const Value.absent(),
                Value<String> targetPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
              }) => BackupRecordsCompanion(
                id: id,
                configId: configId,
                providerType: providerType,
                targetPath: targetPath,
                createdAt: createdAt,
                status: status,
                checksum: checksum,
                metadataJson: metadataJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int configId,
                required String providerType,
                required String targetPath,
                Value<DateTime> createdAt = const Value.absent(),
                required String status,
                Value<String?> checksum = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
              }) => BackupRecordsCompanion.insert(
                id: id,
                configId: configId,
                providerType: providerType,
                targetPath: targetPath,
                createdAt: createdAt,
                status: status,
                checksum: checksum,
                metadataJson: metadataJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BackupRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({configId = false}) {
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
                    if (configId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.configId,
                                referencedTable: $$BackupRecordsTableReferences
                                    ._configIdTable(db),
                                referencedColumn: $$BackupRecordsTableReferences
                                    ._configIdTable(db)
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

typedef $$BackupRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupRecordsTable,
      BackupRecord,
      $$BackupRecordsTableFilterComposer,
      $$BackupRecordsTableOrderingComposer,
      $$BackupRecordsTableAnnotationComposer,
      $$BackupRecordsTableCreateCompanionBuilder,
      $$BackupRecordsTableUpdateCompanionBuilder,
      (BackupRecord, $$BackupRecordsTableReferences),
      BackupRecord,
      PrefetchHooks Function({bool configId})
    >;
typedef $$RunningEntriesTableCreateCompanionBuilder =
    RunningEntriesCompanion Function({
      Value<int> id,
      required int sessionId,
      required String runType,
      required double distanceMeters,
      required int durationSeconds,
      required int avgPaceSeconds,
      Value<int?> bestPaceSeconds,
      Value<int?> avgHeartRate,
      Value<int?> maxHeartRate,
      Value<int?> avgCadence,
      Value<int?> maxCadence,
      Value<double?> elevationGain,
      Value<double?> elevationLoss,
      Value<String?> footwear,
      Value<String?> weatherJson,
    });
typedef $$RunningEntriesTableUpdateCompanionBuilder =
    RunningEntriesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> runType,
      Value<double> distanceMeters,
      Value<int> durationSeconds,
      Value<int> avgPaceSeconds,
      Value<int?> bestPaceSeconds,
      Value<int?> avgHeartRate,
      Value<int?> maxHeartRate,
      Value<int?> avgCadence,
      Value<int?> maxCadence,
      Value<double?> elevationGain,
      Value<double?> elevationLoss,
      Value<String?> footwear,
      Value<String?> weatherJson,
    });

final class $$RunningEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $RunningEntriesTable, RunningEntry> {
  $$RunningEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrainingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.trainingSessions.createAlias(
        $_aliasNameGenerator(
          db.runningEntries.sessionId,
          db.trainingSessions.id,
        ),
      );

  $$TrainingSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$TrainingSessionsTableTableManager(
      $_db,
      $_db.trainingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RunningSplitsTable, List<RunningSplit>>
  _runningSplitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.runningSplits,
    aliasName: $_aliasNameGenerator(
      db.runningEntries.id,
      db.runningSplits.runningEntryId,
    ),
  );

  $$RunningSplitsTableProcessedTableManager get runningSplitsRefs {
    final manager = $$RunningSplitsTableTableManager(
      $_db,
      $_db.runningSplits,
    ).filter((f) => f.runningEntryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_runningSplitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RunningEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $RunningEntriesTable> {
  $$RunningEntriesTableFilterComposer({
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

  ColumnFilters<String> get runType => $composableBuilder(
    column: $table.runType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgPaceSeconds => $composableBuilder(
    column: $table.avgPaceSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestPaceSeconds => $composableBuilder(
    column: $table.bestPaceSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxCadence => $composableBuilder(
    column: $table.maxCadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGain => $composableBuilder(
    column: $table.elevationGain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationLoss => $composableBuilder(
    column: $table.elevationLoss,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get footwear => $composableBuilder(
    column: $table.footwear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherJson => $composableBuilder(
    column: $table.weatherJson,
    builder: (column) => ColumnFilters(column),
  );

  $$TrainingSessionsTableFilterComposer get sessionId {
    final $$TrainingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> runningSplitsRefs(
    Expression<bool> Function($$RunningSplitsTableFilterComposer f) f,
  ) {
    final $$RunningSplitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runningSplits,
      getReferencedColumn: (t) => t.runningEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunningSplitsTableFilterComposer(
            $db: $db,
            $table: $db.runningSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunningEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RunningEntriesTable> {
  $$RunningEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get runType => $composableBuilder(
    column: $table.runType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgPaceSeconds => $composableBuilder(
    column: $table.avgPaceSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestPaceSeconds => $composableBuilder(
    column: $table.bestPaceSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxCadence => $composableBuilder(
    column: $table.maxCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGain => $composableBuilder(
    column: $table.elevationGain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationLoss => $composableBuilder(
    column: $table.elevationLoss,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get footwear => $composableBuilder(
    column: $table.footwear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherJson => $composableBuilder(
    column: $table.weatherJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrainingSessionsTableOrderingComposer get sessionId {
    final $$TrainingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunningEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunningEntriesTable> {
  $$RunningEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get runType =>
      $composableBuilder(column: $table.runType, builder: (column) => column);

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgPaceSeconds => $composableBuilder(
    column: $table.avgPaceSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestPaceSeconds => $composableBuilder(
    column: $table.bestPaceSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxCadence => $composableBuilder(
    column: $table.maxCadence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGain => $composableBuilder(
    column: $table.elevationGain,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationLoss => $composableBuilder(
    column: $table.elevationLoss,
    builder: (column) => column,
  );

  GeneratedColumn<String> get footwear =>
      $composableBuilder(column: $table.footwear, builder: (column) => column);

  GeneratedColumn<String> get weatherJson => $composableBuilder(
    column: $table.weatherJson,
    builder: (column) => column,
  );

  $$TrainingSessionsTableAnnotationComposer get sessionId {
    final $$TrainingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> runningSplitsRefs<T extends Object>(
    Expression<T> Function($$RunningSplitsTableAnnotationComposer a) f,
  ) {
    final $$RunningSplitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runningSplits,
      getReferencedColumn: (t) => t.runningEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunningSplitsTableAnnotationComposer(
            $db: $db,
            $table: $db.runningSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunningEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunningEntriesTable,
          RunningEntry,
          $$RunningEntriesTableFilterComposer,
          $$RunningEntriesTableOrderingComposer,
          $$RunningEntriesTableAnnotationComposer,
          $$RunningEntriesTableCreateCompanionBuilder,
          $$RunningEntriesTableUpdateCompanionBuilder,
          (RunningEntry, $$RunningEntriesTableReferences),
          RunningEntry,
          PrefetchHooks Function({bool sessionId, bool runningSplitsRefs})
        > {
  $$RunningEntriesTableTableManager(
    _$AppDatabase db,
    $RunningEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunningEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunningEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunningEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> runType = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> avgPaceSeconds = const Value.absent(),
                Value<int?> bestPaceSeconds = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> maxHeartRate = const Value.absent(),
                Value<int?> avgCadence = const Value.absent(),
                Value<int?> maxCadence = const Value.absent(),
                Value<double?> elevationGain = const Value.absent(),
                Value<double?> elevationLoss = const Value.absent(),
                Value<String?> footwear = const Value.absent(),
                Value<String?> weatherJson = const Value.absent(),
              }) => RunningEntriesCompanion(
                id: id,
                sessionId: sessionId,
                runType: runType,
                distanceMeters: distanceMeters,
                durationSeconds: durationSeconds,
                avgPaceSeconds: avgPaceSeconds,
                bestPaceSeconds: bestPaceSeconds,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                avgCadence: avgCadence,
                maxCadence: maxCadence,
                elevationGain: elevationGain,
                elevationLoss: elevationLoss,
                footwear: footwear,
                weatherJson: weatherJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String runType,
                required double distanceMeters,
                required int durationSeconds,
                required int avgPaceSeconds,
                Value<int?> bestPaceSeconds = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> maxHeartRate = const Value.absent(),
                Value<int?> avgCadence = const Value.absent(),
                Value<int?> maxCadence = const Value.absent(),
                Value<double?> elevationGain = const Value.absent(),
                Value<double?> elevationLoss = const Value.absent(),
                Value<String?> footwear = const Value.absent(),
                Value<String?> weatherJson = const Value.absent(),
              }) => RunningEntriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                runType: runType,
                distanceMeters: distanceMeters,
                durationSeconds: durationSeconds,
                avgPaceSeconds: avgPaceSeconds,
                bestPaceSeconds: bestPaceSeconds,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                avgCadence: avgCadence,
                maxCadence: maxCadence,
                elevationGain: elevationGain,
                elevationLoss: elevationLoss,
                footwear: footwear,
                weatherJson: weatherJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RunningEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, runningSplitsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (runningSplitsRefs) db.runningSplits,
                  ],
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
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$RunningEntriesTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$RunningEntriesTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (runningSplitsRefs)
                        await $_getPrefetchedData<
                          RunningEntry,
                          $RunningEntriesTable,
                          RunningSplit
                        >(
                          currentTable: table,
                          referencedTable: $$RunningEntriesTableReferences
                              ._runningSplitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RunningEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).runningSplitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.runningEntryId == item.id,
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

typedef $$RunningEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunningEntriesTable,
      RunningEntry,
      $$RunningEntriesTableFilterComposer,
      $$RunningEntriesTableOrderingComposer,
      $$RunningEntriesTableAnnotationComposer,
      $$RunningEntriesTableCreateCompanionBuilder,
      $$RunningEntriesTableUpdateCompanionBuilder,
      (RunningEntry, $$RunningEntriesTableReferences),
      RunningEntry,
      PrefetchHooks Function({bool sessionId, bool runningSplitsRefs})
    >;
typedef $$RunningSplitsTableCreateCompanionBuilder =
    RunningSplitsCompanion Function({
      Value<int> id,
      required int runningEntryId,
      required int splitNumber,
      required double distanceMeters,
      required int durationSeconds,
      required int paceSeconds,
      Value<int?> avgHeartRate,
      Value<int?> cadence,
      Value<double?> elevationGain,
      Value<bool> isManual,
    });
typedef $$RunningSplitsTableUpdateCompanionBuilder =
    RunningSplitsCompanion Function({
      Value<int> id,
      Value<int> runningEntryId,
      Value<int> splitNumber,
      Value<double> distanceMeters,
      Value<int> durationSeconds,
      Value<int> paceSeconds,
      Value<int?> avgHeartRate,
      Value<int?> cadence,
      Value<double?> elevationGain,
      Value<bool> isManual,
    });

final class $$RunningSplitsTableReferences
    extends BaseReferences<_$AppDatabase, $RunningSplitsTable, RunningSplit> {
  $$RunningSplitsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RunningEntriesTable _runningEntryIdTable(_$AppDatabase db) =>
      db.runningEntries.createAlias(
        $_aliasNameGenerator(
          db.runningSplits.runningEntryId,
          db.runningEntries.id,
        ),
      );

  $$RunningEntriesTableProcessedTableManager get runningEntryId {
    final $_column = $_itemColumn<int>('running_entry_id')!;

    final manager = $$RunningEntriesTableTableManager(
      $_db,
      $_db.runningEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runningEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RunningSplitsTableFilterComposer
    extends Composer<_$AppDatabase, $RunningSplitsTable> {
  $$RunningSplitsTableFilterComposer({
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

  ColumnFilters<int> get splitNumber => $composableBuilder(
    column: $table.splitNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paceSeconds => $composableBuilder(
    column: $table.paceSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGain => $composableBuilder(
    column: $table.elevationGain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnFilters(column),
  );

  $$RunningEntriesTableFilterComposer get runningEntryId {
    final $$RunningEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runningEntryId,
      referencedTable: $db.runningEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunningEntriesTableFilterComposer(
            $db: $db,
            $table: $db.runningEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunningSplitsTableOrderingComposer
    extends Composer<_$AppDatabase, $RunningSplitsTable> {
  $$RunningSplitsTableOrderingComposer({
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

  ColumnOrderings<int> get splitNumber => $composableBuilder(
    column: $table.splitNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paceSeconds => $composableBuilder(
    column: $table.paceSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGain => $composableBuilder(
    column: $table.elevationGain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunningEntriesTableOrderingComposer get runningEntryId {
    final $$RunningEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runningEntryId,
      referencedTable: $db.runningEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunningEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.runningEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunningSplitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunningSplitsTable> {
  $$RunningSplitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get splitNumber => $composableBuilder(
    column: $table.splitNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paceSeconds => $composableBuilder(
    column: $table.paceSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => column);

  GeneratedColumn<double> get elevationGain => $composableBuilder(
    column: $table.elevationGain,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  $$RunningEntriesTableAnnotationComposer get runningEntryId {
    final $$RunningEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runningEntryId,
      referencedTable: $db.runningEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunningEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.runningEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunningSplitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunningSplitsTable,
          RunningSplit,
          $$RunningSplitsTableFilterComposer,
          $$RunningSplitsTableOrderingComposer,
          $$RunningSplitsTableAnnotationComposer,
          $$RunningSplitsTableCreateCompanionBuilder,
          $$RunningSplitsTableUpdateCompanionBuilder,
          (RunningSplit, $$RunningSplitsTableReferences),
          RunningSplit,
          PrefetchHooks Function({bool runningEntryId})
        > {
  $$RunningSplitsTableTableManager(_$AppDatabase db, $RunningSplitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunningSplitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunningSplitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunningSplitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runningEntryId = const Value.absent(),
                Value<int> splitNumber = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> paceSeconds = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> cadence = const Value.absent(),
                Value<double?> elevationGain = const Value.absent(),
                Value<bool> isManual = const Value.absent(),
              }) => RunningSplitsCompanion(
                id: id,
                runningEntryId: runningEntryId,
                splitNumber: splitNumber,
                distanceMeters: distanceMeters,
                durationSeconds: durationSeconds,
                paceSeconds: paceSeconds,
                avgHeartRate: avgHeartRate,
                cadence: cadence,
                elevationGain: elevationGain,
                isManual: isManual,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int runningEntryId,
                required int splitNumber,
                required double distanceMeters,
                required int durationSeconds,
                required int paceSeconds,
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> cadence = const Value.absent(),
                Value<double?> elevationGain = const Value.absent(),
                Value<bool> isManual = const Value.absent(),
              }) => RunningSplitsCompanion.insert(
                id: id,
                runningEntryId: runningEntryId,
                splitNumber: splitNumber,
                distanceMeters: distanceMeters,
                durationSeconds: durationSeconds,
                paceSeconds: paceSeconds,
                avgHeartRate: avgHeartRate,
                cadence: cadence,
                elevationGain: elevationGain,
                isManual: isManual,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RunningSplitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({runningEntryId = false}) {
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
                    if (runningEntryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.runningEntryId,
                                referencedTable: $$RunningSplitsTableReferences
                                    ._runningEntryIdTable(db),
                                referencedColumn: $$RunningSplitsTableReferences
                                    ._runningEntryIdTable(db)
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

typedef $$RunningSplitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunningSplitsTable,
      RunningSplit,
      $$RunningSplitsTableFilterComposer,
      $$RunningSplitsTableOrderingComposer,
      $$RunningSplitsTableAnnotationComposer,
      $$RunningSplitsTableCreateCompanionBuilder,
      $$RunningSplitsTableUpdateCompanionBuilder,
      (RunningSplit, $$RunningSplitsTableReferences),
      RunningSplit,
      PrefetchHooks Function({bool runningEntryId})
    >;
typedef $$SwimmingEntriesTableCreateCompanionBuilder =
    SwimmingEntriesCompanion Function({
      Value<int> id,
      required int sessionId,
      required String environment,
      Value<int?> poolLengthMeters,
      required String primaryStroke,
      required double distanceMeters,
      required int durationSeconds,
      required int pacePer100m,
      Value<String?> trainingType,
      Value<String?> equipment,
    });
typedef $$SwimmingEntriesTableUpdateCompanionBuilder =
    SwimmingEntriesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> environment,
      Value<int?> poolLengthMeters,
      Value<String> primaryStroke,
      Value<double> distanceMeters,
      Value<int> durationSeconds,
      Value<int> pacePer100m,
      Value<String?> trainingType,
      Value<String?> equipment,
    });

final class $$SwimmingEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $SwimmingEntriesTable, SwimmingEntry> {
  $$SwimmingEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrainingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.trainingSessions.createAlias(
        $_aliasNameGenerator(
          db.swimmingEntries.sessionId,
          db.trainingSessions.id,
        ),
      );

  $$TrainingSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$TrainingSessionsTableTableManager(
      $_db,
      $_db.trainingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SwimmingSetsTable, List<SwimmingSet>>
  _swimmingSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.swimmingSets,
    aliasName: $_aliasNameGenerator(
      db.swimmingEntries.id,
      db.swimmingSets.swimmingEntryId,
    ),
  );

  $$SwimmingSetsTableProcessedTableManager get swimmingSetsRefs {
    final manager = $$SwimmingSetsTableTableManager(
      $_db,
      $_db.swimmingSets,
    ).filter((f) => f.swimmingEntryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_swimmingSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SwimmingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SwimmingEntriesTable> {
  $$SwimmingEntriesTableFilterComposer({
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

  ColumnFilters<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get poolLengthMeters => $composableBuilder(
    column: $table.poolLengthMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryStroke => $composableBuilder(
    column: $table.primaryStroke,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pacePer100m => $composableBuilder(
    column: $table.pacePer100m,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trainingType => $composableBuilder(
    column: $table.trainingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  $$TrainingSessionsTableFilterComposer get sessionId {
    final $$TrainingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> swimmingSetsRefs(
    Expression<bool> Function($$SwimmingSetsTableFilterComposer f) f,
  ) {
    final $$SwimmingSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.swimmingSets,
      getReferencedColumn: (t) => t.swimmingEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SwimmingSetsTableFilterComposer(
            $db: $db,
            $table: $db.swimmingSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SwimmingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SwimmingEntriesTable> {
  $$SwimmingEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get poolLengthMeters => $composableBuilder(
    column: $table.poolLengthMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryStroke => $composableBuilder(
    column: $table.primaryStroke,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pacePer100m => $composableBuilder(
    column: $table.pacePer100m,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trainingType => $composableBuilder(
    column: $table.trainingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrainingSessionsTableOrderingComposer get sessionId {
    final $$TrainingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SwimmingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SwimmingEntriesTable> {
  $$SwimmingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get poolLengthMeters => $composableBuilder(
    column: $table.poolLengthMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryStroke => $composableBuilder(
    column: $table.primaryStroke,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pacePer100m => $composableBuilder(
    column: $table.pacePer100m,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trainingType => $composableBuilder(
    column: $table.trainingType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  $$TrainingSessionsTableAnnotationComposer get sessionId {
    final $$TrainingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> swimmingSetsRefs<T extends Object>(
    Expression<T> Function($$SwimmingSetsTableAnnotationComposer a) f,
  ) {
    final $$SwimmingSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.swimmingSets,
      getReferencedColumn: (t) => t.swimmingEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SwimmingSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.swimmingSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SwimmingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SwimmingEntriesTable,
          SwimmingEntry,
          $$SwimmingEntriesTableFilterComposer,
          $$SwimmingEntriesTableOrderingComposer,
          $$SwimmingEntriesTableAnnotationComposer,
          $$SwimmingEntriesTableCreateCompanionBuilder,
          $$SwimmingEntriesTableUpdateCompanionBuilder,
          (SwimmingEntry, $$SwimmingEntriesTableReferences),
          SwimmingEntry,
          PrefetchHooks Function({bool sessionId, bool swimmingSetsRefs})
        > {
  $$SwimmingEntriesTableTableManager(
    _$AppDatabase db,
    $SwimmingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SwimmingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SwimmingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SwimmingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> environment = const Value.absent(),
                Value<int?> poolLengthMeters = const Value.absent(),
                Value<String> primaryStroke = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> pacePer100m = const Value.absent(),
                Value<String?> trainingType = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
              }) => SwimmingEntriesCompanion(
                id: id,
                sessionId: sessionId,
                environment: environment,
                poolLengthMeters: poolLengthMeters,
                primaryStroke: primaryStroke,
                distanceMeters: distanceMeters,
                durationSeconds: durationSeconds,
                pacePer100m: pacePer100m,
                trainingType: trainingType,
                equipment: equipment,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String environment,
                Value<int?> poolLengthMeters = const Value.absent(),
                required String primaryStroke,
                required double distanceMeters,
                required int durationSeconds,
                required int pacePer100m,
                Value<String?> trainingType = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
              }) => SwimmingEntriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                environment: environment,
                poolLengthMeters: poolLengthMeters,
                primaryStroke: primaryStroke,
                distanceMeters: distanceMeters,
                durationSeconds: durationSeconds,
                pacePer100m: pacePer100m,
                trainingType: trainingType,
                equipment: equipment,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SwimmingEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, swimmingSetsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (swimmingSetsRefs) db.swimmingSets,
                  ],
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
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$SwimmingEntriesTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$SwimmingEntriesTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (swimmingSetsRefs)
                        await $_getPrefetchedData<
                          SwimmingEntry,
                          $SwimmingEntriesTable,
                          SwimmingSet
                        >(
                          currentTable: table,
                          referencedTable: $$SwimmingEntriesTableReferences
                              ._swimmingSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SwimmingEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).swimmingSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.swimmingEntryId == item.id,
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

typedef $$SwimmingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SwimmingEntriesTable,
      SwimmingEntry,
      $$SwimmingEntriesTableFilterComposer,
      $$SwimmingEntriesTableOrderingComposer,
      $$SwimmingEntriesTableAnnotationComposer,
      $$SwimmingEntriesTableCreateCompanionBuilder,
      $$SwimmingEntriesTableUpdateCompanionBuilder,
      (SwimmingEntry, $$SwimmingEntriesTableReferences),
      SwimmingEntry,
      PrefetchHooks Function({bool sessionId, bool swimmingSetsRefs})
    >;
typedef $$SwimmingSetsTableCreateCompanionBuilder =
    SwimmingSetsCompanion Function({
      Value<int> id,
      required int swimmingEntryId,
      required String setType,
      Value<String?> description,
      required double distanceMeters,
      required int durationSeconds,
      Value<int> sortOrder,
    });
typedef $$SwimmingSetsTableUpdateCompanionBuilder =
    SwimmingSetsCompanion Function({
      Value<int> id,
      Value<int> swimmingEntryId,
      Value<String> setType,
      Value<String?> description,
      Value<double> distanceMeters,
      Value<int> durationSeconds,
      Value<int> sortOrder,
    });

final class $$SwimmingSetsTableReferences
    extends BaseReferences<_$AppDatabase, $SwimmingSetsTable, SwimmingSet> {
  $$SwimmingSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SwimmingEntriesTable _swimmingEntryIdTable(_$AppDatabase db) =>
      db.swimmingEntries.createAlias(
        $_aliasNameGenerator(
          db.swimmingSets.swimmingEntryId,
          db.swimmingEntries.id,
        ),
      );

  $$SwimmingEntriesTableProcessedTableManager get swimmingEntryId {
    final $_column = $_itemColumn<int>('swimming_entry_id')!;

    final manager = $$SwimmingEntriesTableTableManager(
      $_db,
      $_db.swimmingEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_swimmingEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SwimmingSetsTableFilterComposer
    extends Composer<_$AppDatabase, $SwimmingSetsTable> {
  $$SwimmingSetsTableFilterComposer({
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

  ColumnFilters<String> get setType => $composableBuilder(
    column: $table.setType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$SwimmingEntriesTableFilterComposer get swimmingEntryId {
    final $$SwimmingEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.swimmingEntryId,
      referencedTable: $db.swimmingEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SwimmingEntriesTableFilterComposer(
            $db: $db,
            $table: $db.swimmingEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SwimmingSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SwimmingSetsTable> {
  $$SwimmingSetsTableOrderingComposer({
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

  ColumnOrderings<String> get setType => $composableBuilder(
    column: $table.setType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$SwimmingEntriesTableOrderingComposer get swimmingEntryId {
    final $$SwimmingEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.swimmingEntryId,
      referencedTable: $db.swimmingEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SwimmingEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.swimmingEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SwimmingSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SwimmingSetsTable> {
  $$SwimmingSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get setType =>
      $composableBuilder(column: $table.setType, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$SwimmingEntriesTableAnnotationComposer get swimmingEntryId {
    final $$SwimmingEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.swimmingEntryId,
      referencedTable: $db.swimmingEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SwimmingEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.swimmingEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SwimmingSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SwimmingSetsTable,
          SwimmingSet,
          $$SwimmingSetsTableFilterComposer,
          $$SwimmingSetsTableOrderingComposer,
          $$SwimmingSetsTableAnnotationComposer,
          $$SwimmingSetsTableCreateCompanionBuilder,
          $$SwimmingSetsTableUpdateCompanionBuilder,
          (SwimmingSet, $$SwimmingSetsTableReferences),
          SwimmingSet,
          PrefetchHooks Function({bool swimmingEntryId})
        > {
  $$SwimmingSetsTableTableManager(_$AppDatabase db, $SwimmingSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SwimmingSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SwimmingSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SwimmingSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> swimmingEntryId = const Value.absent(),
                Value<String> setType = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SwimmingSetsCompanion(
                id: id,
                swimmingEntryId: swimmingEntryId,
                setType: setType,
                description: description,
                distanceMeters: distanceMeters,
                durationSeconds: durationSeconds,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int swimmingEntryId,
                required String setType,
                Value<String?> description = const Value.absent(),
                required double distanceMeters,
                required int durationSeconds,
                Value<int> sortOrder = const Value.absent(),
              }) => SwimmingSetsCompanion.insert(
                id: id,
                swimmingEntryId: swimmingEntryId,
                setType: setType,
                description: description,
                distanceMeters: distanceMeters,
                durationSeconds: durationSeconds,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SwimmingSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({swimmingEntryId = false}) {
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
                    if (swimmingEntryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.swimmingEntryId,
                                referencedTable: $$SwimmingSetsTableReferences
                                    ._swimmingEntryIdTable(db),
                                referencedColumn: $$SwimmingSetsTableReferences
                                    ._swimmingEntryIdTable(db)
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

typedef $$SwimmingSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SwimmingSetsTable,
      SwimmingSet,
      $$SwimmingSetsTableFilterComposer,
      $$SwimmingSetsTableOrderingComposer,
      $$SwimmingSetsTableAnnotationComposer,
      $$SwimmingSetsTableCreateCompanionBuilder,
      $$SwimmingSetsTableUpdateCompanionBuilder,
      (SwimmingSet, $$SwimmingSetsTableReferences),
      SwimmingSet,
      PrefetchHooks Function({bool swimmingEntryId})
    >;
typedef $$TemplateExercisesTableCreateCompanionBuilder =
    TemplateExercisesCompanion Function({
      Value<int> id,
      required int templateId,
      Value<int?> exerciseId,
      required String exerciseName,
      required int sets,
      required int reps,
      Value<double?> weight,
      Value<int> sortOrder,
    });
typedef $$TemplateExercisesTableUpdateCompanionBuilder =
    TemplateExercisesCompanion Function({
      Value<int> id,
      Value<int> templateId,
      Value<int?> exerciseId,
      Value<String> exerciseName,
      Value<int> sets,
      Value<int> reps,
      Value<double?> weight,
      Value<int> sortOrder,
    });

final class $$TemplateExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TemplateExercisesTable,
          TemplateExercise
        > {
  $$TemplateExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutTemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.workoutTemplates.createAlias(
        $_aliasNameGenerator(
          db.templateExercises.templateId,
          db.workoutTemplates.id,
        ),
      );

  $$WorkoutTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<int>('template_id')!;

    final manager = $$WorkoutTemplatesTableTableManager(
      $_db,
      $_db.workoutTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.templateExercises.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager? get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id');
    if ($_column == null) return null;
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TemplateExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $TemplateExercisesTable> {
  $$TemplateExercisesTableFilterComposer({
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

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutTemplatesTableFilterComposer get templateId {
    final $$WorkoutTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplateExercisesTable> {
  $$TemplateExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutTemplatesTableOrderingComposer get templateId {
    final $$WorkoutTemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplateExercisesTable> {
  $$TemplateExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$WorkoutTemplatesTableAnnotationComposer get templateId {
    final $$WorkoutTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemplateExercisesTable,
          TemplateExercise,
          $$TemplateExercisesTableFilterComposer,
          $$TemplateExercisesTableOrderingComposer,
          $$TemplateExercisesTableAnnotationComposer,
          $$TemplateExercisesTableCreateCompanionBuilder,
          $$TemplateExercisesTableUpdateCompanionBuilder,
          (TemplateExercise, $$TemplateExercisesTableReferences),
          TemplateExercise,
          PrefetchHooks Function({bool templateId, bool exerciseId})
        > {
  $$TemplateExercisesTableTableManager(
    _$AppDatabase db,
    $TemplateExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> templateId = const Value.absent(),
                Value<int?> exerciseId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<int> sets = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TemplateExercisesCompanion(
                id: id,
                templateId: templateId,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                sets: sets,
                reps: reps,
                weight: weight,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int templateId,
                Value<int?> exerciseId = const Value.absent(),
                required String exerciseName,
                required int sets,
                required int reps,
                Value<double?> weight = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TemplateExercisesCompanion.insert(
                id: id,
                templateId: templateId,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                sets: sets,
                reps: reps,
                weight: weight,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TemplateExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({templateId = false, exerciseId = false}) {
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
                    if (templateId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.templateId,
                                referencedTable:
                                    $$TemplateExercisesTableReferences
                                        ._templateIdTable(db),
                                referencedColumn:
                                    $$TemplateExercisesTableReferences
                                        ._templateIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$TemplateExercisesTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$TemplateExercisesTableReferences
                                        ._exerciseIdTable(db)
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

typedef $$TemplateExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemplateExercisesTable,
      TemplateExercise,
      $$TemplateExercisesTableFilterComposer,
      $$TemplateExercisesTableOrderingComposer,
      $$TemplateExercisesTableAnnotationComposer,
      $$TemplateExercisesTableCreateCompanionBuilder,
      $$TemplateExercisesTableUpdateCompanionBuilder,
      (TemplateExercise, $$TemplateExercisesTableReferences),
      TemplateExercise,
      PrefetchHooks Function({bool templateId, bool exerciseId})
    >;
typedef $$PersonalRecordsTableCreateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<int> id,
      required String recordType,
      Value<int?> exerciseId,
      required double value,
      required String unit,
      required DateTime achievedAt,
      Value<int?> sessionId,
      Value<DateTime> createdAt,
    });
typedef $$PersonalRecordsTableUpdateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<int> id,
      Value<String> recordType,
      Value<int?> exerciseId,
      Value<double> value,
      Value<String> unit,
      Value<DateTime> achievedAt,
      Value<int?> sessionId,
      Value<DateTime> createdAt,
    });

final class $$PersonalRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PersonalRecordsTable, PersonalRecord> {
  $$PersonalRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.personalRecords.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager? get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id');
    if ($_column == null) return null;
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TrainingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.trainingSessions.createAlias(
        $_aliasNameGenerator(
          db.personalRecords.sessionId,
          db.trainingSessions.id,
        ),
      );

  $$TrainingSessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$TrainingSessionsTableTableManager(
      $_db,
      $_db.trainingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableFilterComposer({
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

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrainingSessionsTableFilterComposer get sessionId {
    final $$TrainingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrainingSessionsTableOrderingComposer get sessionId {
    final $$TrainingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrainingSessionsTableAnnotationComposer get sessionId {
    final $$TrainingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trainingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecord,
          $$PersonalRecordsTableFilterComposer,
          $$PersonalRecordsTableOrderingComposer,
          $$PersonalRecordsTableAnnotationComposer,
          $$PersonalRecordsTableCreateCompanionBuilder,
          $$PersonalRecordsTableUpdateCompanionBuilder,
          (PersonalRecord, $$PersonalRecordsTableReferences),
          PersonalRecord,
          PrefetchHooks Function({bool exerciseId, bool sessionId})
        > {
  $$PersonalRecordsTableTableManager(
    _$AppDatabase db,
    $PersonalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<int?> exerciseId = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime> achievedAt = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PersonalRecordsCompanion(
                id: id,
                recordType: recordType,
                exerciseId: exerciseId,
                value: value,
                unit: unit,
                achievedAt: achievedAt,
                sessionId: sessionId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recordType,
                Value<int?> exerciseId = const Value.absent(),
                required double value,
                required String unit,
                required DateTime achievedAt,
                Value<int?> sessionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PersonalRecordsCompanion.insert(
                id: id,
                recordType: recordType,
                exerciseId: exerciseId,
                value: value,
                unit: unit,
                achievedAt: achievedAt,
                sessionId: sessionId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, sessionId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$PersonalRecordsTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$PersonalRecordsTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$PersonalRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$PersonalRecordsTableReferences
                                        ._sessionIdTable(db)
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

typedef $$PersonalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalRecordsTable,
      PersonalRecord,
      $$PersonalRecordsTableFilterComposer,
      $$PersonalRecordsTableOrderingComposer,
      $$PersonalRecordsTableAnnotationComposer,
      $$PersonalRecordsTableCreateCompanionBuilder,
      $$PersonalRecordsTableUpdateCompanionBuilder,
      (PersonalRecord, $$PersonalRecordsTableReferences),
      PersonalRecord,
      PrefetchHooks Function({bool exerciseId, bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BackupConfigurationsTableTableManager get backupConfigurations =>
      $$BackupConfigurationsTableTableManager(_db, _db.backupConfigurations);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$WorkoutTemplatesTableTableManager get workoutTemplates =>
      $$WorkoutTemplatesTableTableManager(_db, _db.workoutTemplates);
  $$TrainingSessionsTableTableManager get trainingSessions =>
      $$TrainingSessionsTableTableManager(_db, _db.trainingSessions);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$StrengthExerciseEntriesTableTableManager get strengthExerciseEntries =>
      $$StrengthExerciseEntriesTableTableManager(
        _db,
        _db.strengthExerciseEntries,
      );
  $$BackupRecordsTableTableManager get backupRecords =>
      $$BackupRecordsTableTableManager(_db, _db.backupRecords);
  $$RunningEntriesTableTableManager get runningEntries =>
      $$RunningEntriesTableTableManager(_db, _db.runningEntries);
  $$RunningSplitsTableTableManager get runningSplits =>
      $$RunningSplitsTableTableManager(_db, _db.runningSplits);
  $$SwimmingEntriesTableTableManager get swimmingEntries =>
      $$SwimmingEntriesTableTableManager(_db, _db.swimmingEntries);
  $$SwimmingSetsTableTableManager get swimmingSets =>
      $$SwimmingSetsTableTableManager(_db, _db.swimmingSets);
  $$TemplateExercisesTableTableManager get templateExercises =>
      $$TemplateExercisesTableTableManager(_db, _db.templateExercises);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(_db, _db.personalRecords);
}
