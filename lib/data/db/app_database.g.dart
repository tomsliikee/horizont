// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TabsTable extends Tabs with TableInfo<$TabsTable, Tab> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pageColorMeta = const VerificationMeta(
    'pageColor',
  );
  @override
  late final GeneratedColumn<int> pageColor = GeneratedColumn<int>(
    'page_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openerIdMeta = const VerificationMeta(
    'openerId',
  );
  @override
  late final GeneratedColumn<String> openerId = GeneratedColumn<String>(
    'opener_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tabs (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastActiveAtMeta = const VerificationMeta(
    'lastActiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveAt = GeneratedColumn<DateTime>(
    'last_active_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scrollYMeta = const VerificationMeta(
    'scrollY',
  );
  @override
  late final GeneratedColumn<double> scrollY = GeneratedColumn<double>(
    'scroll_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    title,
    pageColor,
    openerId,
    groupId,
    groupName,
    position,
    createdAt,
    lastActiveAt,
    scrollY,
    thumbnailPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tab> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('page_color')) {
      context.handle(
        _pageColorMeta,
        pageColor.isAcceptableOrUnknown(data['page_color']!, _pageColorMeta),
      );
    }
    if (data.containsKey('opener_id')) {
      context.handle(
        _openerIdMeta,
        openerId.isAcceptableOrUnknown(data['opener_id']!, _openerIdMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_active_at')) {
      context.handle(
        _lastActiveAtMeta,
        lastActiveAt.isAcceptableOrUnknown(
          data['last_active_at']!,
          _lastActiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastActiveAtMeta);
    }
    if (data.containsKey('scroll_y')) {
      context.handle(
        _scrollYMeta,
        scrollY.isAcceptableOrUnknown(data['scroll_y']!, _scrollYMeta),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tab map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tab(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      pageColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_color'],
      ),
      openerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opener_id'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastActiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_at'],
      )!,
      scrollY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scroll_y'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
    );
  }

  @override
  $TabsTable createAlias(String alias) {
    return $TabsTable(attachedDatabase, alias);
  }
}

