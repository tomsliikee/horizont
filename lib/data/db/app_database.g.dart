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

class $BookmarkFoldersTable extends BookmarkFolders
    with TableInfo<$BookmarkFoldersTable, FolderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkFoldersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('folder'),
  );
  static const VerificationMeta _toneMeta = const VerificationMeta('tone');
  @override
  late final GeneratedColumn<String> tone = GeneratedColumn<String>(
    'tone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('neutral'),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isFavoritesMeta = const VerificationMeta(
    'isFavorites',
  );
  @override
  late final GeneratedColumn<bool> isFavorites = GeneratedColumn<bool>(
    'is_favorites',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorites" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    tone,
    position,
    isFavorites,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmark_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<FolderRow> instance, {
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
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('tone')) {
      context.handle(
        _toneMeta,
        tone.isAcceptableOrUnknown(data['tone']!, _toneMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('is_favorites')) {
      context.handle(
        _isFavoritesMeta,
        isFavorites.isAcceptableOrUnknown(
          data['is_favorites']!,
          _isFavoritesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FolderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      tone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tone'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      isFavorites: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorites'],
      )!,
    );
  }

  @override
  $BookmarkFoldersTable createAlias(String alias) {
    return $BookmarkFoldersTable(attachedDatabase, alias);
  }
}

class FolderRow extends DataClass implements Insertable<FolderRow> {
  final int id;
  final String name;
  final String icon;
  final String tone;
  final int position;
  final bool isFavorites;
  const FolderRow({
    required this.id,
    required this.name,
    required this.icon,
    required this.tone,
    required this.position,
    required this.isFavorites,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['tone'] = Variable<String>(tone);
    map['position'] = Variable<int>(position);
    map['is_favorites'] = Variable<bool>(isFavorites);
    return map;
  }

  BookmarkFoldersCompanion toCompanion(bool nullToAbsent) {
    return BookmarkFoldersCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      tone: Value(tone),
      position: Value(position),
      isFavorites: Value(isFavorites),
    );
  }

  factory FolderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      tone: serializer.fromJson<String>(json['tone']),
      position: serializer.fromJson<int>(json['position']),
      isFavorites: serializer.fromJson<bool>(json['isFavorites']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'tone': serializer.toJson<String>(tone),
      'position': serializer.toJson<int>(position),
      'isFavorites': serializer.toJson<bool>(isFavorites),
    };
  }

  FolderRow copyWith({
    int? id,
    String? name,
    String? icon,
    String? tone,
    int? position,
    bool? isFavorites,
  }) => FolderRow(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    tone: tone ?? this.tone,
    position: position ?? this.position,
    isFavorites: isFavorites ?? this.isFavorites,
  );
  FolderRow copyWithCompanion(BookmarkFoldersCompanion data) {
    return FolderRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      tone: data.tone.present ? data.tone.value : this.tone,
      position: data.position.present ? data.position.value : this.position,
      isFavorites: data.isFavorites.present
          ? data.isFavorites.value
          : this.isFavorites,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('tone: $tone, ')
          ..write('position: $position, ')
          ..write('isFavorites: $isFavorites')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, tone, position, isFavorites);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.tone == this.tone &&
          other.position == this.position &&
          other.isFavorites == this.isFavorites);
}

class BookmarkFoldersCompanion extends UpdateCompanion<FolderRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> tone;
  final Value<int> position;
  final Value<bool> isFavorites;
  const BookmarkFoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.tone = const Value.absent(),
    this.position = const Value.absent(),
    this.isFavorites = const Value.absent(),
  });
  BookmarkFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.tone = const Value.absent(),
    this.position = const Value.absent(),
    this.isFavorites = const Value.absent(),
  }) : name = Value(name);
  static Insertable<FolderRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? tone,
    Expression<int>? position,
    Expression<bool>? isFavorites,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (tone != null) 'tone': tone,
      if (position != null) 'position': position,
      if (isFavorites != null) 'is_favorites': isFavorites,
    });
  }

  BookmarkFoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? tone,
    Value<int>? position,
    Value<bool>? isFavorites,
  }) {
    return BookmarkFoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      tone: tone ?? this.tone,
      position: position ?? this.position,
      isFavorites: isFavorites ?? this.isFavorites,
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
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(tone.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isFavorites.present) {
      map['is_favorites'] = Variable<bool>(isFavorites.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkFoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('tone: $tone, ')
          ..write('position: $position, ')
          ..write('isFavorites: $isFavorites')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bookmark_folders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folderId,
    url,
    title,
    position,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final int id;
  final int folderId;
  final String url;
  final String title;
  final int position;
  final DateTime createdAt;
  const BookmarkRow({
    required this.id,
    required this.folderId,
    required this.url,
    required this.title,
    required this.position,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['folder_id'] = Variable<int>(folderId);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      folderId: Value(folderId),
      url: Value(url),
      title: Value(title),
      position: Value(position),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      id: serializer.fromJson<int>(json['id']),
      folderId: serializer.fromJson<int>(json['folderId']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'folderId': serializer.toJson<int>(folderId),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookmarkRow copyWith({
    int? id,
    int? folderId,
    String? url,
    String? title,
    int? position,
    DateTime? createdAt,
  }) => BookmarkRow(
    id: id ?? this.id,
    folderId: folderId ?? this.folderId,
    url: url ?? this.url,
    title: title ?? this.title,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
  );
  BookmarkRow copyWithCompanion(BookmarksCompanion data) {
    return BookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, folderId, url, title, position, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.id == this.id &&
          other.folderId == this.folderId &&
          other.url == this.url &&
          other.title == this.title &&
          other.position == this.position &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<int> id;
  final Value<int> folderId;
  final Value<String> url;
  final Value<String> title;
  final Value<int> position;
  final Value<DateTime> createdAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.folderId = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required int folderId,
    required String url,
    this.title = const Value.absent(),
    this.position = const Value.absent(),
    required DateTime createdAt,
  }) : folderId = Value(folderId),
       url = Value(url),
       createdAt = Value(createdAt);
  static Insertable<BookmarkRow> custom({
    Expression<int>? id,
    Expression<int>? folderId,
    Expression<String>? url,
    Expression<String>? title,
    Expression<int>? position,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folderId != null) 'folder_id': folderId,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<int>? folderId,
    Value<String>? url,
    Value<String>? title,
    Value<int>? position,
    Value<DateTime>? createdAt,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      url: url ?? this.url,
      title: title ?? this.title,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, VisitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _visitedAtMeta = const VerificationMeta(
    'visitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> visitedAt = GeneratedColumn<DateTime>(
    'visited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, url, title, visitedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('visited_at')) {
      context.handle(
        _visitedAtMeta,
        visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_visitedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      visitedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visited_at'],
      )!,
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }
}

class VisitRow extends DataClass implements Insertable<VisitRow> {
  final int id;
  final String url;
  final String title;
  final DateTime visitedAt;
  const VisitRow({
    required this.id,
    required this.url,
    required this.title,
    required this.visitedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['visited_at'] = Variable<DateTime>(visitedAt);
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      visitedAt: Value(visitedAt),
    );
  }

  factory VisitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitRow(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      visitedAt: serializer.fromJson<DateTime>(json['visitedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'visitedAt': serializer.toJson<DateTime>(visitedAt),
    };
  }

  VisitRow copyWith({
    int? id,
    String? url,
    String? title,
    DateTime? visitedAt,
  }) => VisitRow(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title ?? this.title,
    visitedAt: visitedAt ?? this.visitedAt,
  );
  VisitRow copyWithCompanion(VisitsCompanion data) {
    return VisitRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      visitedAt: data.visitedAt.present ? data.visitedAt.value : this.visitedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('visitedAt: $visitedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url, title, visitedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.visitedAt == this.visitedAt);
}

class VisitsCompanion extends UpdateCompanion<VisitRow> {
  final Value<int> id;
  final Value<String> url;
  final Value<String> title;
  final Value<DateTime> visitedAt;
  const VisitsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.visitedAt = const Value.absent(),
  });
  VisitsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    this.title = const Value.absent(),
    required DateTime visitedAt,
  }) : url = Value(url),
       visitedAt = Value(visitedAt);
  static Insertable<VisitRow> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<DateTime>? visitedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (visitedAt != null) 'visited_at': visitedAt,
    });
  }

  VisitsCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<String>? title,
    Value<DateTime>? visitedAt,
  }) {
    return VisitsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      visitedAt: visitedAt ?? this.visitedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = Variable<DateTime>(visitedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('visitedAt: $visitedAt')
          ..write(')'))
        .toString();
  }
}

class $PagesTable extends Pages with TableInfo<$PagesTable, PageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _visitCountMeta = const VerificationMeta(
    'visitCount',
  );
  @override
  late final GeneratedColumn<int> visitCount = GeneratedColumn<int>(
    'visit_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastVisitAtMeta = const VerificationMeta(
    'lastVisitAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVisitAt = GeneratedColumn<DateTime>(
    'last_visit_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [url, title, visitCount, lastVisitAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<PageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('visit_count')) {
      context.handle(
        _visitCountMeta,
        visitCount.isAcceptableOrUnknown(data['visit_count']!, _visitCountMeta),
      );
    }
    if (data.containsKey('last_visit_at')) {
      context.handle(
        _lastVisitAtMeta,
        lastVisitAt.isAcceptableOrUnknown(
          data['last_visit_at']!,
          _lastVisitAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastVisitAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  PageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageRow(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      visitCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visit_count'],
      )!,
      lastVisitAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_visit_at'],
      )!,
    );
  }

  @override
  $PagesTable createAlias(String alias) {
    return $PagesTable(attachedDatabase, alias);
  }
}

class PageRow extends DataClass implements Insertable<PageRow> {
  final String url;
  final String title;
  final int visitCount;
  final DateTime lastVisitAt;
  const PageRow({
    required this.url,
    required this.title,
    required this.visitCount,
    required this.lastVisitAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['visit_count'] = Variable<int>(visitCount);
    map['last_visit_at'] = Variable<DateTime>(lastVisitAt);
    return map;
  }

  PagesCompanion toCompanion(bool nullToAbsent) {
    return PagesCompanion(
      url: Value(url),
      title: Value(title),
      visitCount: Value(visitCount),
      lastVisitAt: Value(lastVisitAt),
    );
  }

  factory PageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageRow(
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      visitCount: serializer.fromJson<int>(json['visitCount']),
      lastVisitAt: serializer.fromJson<DateTime>(json['lastVisitAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'visitCount': serializer.toJson<int>(visitCount),
      'lastVisitAt': serializer.toJson<DateTime>(lastVisitAt),
    };
  }

  PageRow copyWith({
    String? url,
    String? title,
    int? visitCount,
    DateTime? lastVisitAt,
  }) => PageRow(
    url: url ?? this.url,
    title: title ?? this.title,
    visitCount: visitCount ?? this.visitCount,
    lastVisitAt: lastVisitAt ?? this.lastVisitAt,
  );
  PageRow copyWithCompanion(PagesCompanion data) {
    return PageRow(
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      visitCount: data.visitCount.present
          ? data.visitCount.value
          : this.visitCount,
      lastVisitAt: data.lastVisitAt.present
          ? data.lastVisitAt.value
          : this.lastVisitAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageRow(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('visitCount: $visitCount, ')
          ..write('lastVisitAt: $lastVisitAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(url, title, visitCount, lastVisitAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageRow &&
          other.url == this.url &&
          other.title == this.title &&
          other.visitCount == this.visitCount &&
          other.lastVisitAt == this.lastVisitAt);
}

class PagesCompanion extends UpdateCompanion<PageRow> {
  final Value<String> url;
  final Value<String> title;
  final Value<int> visitCount;
  final Value<DateTime> lastVisitAt;
  final Value<int> rowid;
  const PagesCompanion({
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.visitCount = const Value.absent(),
    this.lastVisitAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagesCompanion.insert({
    required String url,
    this.title = const Value.absent(),
    this.visitCount = const Value.absent(),
    required DateTime lastVisitAt,
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       lastVisitAt = Value(lastVisitAt);
  static Insertable<PageRow> custom({
    Expression<String>? url,
    Expression<String>? title,
    Expression<int>? visitCount,
    Expression<DateTime>? lastVisitAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (visitCount != null) 'visit_count': visitCount,
      if (lastVisitAt != null) 'last_visit_at': lastVisitAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagesCompanion copyWith({
    Value<String>? url,
    Value<String>? title,
    Value<int>? visitCount,
    Value<DateTime>? lastVisitAt,
    Value<int>? rowid,
  }) {
    return PagesCompanion(
      url: url ?? this.url,
      title: title ?? this.title,
      visitCount: visitCount ?? this.visitCount,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (visitCount.present) {
      map['visit_count'] = Variable<int>(visitCount.value);
    }
    if (lastVisitAt.present) {
      map['last_visit_at'] = Variable<DateTime>(lastVisitAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagesCompanion(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('visitCount: $visitCount, ')
          ..write('lastVisitAt: $lastVisitAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingItemsTable extends ReadingItems
    with TableInfo<$ReadingItemsTable, ReadingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readFractionMeta = const VerificationMeta(
    'readFraction',
  );
  @override
  late final GeneratedColumn<double> readFraction = GeneratedColumn<double>(
    'read_fraction',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _offlinePathMeta = const VerificationMeta(
    'offlinePath',
  );
  @override
  late final GeneratedColumn<String> offlinePath = GeneratedColumn<String>(
    'offline_path',
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
    addedAt,
    readFraction,
    estimatedMinutes,
    offlinePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('read_fraction')) {
      context.handle(
        _readFractionMeta,
        readFraction.isAcceptableOrUnknown(
          data['read_fraction']!,
          _readFractionMeta,
        ),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('offline_path')) {
      context.handle(
        _offlinePathMeta,
        offlinePath.isAcceptableOrUnknown(
          data['offline_path']!,
          _offlinePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      readFraction: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}read_fraction'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      )!,
      offlinePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offline_path'],
      ),
    );
  }

  @override
  $ReadingItemsTable createAlias(String alias) {
    return $ReadingItemsTable(attachedDatabase, alias);
  }
}

class ReadingRow extends DataClass implements Insertable<ReadingRow> {
  final int id;
  final String url;
  final String title;
  final DateTime addedAt;
  final double readFraction;
  final int estimatedMinutes;
  final String? offlinePath;
  const ReadingRow({
    required this.id,
    required this.url,
    required this.title,
    required this.addedAt,
    required this.readFraction,
    required this.estimatedMinutes,
    this.offlinePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['read_fraction'] = Variable<double>(readFraction);
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    if (!nullToAbsent || offlinePath != null) {
      map['offline_path'] = Variable<String>(offlinePath);
    }
    return map;
  }

  ReadingItemsCompanion toCompanion(bool nullToAbsent) {
    return ReadingItemsCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      addedAt: Value(addedAt),
      readFraction: Value(readFraction),
      estimatedMinutes: Value(estimatedMinutes),
      offlinePath: offlinePath == null && nullToAbsent
          ? const Value.absent()
          : Value(offlinePath),
    );
  }

  factory ReadingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingRow(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      readFraction: serializer.fromJson<double>(json['readFraction']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      offlinePath: serializer.fromJson<String?>(json['offlinePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'readFraction': serializer.toJson<double>(readFraction),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'offlinePath': serializer.toJson<String?>(offlinePath),
    };
  }

  ReadingRow copyWith({
    int? id,
    String? url,
    String? title,
    DateTime? addedAt,
    double? readFraction,
    int? estimatedMinutes,
    Value<String?> offlinePath = const Value.absent(),
  }) => ReadingRow(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title ?? this.title,
    addedAt: addedAt ?? this.addedAt,
    readFraction: readFraction ?? this.readFraction,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    offlinePath: offlinePath.present ? offlinePath.value : this.offlinePath,
  );
  ReadingRow copyWithCompanion(ReadingItemsCompanion data) {
    return ReadingRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      readFraction: data.readFraction.present
          ? data.readFraction.value
          : this.readFraction,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      offlinePath: data.offlinePath.present
          ? data.offlinePath.value
          : this.offlinePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('addedAt: $addedAt, ')
          ..write('readFraction: $readFraction, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('offlinePath: $offlinePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    title,
    addedAt,
    readFraction,
    estimatedMinutes,
    offlinePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.addedAt == this.addedAt &&
          other.readFraction == this.readFraction &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.offlinePath == this.offlinePath);
}

class ReadingItemsCompanion extends UpdateCompanion<ReadingRow> {
  final Value<int> id;
  final Value<String> url;
  final Value<String> title;
  final Value<DateTime> addedAt;
  final Value<double> readFraction;
  final Value<int> estimatedMinutes;
  final Value<String?> offlinePath;
  const ReadingItemsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.readFraction = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.offlinePath = const Value.absent(),
  });
  ReadingItemsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    this.title = const Value.absent(),
    required DateTime addedAt,
    this.readFraction = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.offlinePath = const Value.absent(),
  }) : url = Value(url),
       addedAt = Value(addedAt);
  static Insertable<ReadingRow> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<DateTime>? addedAt,
    Expression<double>? readFraction,
    Expression<int>? estimatedMinutes,
    Expression<String>? offlinePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (addedAt != null) 'added_at': addedAt,
      if (readFraction != null) 'read_fraction': readFraction,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (offlinePath != null) 'offline_path': offlinePath,
    });
  }

  ReadingItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<String>? title,
    Value<DateTime>? addedAt,
    Value<double>? readFraction,
    Value<int>? estimatedMinutes,
    Value<String?>? offlinePath,
  }) {
    return ReadingItemsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      addedAt: addedAt ?? this.addedAt,
      readFraction: readFraction ?? this.readFraction,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      offlinePath: offlinePath ?? this.offlinePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (readFraction.present) {
      map['read_fraction'] = Variable<double>(readFraction.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (offlinePath.present) {
      map['offline_path'] = Variable<String>(offlinePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingItemsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('addedAt: $addedAt, ')
          ..write('readFraction: $readFraction, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('offlinePath: $offlinePath')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, DownloadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedBytesMeta = const VerificationMeta(
    'receivedBytes',
  );
  @override
  late final GeneratedColumn<int> receivedBytes = GeneratedColumn<int>(
    'received_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savedUriMeta = const VerificationMeta(
    'savedUri',
  );
  @override
  late final GeneratedColumn<String> savedUri = GeneratedColumn<String>(
    'saved_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    taskId,
    url,
    fileName,
    mimeType,
    totalBytes,
    receivedBytes,
    status,
    startedAt,
    finishedAt,
    savedUri,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('received_bytes')) {
      context.handle(
        _receivedBytesMeta,
        receivedBytes.isAcceptableOrUnknown(
          data['received_bytes']!,
          _receivedBytesMeta,
        ),
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
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('saved_uri')) {
      context.handle(
        _savedUriMeta,
        savedUri.isAcceptableOrUnknown(data['saved_uri']!, _savedUriMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  DownloadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadRow(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      ),
      receivedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_bytes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      savedUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saved_uri'],
      ),
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }
}

class DownloadRow extends DataClass implements Insertable<DownloadRow> {
  final String taskId;
  final String url;
  final String fileName;
  final String mimeType;
  final int? totalBytes;
  final int receivedBytes;
  final String status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? savedUri;
  const DownloadRow({
    required this.taskId,
    required this.url,
    required this.fileName,
    required this.mimeType,
    this.totalBytes,
    required this.receivedBytes,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.savedUri,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['url'] = Variable<String>(url);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || totalBytes != null) {
      map['total_bytes'] = Variable<int>(totalBytes);
    }
    map['received_bytes'] = Variable<int>(receivedBytes);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || savedUri != null) {
      map['saved_uri'] = Variable<String>(savedUri);
    }
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      taskId: Value(taskId),
      url: Value(url),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      totalBytes: totalBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalBytes),
      receivedBytes: Value(receivedBytes),
      status: Value(status),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      savedUri: savedUri == null && nullToAbsent
          ? const Value.absent()
          : Value(savedUri),
    );
  }

  factory DownloadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadRow(
      taskId: serializer.fromJson<String>(json['taskId']),
      url: serializer.fromJson<String>(json['url']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      totalBytes: serializer.fromJson<int?>(json['totalBytes']),
      receivedBytes: serializer.fromJson<int>(json['receivedBytes']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      savedUri: serializer.fromJson<String?>(json['savedUri']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'url': serializer.toJson<String>(url),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'totalBytes': serializer.toJson<int?>(totalBytes),
      'receivedBytes': serializer.toJson<int>(receivedBytes),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'savedUri': serializer.toJson<String?>(savedUri),
    };
  }

  DownloadRow copyWith({
    String? taskId,
    String? url,
    String? fileName,
    String? mimeType,
    Value<int?> totalBytes = const Value.absent(),
    int? receivedBytes,
    String? status,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<String?> savedUri = const Value.absent(),
  }) => DownloadRow(
    taskId: taskId ?? this.taskId,
    url: url ?? this.url,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    totalBytes: totalBytes.present ? totalBytes.value : this.totalBytes,
    receivedBytes: receivedBytes ?? this.receivedBytes,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    savedUri: savedUri.present ? savedUri.value : this.savedUri,
  );
  DownloadRow copyWithCompanion(DownloadsCompanion data) {
    return DownloadRow(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      url: data.url.present ? data.url.value : this.url,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      receivedBytes: data.receivedBytes.present
          ? data.receivedBytes.value
          : this.receivedBytes,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      savedUri: data.savedUri.present ? data.savedUri.value : this.savedUri,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadRow(')
          ..write('taskId: $taskId, ')
          ..write('url: $url, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('receivedBytes: $receivedBytes, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('savedUri: $savedUri')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    taskId,
    url,
    fileName,
    mimeType,
    totalBytes,
    receivedBytes,
    status,
    startedAt,
    finishedAt,
    savedUri,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadRow &&
          other.taskId == this.taskId &&
          other.url == this.url &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.totalBytes == this.totalBytes &&
          other.receivedBytes == this.receivedBytes &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.savedUri == this.savedUri);
}

class DownloadsCompanion extends UpdateCompanion<DownloadRow> {
  final Value<String> taskId;
  final Value<String> url;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int?> totalBytes;
  final Value<int> receivedBytes;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<String?> savedUri;
  final Value<int> rowid;
  const DownloadsCompanion({
    this.taskId = const Value.absent(),
    this.url = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.receivedBytes = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.savedUri = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadsCompanion.insert({
    required String taskId,
    required String url,
    required String fileName,
    this.mimeType = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.receivedBytes = const Value.absent(),
    required String status,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.savedUri = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       url = Value(url),
       fileName = Value(fileName),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<DownloadRow> custom({
    Expression<String>? taskId,
    Expression<String>? url,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? totalBytes,
    Expression<int>? receivedBytes,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? savedUri,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (url != null) 'url': url,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (receivedBytes != null) 'received_bytes': receivedBytes,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (savedUri != null) 'saved_uri': savedUri,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadsCompanion copyWith({
    Value<String>? taskId,
    Value<String>? url,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int?>? totalBytes,
    Value<int>? receivedBytes,
    Value<String>? status,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<String?>? savedUri,
    Value<int>? rowid,
  }) {
    return DownloadsCompanion(
      taskId: taskId ?? this.taskId,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      totalBytes: totalBytes ?? this.totalBytes,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      savedUri: savedUri ?? this.savedUri,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (receivedBytes.present) {
      map['received_bytes'] = Variable<int>(receivedBytes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (savedUri.present) {
      map['saved_uri'] = Variable<String>(savedUri.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('taskId: $taskId, ')
          ..write('url: $url, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('receivedBytes: $receivedBytes, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('savedUri: $savedUri, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackerDaysTable extends TrackerDays
    with TableInfo<$TrackerDaysTable, TrackerDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackerDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blockedCountMeta = const VerificationMeta(
    'blockedCount',
  );
  @override
  late final GeneratedColumn<int> blockedCount = GeneratedColumn<int>(
    'blocked_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [day, host, blockedCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracker_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackerDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('blocked_count')) {
      context.handle(
        _blockedCountMeta,
        blockedCount.isAcceptableOrUnknown(
          data['blocked_count']!,
          _blockedCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day, host};
  @override
  TrackerDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackerDayRow(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      blockedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}blocked_count'],
      )!,
    );
  }

  @override
  $TrackerDaysTable createAlias(String alias) {
    return $TrackerDaysTable(attachedDatabase, alias);
  }
}

class TrackerDayRow extends DataClass implements Insertable<TrackerDayRow> {
  final String day;
  final String host;
  final int blockedCount;
  const TrackerDayRow({
    required this.day,
    required this.host,
    required this.blockedCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['host'] = Variable<String>(host);
    map['blocked_count'] = Variable<int>(blockedCount);
    return map;
  }

  TrackerDaysCompanion toCompanion(bool nullToAbsent) {
    return TrackerDaysCompanion(
      day: Value(day),
      host: Value(host),
      blockedCount: Value(blockedCount),
    );
  }

  factory TrackerDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackerDayRow(
      day: serializer.fromJson<String>(json['day']),
      host: serializer.fromJson<String>(json['host']),
      blockedCount: serializer.fromJson<int>(json['blockedCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'host': serializer.toJson<String>(host),
      'blockedCount': serializer.toJson<int>(blockedCount),
    };
  }

  TrackerDayRow copyWith({String? day, String? host, int? blockedCount}) =>
      TrackerDayRow(
        day: day ?? this.day,
        host: host ?? this.host,
        blockedCount: blockedCount ?? this.blockedCount,
      );
  TrackerDayRow copyWithCompanion(TrackerDaysCompanion data) {
    return TrackerDayRow(
      day: data.day.present ? data.day.value : this.day,
      host: data.host.present ? data.host.value : this.host,
      blockedCount: data.blockedCount.present
          ? data.blockedCount.value
          : this.blockedCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackerDayRow(')
          ..write('day: $day, ')
          ..write('host: $host, ')
          ..write('blockedCount: $blockedCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, host, blockedCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackerDayRow &&
          other.day == this.day &&
          other.host == this.host &&
          other.blockedCount == this.blockedCount);
}

class TrackerDaysCompanion extends UpdateCompanion<TrackerDayRow> {
  final Value<String> day;
  final Value<String> host;
  final Value<int> blockedCount;
  final Value<int> rowid;
  const TrackerDaysCompanion({
    this.day = const Value.absent(),
    this.host = const Value.absent(),
    this.blockedCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackerDaysCompanion.insert({
    required String day,
    required String host,
    this.blockedCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       host = Value(host);
  static Insertable<TrackerDayRow> custom({
    Expression<String>? day,
    Expression<String>? host,
    Expression<int>? blockedCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (host != null) 'host': host,
      if (blockedCount != null) 'blocked_count': blockedCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackerDaysCompanion copyWith({
    Value<String>? day,
    Value<String>? host,
    Value<int>? blockedCount,
    Value<int>? rowid,
  }) {
    return TrackerDaysCompanion(
      day: day ?? this.day,
      host: host ?? this.host,
      blockedCount: blockedCount ?? this.blockedCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (blockedCount.present) {
      map['blocked_count'] = Variable<int>(blockedCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackerDaysCompanion(')
          ..write('day: $day, ')
          ..write('host: $host, ')
          ..write('blockedCount: $blockedCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SitePermissionsTable extends SitePermissions
    with TableInfo<$SitePermissionsTable, PermissionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SitePermissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allowedMeta = const VerificationMeta(
    'allowed',
  );
  @override
  late final GeneratedColumn<bool> allowed = GeneratedColumn<bool>(
    'allowed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allowed" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [origin, kind, allowed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'site_permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PermissionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('allowed')) {
      context.handle(
        _allowedMeta,
        allowed.isAcceptableOrUnknown(data['allowed']!, _allowedMeta),
      );
    } else if (isInserting) {
      context.missing(_allowedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {origin, kind};
  @override
  PermissionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PermissionRow(
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      allowed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allowed'],
      )!,
    );
  }

  @override
  $SitePermissionsTable createAlias(String alias) {
    return $SitePermissionsTable(attachedDatabase, alias);
  }
}

class PermissionRow extends DataClass implements Insertable<PermissionRow> {
  final String origin;
  final String kind;
  final bool allowed;
  const PermissionRow({
    required this.origin,
    required this.kind,
    required this.allowed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['origin'] = Variable<String>(origin);
    map['kind'] = Variable<String>(kind);
    map['allowed'] = Variable<bool>(allowed);
    return map;
  }

  SitePermissionsCompanion toCompanion(bool nullToAbsent) {
    return SitePermissionsCompanion(
      origin: Value(origin),
      kind: Value(kind),
      allowed: Value(allowed),
    );
  }

  factory PermissionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PermissionRow(
      origin: serializer.fromJson<String>(json['origin']),
      kind: serializer.fromJson<String>(json['kind']),
      allowed: serializer.fromJson<bool>(json['allowed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'origin': serializer.toJson<String>(origin),
      'kind': serializer.toJson<String>(kind),
      'allowed': serializer.toJson<bool>(allowed),
    };
  }

  PermissionRow copyWith({String? origin, String? kind, bool? allowed}) =>
      PermissionRow(
        origin: origin ?? this.origin,
        kind: kind ?? this.kind,
        allowed: allowed ?? this.allowed,
      );
  PermissionRow copyWithCompanion(SitePermissionsCompanion data) {
    return PermissionRow(
      origin: data.origin.present ? data.origin.value : this.origin,
      kind: data.kind.present ? data.kind.value : this.kind,
      allowed: data.allowed.present ? data.allowed.value : this.allowed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PermissionRow(')
          ..write('origin: $origin, ')
          ..write('kind: $kind, ')
          ..write('allowed: $allowed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(origin, kind, allowed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PermissionRow &&
          other.origin == this.origin &&
          other.kind == this.kind &&
          other.allowed == this.allowed);
}

class SitePermissionsCompanion extends UpdateCompanion<PermissionRow> {
  final Value<String> origin;
  final Value<String> kind;
  final Value<bool> allowed;
  final Value<int> rowid;
  const SitePermissionsCompanion({
    this.origin = const Value.absent(),
    this.kind = const Value.absent(),
    this.allowed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SitePermissionsCompanion.insert({
    required String origin,
    required String kind,
    required bool allowed,
    this.rowid = const Value.absent(),
  }) : origin = Value(origin),
       kind = Value(kind),
       allowed = Value(allowed);
  static Insertable<PermissionRow> custom({
    Expression<String>? origin,
    Expression<String>? kind,
    Expression<bool>? allowed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (origin != null) 'origin': origin,
      if (kind != null) 'kind': kind,
      if (allowed != null) 'allowed': allowed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SitePermissionsCompanion copyWith({
    Value<String>? origin,
    Value<String>? kind,
    Value<bool>? allowed,
    Value<int>? rowid,
  }) {
    return SitePermissionsCompanion(
      origin: origin ?? this.origin,
      kind: kind ?? this.kind,
      allowed: allowed ?? this.allowed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (allowed.present) {
      map['allowed'] = Variable<bool>(allowed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SitePermissionsCompanion(')
          ..write('origin: $origin, ')
          ..write('kind: $kind, ')
          ..write('allowed: $allowed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TabsTable tabs = $TabsTable(this);
  late final $BookmarkFoldersTable bookmarkFolders = $BookmarkFoldersTable(
    this,
  );
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  late final $PagesTable pages = $PagesTable(this);
  late final $ReadingItemsTable readingItems = $ReadingItemsTable(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  late final $TrackerDaysTable trackerDays = $TrackerDaysTable(this);
  late final $SitePermissionsTable sitePermissions = $SitePermissionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tabs,
    bookmarkFolders,
    bookmarks,
    visits,
    pages,
    readingItems,
    downloads,
    trackerDays,
    sitePermissions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tabs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tabs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bookmark_folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bookmarks', kind: UpdateKind.delete)],
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
typedef $$BookmarkFoldersTableCreateCompanionBuilder =
    BookmarkFoldersCompanion Function({
      Value<int> id,
      required String name,
      Value<String> icon,
      Value<String> tone,
      Value<int> position,
      Value<bool> isFavorites,
    });
typedef $$BookmarkFoldersTableUpdateCompanionBuilder =
    BookmarkFoldersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> icon,
      Value<String> tone,
      Value<int> position,
      Value<bool> isFavorites,
    });

final class $$BookmarkFoldersTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarkFoldersTable, FolderRow> {
  $$BookmarkFoldersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$BookmarksTable, List<BookmarkRow>>
  _bookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarks,
    aliasName: 'bookmark_folders__id__bookmarks__folder_id',
  );

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BookmarkFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarkFoldersTable> {
  $$BookmarkFoldersTableFilterComposer({
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

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorites => $composableBuilder(
    column: $table.isFavorites,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookmarksRefs(
    Expression<bool> Function($$BookmarksTableFilterComposer f) f,
  ) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookmarkFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarkFoldersTable> {
  $$BookmarkFoldersTableOrderingComposer({
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

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorites => $composableBuilder(
    column: $table.isFavorites,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarkFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarkFoldersTable> {
  $$BookmarkFoldersTableAnnotationComposer({
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

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isFavorites => $composableBuilder(
    column: $table.isFavorites,
    builder: (column) => column,
  );

  Expression<T> bookmarksRefs<T extends Object>(
    Expression<T> Function($$BookmarksTableAnnotationComposer a) f,
  ) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookmarkFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarkFoldersTable,
          FolderRow,
          $$BookmarkFoldersTableFilterComposer,
          $$BookmarkFoldersTableOrderingComposer,
          $$BookmarkFoldersTableAnnotationComposer,
          $$BookmarkFoldersTableCreateCompanionBuilder,
          $$BookmarkFoldersTableUpdateCompanionBuilder,
          (FolderRow, $$BookmarkFoldersTableReferences),
          FolderRow,
          PrefetchHooks Function({bool bookmarksRefs})
        > {
  $$BookmarkFoldersTableTableManager(
    _$AppDatabase db,
    $BookmarkFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> tone = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> isFavorites = const Value.absent(),
              }) => BookmarkFoldersCompanion(
                id: id,
                name: name,
                icon: icon,
                tone: tone,
                position: position,
                isFavorites: isFavorites,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> icon = const Value.absent(),
                Value<String> tone = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> isFavorites = const Value.absent(),
              }) => BookmarkFoldersCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                tone: tone,
                position: position,
                isFavorites: isFavorites,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarkFoldersTable, FolderRow>(table),
                  $$BookmarkFoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookmarksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookmarksRefs) db.bookmarks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookmarksRefs)
                    await $_getPrefetchedData<
                      FolderRow,
                      $BookmarkFoldersTable,
                      BookmarkRow
                    >(
                      currentTable: table,
                      referencedTable: $$BookmarkFoldersTableReferences
                          ._bookmarksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BookmarkFoldersTableReferences(
                            db,
                            table,
                            p0,
                          ).bookmarksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BookmarkFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarkFoldersTable,
      FolderRow,
      $$BookmarkFoldersTableFilterComposer,
      $$BookmarkFoldersTableOrderingComposer,
      $$BookmarkFoldersTableAnnotationComposer,
      $$BookmarkFoldersTableCreateCompanionBuilder,
      $$BookmarkFoldersTableUpdateCompanionBuilder,
      (FolderRow, $$BookmarkFoldersTableReferences),
      FolderRow,
      PrefetchHooks Function({bool bookmarksRefs})
    >;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  required int folderId,
  required String url,
  Value<String> title,
  Value<int> position,
  required DateTime createdAt,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  Value<int> folderId,
  Value<String> url,
  Value<String> title,
  Value<int> position,
  Value<DateTime> createdAt,
});

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BookmarkFoldersTable _folderIdTable(_$AppDatabase db) => db
      .bookmarkFolders
      .createAlias('bookmarks__folder_id__bookmark_folders__id');

  $$BookmarkFoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<int>('folder_id')!;

    final manager = $$BookmarkFoldersTableTableManager(
      $_db,
      $_db.bookmarkFolders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
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

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
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

  $$BookmarkFoldersTableFilterComposer get folderId {
    final $$BookmarkFoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.bookmarkFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkFoldersTableFilterComposer(
            $db: $db,
            $table: $db.bookmarkFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
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

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
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

  $$BookmarkFoldersTableOrderingComposer get folderId {
    final $$BookmarkFoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.bookmarkFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkFoldersTableOrderingComposer(
            $db: $db,
            $table: $db.bookmarkFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BookmarkFoldersTableAnnotationComposer get folderId {
    final $$BookmarkFoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.bookmarkFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkFoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarkFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          BookmarkRow,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (BookmarkRow, $$BookmarksTableReferences),
          BookmarkRow,
          PrefetchHooks Function({bool folderId})
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> folderId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                folderId: folderId,
                url: url,
                title: title,
                position: position,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int folderId,
                required String url,
                Value<String> title = const Value.absent(),
                Value<int> position = const Value.absent(),
                required DateTime createdAt,
              }) => BookmarksCompanion.insert(
                id: id,
                folderId: folderId,
                url: url,
                title: title,
                position: position,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarksTable, BookmarkRow>(table),
                  $$BookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false}) {
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
                    if (folderId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.folderId,
                        referencedTable: $$BookmarksTableReferences
                            ._folderIdTable(db),
                        referencedColumn: $$BookmarksTableReferences
                            ._folderIdTable(db)
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

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      BookmarkRow,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (BookmarkRow, $$BookmarksTableReferences),
      BookmarkRow,
      PrefetchHooks Function({bool folderId})
    >;
typedef $$VisitsTableCreateCompanionBuilder = VisitsCompanion Function({
  Value<int> id,
  required String url,
  Value<String> title,
  required DateTime visitedAt,
});
typedef $$VisitsTableUpdateCompanionBuilder = VisitsCompanion Function({
  Value<int> id,
  Value<String> url,
  Value<String> title,
  Value<DateTime> visitedAt,
});

class $$VisitsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
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

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
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

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get visitedAt =>
      $composableBuilder(column: $table.visitedAt, builder: (column) => column);
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsTable,
          VisitRow,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (VisitRow, BaseReferences<_$AppDatabase, $VisitsTable, VisitRow>),
          VisitRow,
          PrefetchHooks Function()
        > {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> visitedAt = const Value.absent(),
              }) => VisitsCompanion(
                id: id,
                url: url,
                title: title,
                visitedAt: visitedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                Value<String> title = const Value.absent(),
                required DateTime visitedAt,
              }) => VisitsCompanion.insert(
                id: id,
                url: url,
                title: title,
                visitedAt: visitedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitsTable, VisitRow>(table),
                  BaseReferences<_$AppDatabase, $VisitsTable, VisitRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsTable,
      VisitRow,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (VisitRow, BaseReferences<_$AppDatabase, $VisitsTable, VisitRow>),
      VisitRow,
      PrefetchHooks Function()
    >;
typedef $$PagesTableCreateCompanionBuilder = PagesCompanion Function({
  required String url,
  Value<String> title,
  Value<int> visitCount,
  required DateTime lastVisitAt,
  Value<int> rowid,
});
typedef $$PagesTableUpdateCompanionBuilder = PagesCompanion Function({
  Value<String> url,
  Value<String> title,
  Value<int> visitCount,
  Value<DateTime> lastVisitAt,
  Value<int> rowid,
});

class $$PagesTableFilterComposer extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitCount => $composableBuilder(
    column: $table.visitCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PagesTableOrderingComposer
    extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitCount => $composableBuilder(
    column: $table.visitCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagesTable> {
  $$PagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get visitCount => $composableBuilder(
    column: $table.visitCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => column,
  );
}

class $$PagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PagesTable,
          PageRow,
          $$PagesTableFilterComposer,
          $$PagesTableOrderingComposer,
          $$PagesTableAnnotationComposer,
          $$PagesTableCreateCompanionBuilder,
          $$PagesTableUpdateCompanionBuilder,
          (PageRow, BaseReferences<_$AppDatabase, $PagesTable, PageRow>),
          PageRow,
          PrefetchHooks Function()
        > {
  $$PagesTableTableManager(_$AppDatabase db, $PagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> visitCount = const Value.absent(),
                Value<DateTime> lastVisitAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagesCompanion(
                url: url,
                title: title,
                visitCount: visitCount,
                lastVisitAt: lastVisitAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                Value<String> title = const Value.absent(),
                Value<int> visitCount = const Value.absent(),
                required DateTime lastVisitAt,
                Value<int> rowid = const Value.absent(),
              }) => PagesCompanion.insert(
                url: url,
                title: title,
                visitCount: visitCount,
                lastVisitAt: lastVisitAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagesTable, PageRow>(table),
                  BaseReferences<_$AppDatabase, $PagesTable, PageRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PagesTable,
      PageRow,
      $$PagesTableFilterComposer,
      $$PagesTableOrderingComposer,
      $$PagesTableAnnotationComposer,
      $$PagesTableCreateCompanionBuilder,
      $$PagesTableUpdateCompanionBuilder,
      (PageRow, BaseReferences<_$AppDatabase, $PagesTable, PageRow>),
      PageRow,
      PrefetchHooks Function()
    >;
typedef $$ReadingItemsTableCreateCompanionBuilder =
    ReadingItemsCompanion Function({
      Value<int> id,
      required String url,
      Value<String> title,
      required DateTime addedAt,
      Value<double> readFraction,
      Value<int> estimatedMinutes,
      Value<String?> offlinePath,
    });
typedef $$ReadingItemsTableUpdateCompanionBuilder =
    ReadingItemsCompanion Function({
      Value<int> id,
      Value<String> url,
      Value<String> title,
      Value<DateTime> addedAt,
      Value<double> readFraction,
      Value<int> estimatedMinutes,
      Value<String?> offlinePath,
    });

class $$ReadingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingItemsTable> {
  $$ReadingItemsTableFilterComposer({
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

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get readFraction => $composableBuilder(
    column: $table.readFraction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get offlinePath => $composableBuilder(
    column: $table.offlinePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingItemsTable> {
  $$ReadingItemsTableOrderingComposer({
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

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get readFraction => $composableBuilder(
    column: $table.readFraction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get offlinePath => $composableBuilder(
    column: $table.offlinePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingItemsTable> {
  $$ReadingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<double> get readFraction => $composableBuilder(
    column: $table.readFraction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get offlinePath => $composableBuilder(
    column: $table.offlinePath,
    builder: (column) => column,
  );
}

class $$ReadingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingItemsTable,
          ReadingRow,
          $$ReadingItemsTableFilterComposer,
          $$ReadingItemsTableOrderingComposer,
          $$ReadingItemsTableAnnotationComposer,
          $$ReadingItemsTableCreateCompanionBuilder,
          $$ReadingItemsTableUpdateCompanionBuilder,
          (
            ReadingRow,
            BaseReferences<_$AppDatabase, $ReadingItemsTable, ReadingRow>,
          ),
          ReadingRow,
          PrefetchHooks Function()
        > {
  $$ReadingItemsTableTableManager(_$AppDatabase db, $ReadingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<double> readFraction = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<String?> offlinePath = const Value.absent(),
              }) => ReadingItemsCompanion(
                id: id,
                url: url,
                title: title,
                addedAt: addedAt,
                readFraction: readFraction,
                estimatedMinutes: estimatedMinutes,
                offlinePath: offlinePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                Value<String> title = const Value.absent(),
                required DateTime addedAt,
                Value<double> readFraction = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<String?> offlinePath = const Value.absent(),
              }) => ReadingItemsCompanion.insert(
                id: id,
                url: url,
                title: title,
                addedAt: addedAt,
                readFraction: readFraction,
                estimatedMinutes: estimatedMinutes,
                offlinePath: offlinePath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingItemsTable, ReadingRow>(table),
                  BaseReferences<_$AppDatabase, $ReadingItemsTable, ReadingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingItemsTable,
      ReadingRow,
      $$ReadingItemsTableFilterComposer,
      $$ReadingItemsTableOrderingComposer,
      $$ReadingItemsTableAnnotationComposer,
      $$ReadingItemsTableCreateCompanionBuilder,
      $$ReadingItemsTableUpdateCompanionBuilder,
      (
        ReadingRow,
        BaseReferences<_$AppDatabase, $ReadingItemsTable, ReadingRow>,
      ),
      ReadingRow,
      PrefetchHooks Function()
    >;
typedef $$DownloadsTableCreateCompanionBuilder = DownloadsCompanion Function({
  required String taskId,
  required String url,
  required String fileName,
  Value<String> mimeType,
  Value<int?> totalBytes,
  Value<int> receivedBytes,
  required String status,
  required DateTime startedAt,
  Value<DateTime?> finishedAt,
  Value<String?> savedUri,
  Value<int> rowid,
});
typedef $$DownloadsTableUpdateCompanionBuilder = DownloadsCompanion Function({
  Value<String> taskId,
  Value<String> url,
  Value<String> fileName,
  Value<String> mimeType,
  Value<int?> totalBytes,
  Value<int> receivedBytes,
  Value<String> status,
  Value<DateTime> startedAt,
  Value<DateTime?> finishedAt,
  Value<String?> savedUri,
  Value<int> rowid,
});

class $$DownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedBytes => $composableBuilder(
    column: $table.receivedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savedUri => $composableBuilder(
    column: $table.savedUri,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedBytes => $composableBuilder(
    column: $table.receivedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savedUri => $composableBuilder(
    column: $table.savedUri,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receivedBytes => $composableBuilder(
    column: $table.receivedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get savedUri =>
      $composableBuilder(column: $table.savedUri, builder: (column) => column);
}

class $$DownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadsTable,
          DownloadRow,
          $$DownloadsTableFilterComposer,
          $$DownloadsTableOrderingComposer,
          $$DownloadsTableAnnotationComposer,
          $$DownloadsTableCreateCompanionBuilder,
          $$DownloadsTableUpdateCompanionBuilder,
          (
            DownloadRow,
            BaseReferences<_$AppDatabase, $DownloadsTable, DownloadRow>,
          ),
          DownloadRow,
          PrefetchHooks Function()
        > {
  $$DownloadsTableTableManager(_$AppDatabase db, $DownloadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> taskId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<int> receivedBytes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String?> savedUri = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadsCompanion(
                taskId: taskId,
                url: url,
                fileName: fileName,
                mimeType: mimeType,
                totalBytes: totalBytes,
                receivedBytes: receivedBytes,
                status: status,
                startedAt: startedAt,
                finishedAt: finishedAt,
                savedUri: savedUri,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String taskId,
                required String url,
                required String fileName,
                Value<String> mimeType = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<int> receivedBytes = const Value.absent(),
                required String status,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<String?> savedUri = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadsCompanion.insert(
                taskId: taskId,
                url: url,
                fileName: fileName,
                mimeType: mimeType,
                totalBytes: totalBytes,
                receivedBytes: receivedBytes,
                status: status,
                startedAt: startedAt,
                finishedAt: finishedAt,
                savedUri: savedUri,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadsTable, DownloadRow>(table),
                  BaseReferences<_$AppDatabase, $DownloadsTable, DownloadRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadsTable,
      DownloadRow,
      $$DownloadsTableFilterComposer,
      $$DownloadsTableOrderingComposer,
      $$DownloadsTableAnnotationComposer,
      $$DownloadsTableCreateCompanionBuilder,
      $$DownloadsTableUpdateCompanionBuilder,
      (
        DownloadRow,
        BaseReferences<_$AppDatabase, $DownloadsTable, DownloadRow>,
      ),
      DownloadRow,
      PrefetchHooks Function()
    >;
typedef $$TrackerDaysTableCreateCompanionBuilder =
    TrackerDaysCompanion Function({
      required String day,
      required String host,
      Value<int> blockedCount,
      Value<int> rowid,
    });
typedef $$TrackerDaysTableUpdateCompanionBuilder =
    TrackerDaysCompanion Function({
      Value<String> day,
      Value<String> host,
      Value<int> blockedCount,
      Value<int> rowid,
    });

class $$TrackerDaysTableFilterComposer
    extends Composer<_$AppDatabase, $TrackerDaysTable> {
  $$TrackerDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blockedCount => $composableBuilder(
    column: $table.blockedCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackerDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackerDaysTable> {
  $$TrackerDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blockedCount => $composableBuilder(
    column: $table.blockedCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackerDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackerDaysTable> {
  $$TrackerDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get blockedCount => $composableBuilder(
    column: $table.blockedCount,
    builder: (column) => column,
  );
}

class $$TrackerDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackerDaysTable,
          TrackerDayRow,
          $$TrackerDaysTableFilterComposer,
          $$TrackerDaysTableOrderingComposer,
          $$TrackerDaysTableAnnotationComposer,
          $$TrackerDaysTableCreateCompanionBuilder,
          $$TrackerDaysTableUpdateCompanionBuilder,
          (
            TrackerDayRow,
            BaseReferences<_$AppDatabase, $TrackerDaysTable, TrackerDayRow>,
          ),
          TrackerDayRow,
          PrefetchHooks Function()
        > {
  $$TrackerDaysTableTableManager(_$AppDatabase db, $TrackerDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackerDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackerDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackerDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> blockedCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackerDaysCompanion(
                day: day,
                host: host,
                blockedCount: blockedCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required String host,
                Value<int> blockedCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackerDaysCompanion.insert(
                day: day,
                host: host,
                blockedCount: blockedCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackerDaysTable, TrackerDayRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TrackerDaysTable,
                    TrackerDayRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackerDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackerDaysTable,
      TrackerDayRow,
      $$TrackerDaysTableFilterComposer,
      $$TrackerDaysTableOrderingComposer,
      $$TrackerDaysTableAnnotationComposer,
      $$TrackerDaysTableCreateCompanionBuilder,
      $$TrackerDaysTableUpdateCompanionBuilder,
      (
        TrackerDayRow,
        BaseReferences<_$AppDatabase, $TrackerDaysTable, TrackerDayRow>,
      ),
      TrackerDayRow,
      PrefetchHooks Function()
    >;
typedef $$SitePermissionsTableCreateCompanionBuilder =
    SitePermissionsCompanion Function({
      required String origin,
      required String kind,
      required bool allowed,
      Value<int> rowid,
    });
typedef $$SitePermissionsTableUpdateCompanionBuilder =
    SitePermissionsCompanion Function({
      Value<String> origin,
      Value<String> kind,
      Value<bool> allowed,
      Value<int> rowid,
    });

class $$SitePermissionsTableFilterComposer
    extends Composer<_$AppDatabase, $SitePermissionsTable> {
  $$SitePermissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowed => $composableBuilder(
    column: $table.allowed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SitePermissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SitePermissionsTable> {
  $$SitePermissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowed => $composableBuilder(
    column: $table.allowed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SitePermissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SitePermissionsTable> {
  $$SitePermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get allowed =>
      $composableBuilder(column: $table.allowed, builder: (column) => column);
}

class $$SitePermissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SitePermissionsTable,
          PermissionRow,
          $$SitePermissionsTableFilterComposer,
          $$SitePermissionsTableOrderingComposer,
          $$SitePermissionsTableAnnotationComposer,
          $$SitePermissionsTableCreateCompanionBuilder,
          $$SitePermissionsTableUpdateCompanionBuilder,
          (
            PermissionRow,
            BaseReferences<_$AppDatabase, $SitePermissionsTable, PermissionRow>,
          ),
          PermissionRow,
          PrefetchHooks Function()
        > {
  $$SitePermissionsTableTableManager(
    _$AppDatabase db,
    $SitePermissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SitePermissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SitePermissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SitePermissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> origin = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> allowed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SitePermissionsCompanion(
                origin: origin,
                kind: kind,
                allowed: allowed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String origin,
                required String kind,
                required bool allowed,
                Value<int> rowid = const Value.absent(),
              }) => SitePermissionsCompanion.insert(
                origin: origin,
                kind: kind,
                allowed: allowed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SitePermissionsTable, PermissionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SitePermissionsTable,
                    PermissionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SitePermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SitePermissionsTable,
      PermissionRow,
      $$SitePermissionsTableFilterComposer,
      $$SitePermissionsTableOrderingComposer,
      $$SitePermissionsTableAnnotationComposer,
      $$SitePermissionsTableCreateCompanionBuilder,
      $$SitePermissionsTableUpdateCompanionBuilder,
      (
        PermissionRow,
        BaseReferences<_$AppDatabase, $SitePermissionsTable, PermissionRow>,
      ),
      PermissionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TabsTableTableManager get tabs => $$TabsTableTableManager(_db, _db.tabs);
  $$BookmarkFoldersTableTableManager get bookmarkFolders =>
      $$BookmarkFoldersTableTableManager(_db, _db.bookmarkFolders);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db, _db.pages);
  $$ReadingItemsTableTableManager get readingItems =>
      $$ReadingItemsTableTableManager(_db, _db.readingItems);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
  $$TrackerDaysTableTableManager get trackerDays =>
      $$TrackerDaysTableTableManager(_db, _db.trackerDays);
  $$SitePermissionsTableTableManager get sitePermissions =>
      $$SitePermissionsTableTableManager(_db, _db.sitePermissions);
}