class Tab extends DataClass implements Insertable<Tab> {
  final String id;
  final String? url;
  final String title;
  final int? pageColor;
  final String? openerId;
  final String? groupId;
  final String? groupName;
  final int position;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final double? scrollY;
  final String? thumbnailPath;
  const Tab({
    required this.id,
    this.url,
    required this.title,
    this.pageColor,
    this.openerId,
    this.groupId,
    this.groupName,
    required this.position,
    required this.createdAt,
    required this.lastActiveAt,
    this.scrollY,
    this.thumbnailPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || pageColor != null) {
      map['page_color'] = Variable<int>(pageColor);
    }
    if (!nullToAbsent || openerId != null) {
      map['opener_id'] = Variable<String>(openerId);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_active_at'] = Variable<DateTime>(lastActiveAt);
    if (!nullToAbsent || scrollY != null) {
      map['scroll_y'] = Variable<double>(scrollY);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    return map;
  }

  TabsCompanion toCompanion(bool nullToAbsent) {
    return TabsCompanion(
      id: Value(id),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      title: Value(title),
      pageColor: pageColor == null && nullToAbsent
          ? const Value.absent()
          : Value(pageColor),
      openerId: openerId == null && nullToAbsent
          ? const Value.absent()
          : Value(openerId),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
      position: Value(position),
      createdAt: Value(createdAt),
      lastActiveAt: Value(lastActiveAt),
      scrollY: scrollY == null && nullToAbsent
          ? const Value.absent()
          : Value(scrollY),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
    );
  }

  factory Tab.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tab(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String?>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      pageColor: serializer.fromJson<int?>(json['pageColor']),
      openerId: serializer.fromJson<String?>(json['openerId']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      groupName: serializer.fromJson<String?>(json['groupName']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastActiveAt: serializer.fromJson<DateTime>(json['lastActiveAt']),
      scrollY: serializer.fromJson<double?>(json['scrollY']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String?>(url),
      'title': serializer.toJson<String>(title),
      'pageColor': serializer.toJson<int?>(pageColor),
      'openerId': serializer.toJson<String?>(openerId),
      'groupId': serializer.toJson<String?>(groupId),
      'groupName': serializer.toJson<String?>(groupName),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastActiveAt': serializer.toJson<DateTime>(lastActiveAt),
      'scrollY': serializer.toJson<double?>(scrollY),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
    };
  }

  Tab copyWith({
    String? id,
    Value<String?> url = const Value.absent(),
    String? title,
    Value<int?> pageColor = const Value.absent(),
    Value<String?> openerId = const Value.absent(),
    Value<String?> groupId = const Value.absent(),
    Value<String?> groupName = const Value.absent(),
    int? position,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Value<double?> scrollY = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
  }) => Tab(
    id: id ?? this.id,
    url: url.present ? url.value : this.url,
    title: title ?? this.title,
    pageColor: pageColor.present ? pageColor.value : this.pageColor,
    openerId: openerId.present ? openerId.value : this.openerId,
    groupId: groupId.present ? groupId.value : this.groupId,
    groupName: groupName.present ? groupName.value : this.groupName,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    scrollY: scrollY.present ? scrollY.value : this.scrollY,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
  );
  Tab copyWithCompanion(TabsCompanion data) {
    return Tab(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      pageColor: data.pageColor.present ? data.pageColor.value : this.pageColor,
      openerId: data.openerId.present ? data.openerId.value : this.openerId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastActiveAt: data.lastActiveAt.present
          ? data.lastActiveAt.value
          : this.lastActiveAt,
      scrollY: data.scrollY.present ? data.scrollY.value : this.scrollY,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tab(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('pageColor: $pageColor, ')
          ..write('openerId: $openerId, ')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('scrollY: $scrollY, ')
          ..write('thumbnailPath: $thumbnailPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    title,
    pageColor,
    openerId,
    groupId,
    groupName,
    position,
    createdAt,
    lastActiveAt,
    scrollY,
    thumbnailPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tab &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.pageColor == this.pageColor &&
          other.openerId == this.openerId &&
          other.groupId == this.groupId &&
          other.groupName == this.groupName &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.lastActiveAt == this.lastActiveAt &&
          other.scrollY == this.scrollY &&
          other.thumbnailPath == this.thumbnailPath);
}

class TabsCompanion extends UpdateCompanion<Tab> {
  final Value<String> id;
  final Value<String?> url;
  final Value<String> title;
  final Value<int?> pageColor;
  final Value<String?> openerId;
  final Value<String?> groupId;
  final Value<String?> groupName;
  final Value<int> position;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastActiveAt;
  final Value<double?> scrollY;
  final Value<String?> thumbnailPath;
  final Value<int> rowid;
  const TabsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.pageColor = const Value.absent(),
    this.openerId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupName = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
    this.scrollY = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabsCompanion.insert({
    required String id,
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.pageColor = const Value.absent(),
    this.openerId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupName = const Value.absent(),
    required int position,
    required DateTime createdAt,
    required DateTime lastActiveAt,
    this.scrollY = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       position = Value(position),
       createdAt = Value(createdAt),
       lastActiveAt = Value(lastActiveAt);
  static Insertable<Tab> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<int>? pageColor,
    Expression<String>? openerId,
    Expression<String>? groupId,
    Expression<String>? groupName,
    Expression<int>? position,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastActiveAt,
    Expression<double>? scrollY,
    Expression<String>? thumbnailPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (pageColor != null) 'page_color': pageColor,
      if (openerId != null) 'opener_id': openerId,
      if (groupId != null) 'group_id': groupId,
      if (groupName != null) 'group_name': groupName,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
      if (scrollY != null) 'scroll_y': scrollY,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabsCompanion copyWith({
    Value<String>? id,
    Value<String?>? url,
    Value<String>? title,
    Value<int?>? pageColor,
    Value<String?>? openerId,
    Value<String?>? groupId,
    Value<String?>? groupName,
    Value<int>? position,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastActiveAt,
    Value<double?>? scrollY,
    Value<String?>? thumbnailPath,
    Value<int>? rowid,
  }) {
    return TabsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      pageColor: pageColor ?? this.pageColor,
      openerId: openerId ?? this.openerId,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      scrollY: scrollY ?? this.scrollY,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (pageColor.present) {
      map['page_color'] = Variable<int>(pageColor.value);
    }
    if (openerId.present) {
      map['opener_id'] = Variable<String>(openerId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<DateTime>(lastActiveAt.value);
    }
    if (scrollY.present) {
      map['scroll_y'] = Variable<double>(scrollY.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('pageColor: $pageColor, ')
          ..write('openerId: $openerId, ')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('scrollY: $scrollY, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TabsTable tabs = $TabsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tabs];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabs', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$TabsTableCreateCompanionBuilder = TabsCompanion Function({
  required String id,
  Value<String?> url,
  Value<String> title,
  Value<int?> pageColor,
  Value<String?> openerId,
  Value<String?> groupId,
  Value<String?> groupName,
  required int position,
  required DateTime createdAt,
  required DateTime lastActiveAt,
  Value<double?> scrollY,
  Value<String?> thumbnailPath,
  Value<int> rowid,
});
typedef $$TabsTableUpdateCompanionBuilder = TabsCompanion Function({
  Value<String> id,
  Value<String?> url,
  Value<String> title,
  Value<int?> pageColor,
  Value<String?> openerId,
  Value<String?> groupId,
  Value<String?> groupName,
  Value<int> position,
  Value<DateTime> createdAt,
  Value<DateTime> lastActiveAt,
  Value<double?> scrollY,
  Value<String?> thumbnailPath,
  Value<int> rowid,
});

final class $$TabsTableReferences
    extends BaseReferences<_$AppDatabase, $TabsTable, Tab> {
  $$TabsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TabsTable _openerIdTable(_$AppDatabase db) =>
      db.tabs.createAlias('tabs__opener_id__tabs__id');

  $$TabsTableProcessedTableManager? get openerId {
    final $_column = $_itemColumn<String>('opener_id');
    if ($_column == null) return null;
    final manager = $$TabsTableTableManager(
      $_db,
      $_db.tabs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_openerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TabsTableFilterComposer extends Composer<_$AppDatabase, $TabsTable> {
  $$TabsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageColor => $composableBuilder(
    column: $table.pageColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scrollY => $composableBuilder(
    column: $table.scrollY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  $$TabsTableFilterComposer get openerId {
    final $$TabsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openerId,
      referencedTable: $db.tabs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabsTableFilterComposer(
            $db: $db,
            $table: $db.tabs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabsTableOrderingComposer extends Composer<_$AppDatabase, $TabsTable> {
  $$TabsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageColor => $composableBuilder(
    column: $table.pageColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scrollY => $composableBuilder(
    column: $table.scrollY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  $$TabsTableOrderingComposer get openerId {
    final $$TabsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openerId,
      referencedTable: $db.tabs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabsTableOrderingComposer(
            $db: $db,
            $table: $db.tabs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TabsTable> {
  $$TabsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get pageColor =>
      $composableBuilder(column: $table.pageColor, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get scrollY =>
      $composableBuilder(column: $table.scrollY, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  $$TabsTableAnnotationComposer get openerId {
    final $$TabsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.openerId,
      referencedTable: $db.tabs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TabsTableAnnotationComposer(
            $db: $db,
            $table: $db.tabs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TabsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TabsTable,
          Tab,
          $$TabsTableFilterComposer,
          $$TabsTableOrderingComposer,
          $$TabsTableAnnotationComposer,
          $$TabsTableCreateCompanionBuilder,
          $$TabsTableUpdateCompanionBuilder,
          (Tab, $$TabsTableReferences),
          Tab,
          PrefetchHooks Function({bool openerId})
        > {
  $$TabsTableTableManager(_$AppDatabase db, $TabsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> pageColor = const Value.absent(),
                Value<String?> openerId = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastActiveAt = const Value.absent(),
                Value<double?> scrollY = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabsCompanion(
                id: id,
                url: url,
                title: title,
                pageColor: pageColor,
                openerId: openerId,
                groupId: groupId,
                groupName: groupName,
                position: position,
                createdAt: createdAt,
                lastActiveAt: lastActiveAt,
                scrollY: scrollY,
                thumbnailPath: thumbnailPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> pageColor = const Value.absent(),
                Value<String?> openerId = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                required int position,
                required DateTime createdAt,
                required DateTime lastActiveAt,
                Value<double?> scrollY = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabsCompanion.insert(
                id: id,
                url: url,
                title: title,
                pageColor: pageColor,
                openerId: openerId,
                groupId: groupId,
                groupName: groupName,
                position: position,
                createdAt: createdAt,
                lastActiveAt: lastActiveAt,
                scrollY: scrollY,
                thumbnailPath: thumbnailPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TabsTable, Tab>(table),
                  $$TabsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({openerId = false}) {
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
                    if (openerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.openerId,
                        referencedTable: $$TabsTableReferences._openerIdTable(
                          db,
                        ),
                        referencedColumn: $$TabsTableReferences
                            ._openerIdTable(db)
                            .id,
                      ) as T;
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

typedef $$TabsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TabsTable,
      Tab,
      $$TabsTableFilterComposer,
      $$TabsTableOrderingComposer,
      $$TabsTableAnnotationComposer,
      $$TabsTableCreateCompanionBuilder,
      $$TabsTableUpdateCompanionBuilder,
      (Tab, $$TabsTableReferences),
      Tab,
      PrefetchHooks Function({bool openerId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TabsTableTableManager get tabs => $$TabsTableTableManager(_db, _db.tabs);
}
