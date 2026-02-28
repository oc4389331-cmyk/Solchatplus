// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalChatsTable extends LocalChats
    with TableInfo<$LocalChatsTable, LocalChat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _participantsMeta = const VerificationMeta(
    'participants',
  );
  @override
  late final GeneratedColumn<String> participants = GeneratedColumn<String>(
    'participants',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPrivateMeta = const VerificationMeta(
    'isPrivate',
  );
  @override
  late final GeneratedColumn<bool> isPrivate = GeneratedColumn<bool>(
    'is_private',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_private" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isGroupMeta = const VerificationMeta(
    'isGroup',
  );
  @override
  late final GeneratedColumn<bool> isGroup = GeneratedColumn<bool>(
    'is_group',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_group" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupImageMeta = const VerificationMeta(
    'groupImage',
  );
  @override
  late final GeneratedColumn<String> groupImage = GeneratedColumn<String>(
    'group_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rolesMeta = const VerificationMeta('roles');
  @override
  late final GeneratedColumn<String> roles = GeneratedColumn<String>(
    'roles',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageMeta = const VerificationMeta(
    'lastMessage',
  );
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
    'last_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageTypeMeta = const VerificationMeta(
    'lastMessageType',
  );
  @override
  late final GeneratedColumn<String> lastMessageType = GeneratedColumn<String>(
    'last_message_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _lastMessageTimeMeta = const VerificationMeta(
    'lastMessageTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageTime =
      GeneratedColumn<DateTime>(
        'last_message_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    participants,
    isPrivate,
    isGroup,
    name,
    groupImage,
    roles,
    createdBy,
    lastMessage,
    lastMessageType,
    lastMessageTime,
    isLocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('participants')) {
      context.handle(
        _participantsMeta,
        participants.isAcceptableOrUnknown(
          data['participants']!,
          _participantsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantsMeta);
    }
    if (data.containsKey('is_private')) {
      context.handle(
        _isPrivateMeta,
        isPrivate.isAcceptableOrUnknown(data['is_private']!, _isPrivateMeta),
      );
    }
    if (data.containsKey('is_group')) {
      context.handle(
        _isGroupMeta,
        isGroup.isAcceptableOrUnknown(data['is_group']!, _isGroupMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('group_image')) {
      context.handle(
        _groupImageMeta,
        groupImage.isAcceptableOrUnknown(data['group_image']!, _groupImageMeta),
      );
    }
    if (data.containsKey('roles')) {
      context.handle(
        _rolesMeta,
        roles.isAcceptableOrUnknown(data['roles']!, _rolesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('last_message')) {
      context.handle(
        _lastMessageMeta,
        lastMessage.isAcceptableOrUnknown(
          data['last_message']!,
          _lastMessageMeta,
        ),
      );
    }
    if (data.containsKey('last_message_type')) {
      context.handle(
        _lastMessageTypeMeta,
        lastMessageType.isAcceptableOrUnknown(
          data['last_message_type']!,
          _lastMessageTypeMeta,
        ),
      );
    }
    if (data.containsKey('last_message_time')) {
      context.handle(
        _lastMessageTimeMeta,
        lastMessageTime.isAcceptableOrUnknown(
          data['last_message_time']!,
          _lastMessageTimeMeta,
        ),
      );
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalChat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChat(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      participants:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}participants'],
          )!,
      isPrivate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_private'],
          )!,
      isGroup:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_group'],
          )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      groupImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_image'],
      ),
      roles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}roles'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      lastMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message'],
      ),
      lastMessageType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}last_message_type'],
          )!,
      lastMessageTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_time'],
      ),
      isLocked:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_locked'],
          )!,
    );
  }

  @override
  $LocalChatsTable createAlias(String alias) {
    return $LocalChatsTable(attachedDatabase, alias);
  }
}

class LocalChat extends DataClass implements Insertable<LocalChat> {
  final String id;
  final String participants;
  final bool isPrivate;
  final bool isGroup;
  final String? name;
  final String? groupImage;
  final String? roles;
  final String? createdBy;
  final String? lastMessage;
  final String lastMessageType;
  final DateTime? lastMessageTime;
  final bool isLocked;
  const LocalChat({
    required this.id,
    required this.participants,
    required this.isPrivate,
    required this.isGroup,
    this.name,
    this.groupImage,
    this.roles,
    this.createdBy,
    this.lastMessage,
    required this.lastMessageType,
    this.lastMessageTime,
    required this.isLocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['participants'] = Variable<String>(participants);
    map['is_private'] = Variable<bool>(isPrivate);
    map['is_group'] = Variable<bool>(isGroup);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || groupImage != null) {
      map['group_image'] = Variable<String>(groupImage);
    }
    if (!nullToAbsent || roles != null) {
      map['roles'] = Variable<String>(roles);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    map['last_message_type'] = Variable<String>(lastMessageType);
    if (!nullToAbsent || lastMessageTime != null) {
      map['last_message_time'] = Variable<DateTime>(lastMessageTime);
    }
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  LocalChatsCompanion toCompanion(bool nullToAbsent) {
    return LocalChatsCompanion(
      id: Value(id),
      participants: Value(participants),
      isPrivate: Value(isPrivate),
      isGroup: Value(isGroup),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      groupImage:
          groupImage == null && nullToAbsent
              ? const Value.absent()
              : Value(groupImage),
      roles:
          roles == null && nullToAbsent ? const Value.absent() : Value(roles),
      createdBy:
          createdBy == null && nullToAbsent
              ? const Value.absent()
              : Value(createdBy),
      lastMessage:
          lastMessage == null && nullToAbsent
              ? const Value.absent()
              : Value(lastMessage),
      lastMessageType: Value(lastMessageType),
      lastMessageTime:
          lastMessageTime == null && nullToAbsent
              ? const Value.absent()
              : Value(lastMessageTime),
      isLocked: Value(isLocked),
    );
  }

  factory LocalChat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChat(
      id: serializer.fromJson<String>(json['id']),
      participants: serializer.fromJson<String>(json['participants']),
      isPrivate: serializer.fromJson<bool>(json['isPrivate']),
      isGroup: serializer.fromJson<bool>(json['isGroup']),
      name: serializer.fromJson<String?>(json['name']),
      groupImage: serializer.fromJson<String?>(json['groupImage']),
      roles: serializer.fromJson<String?>(json['roles']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      lastMessageType: serializer.fromJson<String>(json['lastMessageType']),
      lastMessageTime: serializer.fromJson<DateTime?>(json['lastMessageTime']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'participants': serializer.toJson<String>(participants),
      'isPrivate': serializer.toJson<bool>(isPrivate),
      'isGroup': serializer.toJson<bool>(isGroup),
      'name': serializer.toJson<String?>(name),
      'groupImage': serializer.toJson<String?>(groupImage),
      'roles': serializer.toJson<String?>(roles),
      'createdBy': serializer.toJson<String?>(createdBy),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'lastMessageType': serializer.toJson<String>(lastMessageType),
      'lastMessageTime': serializer.toJson<DateTime?>(lastMessageTime),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  LocalChat copyWith({
    String? id,
    String? participants,
    bool? isPrivate,
    bool? isGroup,
    Value<String?> name = const Value.absent(),
    Value<String?> groupImage = const Value.absent(),
    Value<String?> roles = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> lastMessage = const Value.absent(),
    String? lastMessageType,
    Value<DateTime?> lastMessageTime = const Value.absent(),
    bool? isLocked,
  }) => LocalChat(
    id: id ?? this.id,
    participants: participants ?? this.participants,
    isPrivate: isPrivate ?? this.isPrivate,
    isGroup: isGroup ?? this.isGroup,
    name: name.present ? name.value : this.name,
    groupImage: groupImage.present ? groupImage.value : this.groupImage,
    roles: roles.present ? roles.value : this.roles,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
    lastMessageType: lastMessageType ?? this.lastMessageType,
    lastMessageTime:
        lastMessageTime.present ? lastMessageTime.value : this.lastMessageTime,
    isLocked: isLocked ?? this.isLocked,
  );
  LocalChat copyWithCompanion(LocalChatsCompanion data) {
    return LocalChat(
      id: data.id.present ? data.id.value : this.id,
      participants:
          data.participants.present
              ? data.participants.value
              : this.participants,
      isPrivate: data.isPrivate.present ? data.isPrivate.value : this.isPrivate,
      isGroup: data.isGroup.present ? data.isGroup.value : this.isGroup,
      name: data.name.present ? data.name.value : this.name,
      groupImage:
          data.groupImage.present ? data.groupImage.value : this.groupImage,
      roles: data.roles.present ? data.roles.value : this.roles,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      lastMessage:
          data.lastMessage.present ? data.lastMessage.value : this.lastMessage,
      lastMessageType:
          data.lastMessageType.present
              ? data.lastMessageType.value
              : this.lastMessageType,
      lastMessageTime:
          data.lastMessageTime.present
              ? data.lastMessageTime.value
              : this.lastMessageTime,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChat(')
          ..write('id: $id, ')
          ..write('participants: $participants, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('isGroup: $isGroup, ')
          ..write('name: $name, ')
          ..write('groupImage: $groupImage, ')
          ..write('roles: $roles, ')
          ..write('createdBy: $createdBy, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageType: $lastMessageType, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    participants,
    isPrivate,
    isGroup,
    name,
    groupImage,
    roles,
    createdBy,
    lastMessage,
    lastMessageType,
    lastMessageTime,
    isLocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChat &&
          other.id == this.id &&
          other.participants == this.participants &&
          other.isPrivate == this.isPrivate &&
          other.isGroup == this.isGroup &&
          other.name == this.name &&
          other.groupImage == this.groupImage &&
          other.roles == this.roles &&
          other.createdBy == this.createdBy &&
          other.lastMessage == this.lastMessage &&
          other.lastMessageType == this.lastMessageType &&
          other.lastMessageTime == this.lastMessageTime &&
          other.isLocked == this.isLocked);
}

class LocalChatsCompanion extends UpdateCompanion<LocalChat> {
  final Value<String> id;
  final Value<String> participants;
  final Value<bool> isPrivate;
  final Value<bool> isGroup;
  final Value<String?> name;
  final Value<String?> groupImage;
  final Value<String?> roles;
  final Value<String?> createdBy;
  final Value<String?> lastMessage;
  final Value<String> lastMessageType;
  final Value<DateTime?> lastMessageTime;
  final Value<bool> isLocked;
  final Value<int> rowid;
  const LocalChatsCompanion({
    this.id = const Value.absent(),
    this.participants = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.name = const Value.absent(),
    this.groupImage = const Value.absent(),
    this.roles = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageType = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalChatsCompanion.insert({
    required String id,
    required String participants,
    this.isPrivate = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.name = const Value.absent(),
    this.groupImage = const Value.absent(),
    this.roles = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageType = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       participants = Value(participants);
  static Insertable<LocalChat> custom({
    Expression<String>? id,
    Expression<String>? participants,
    Expression<bool>? isPrivate,
    Expression<bool>? isGroup,
    Expression<String>? name,
    Expression<String>? groupImage,
    Expression<String>? roles,
    Expression<String>? createdBy,
    Expression<String>? lastMessage,
    Expression<String>? lastMessageType,
    Expression<DateTime>? lastMessageTime,
    Expression<bool>? isLocked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (participants != null) 'participants': participants,
      if (isPrivate != null) 'is_private': isPrivate,
      if (isGroup != null) 'is_group': isGroup,
      if (name != null) 'name': name,
      if (groupImage != null) 'group_image': groupImage,
      if (roles != null) 'roles': roles,
      if (createdBy != null) 'created_by': createdBy,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageType != null) 'last_message_type': lastMessageType,
      if (lastMessageTime != null) 'last_message_time': lastMessageTime,
      if (isLocked != null) 'is_locked': isLocked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalChatsCompanion copyWith({
    Value<String>? id,
    Value<String>? participants,
    Value<bool>? isPrivate,
    Value<bool>? isGroup,
    Value<String?>? name,
    Value<String?>? groupImage,
    Value<String?>? roles,
    Value<String?>? createdBy,
    Value<String?>? lastMessage,
    Value<String>? lastMessageType,
    Value<DateTime?>? lastMessageTime,
    Value<bool>? isLocked,
    Value<int>? rowid,
  }) {
    return LocalChatsCompanion(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      isPrivate: isPrivate ?? this.isPrivate,
      isGroup: isGroup ?? this.isGroup,
      name: name ?? this.name,
      groupImage: groupImage ?? this.groupImage,
      roles: roles ?? this.roles,
      createdBy: createdBy ?? this.createdBy,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isLocked: isLocked ?? this.isLocked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (participants.present) {
      map['participants'] = Variable<String>(participants.value);
    }
    if (isPrivate.present) {
      map['is_private'] = Variable<bool>(isPrivate.value);
    }
    if (isGroup.present) {
      map['is_group'] = Variable<bool>(isGroup.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupImage.present) {
      map['group_image'] = Variable<String>(groupImage.value);
    }
    if (roles.present) {
      map['roles'] = Variable<String>(roles.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (lastMessageType.present) {
      map['last_message_type'] = Variable<String>(lastMessageType.value);
    }
    if (lastMessageTime.present) {
      map['last_message_time'] = Variable<DateTime>(lastMessageTime.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChatsCompanion(')
          ..write('id: $id, ')
          ..write('participants: $participants, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('isGroup: $isGroup, ')
          ..write('name: $name, ')
          ..write('groupImage: $groupImage, ')
          ..write('roles: $roles, ')
          ..write('createdBy: $createdBy, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageType: $lastMessageType, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('isLocked: $isLocked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMessagesTable extends LocalMessages
    with TableInfo<$LocalMessagesTable, LocalMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_chats (id)',
    ),
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageTempUrlMeta = const VerificationMeta(
    'imageTempUrl',
  );
  @override
  late final GeneratedColumn<String> imageTempUrl = GeneratedColumn<String>(
    'image_temp_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentAmountMeta = const VerificationMeta(
    'paymentAmount',
  );
  @override
  late final GeneratedColumn<double> paymentAmount = GeneratedColumn<double>(
    'payment_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentSignatureMeta = const VerificationMeta(
    'paymentSignature',
  );
  @override
  late final GeneratedColumn<String> paymentSignature = GeneratedColumn<String>(
    'payment_signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _deliveredMeta = const VerificationMeta(
    'delivered',
  );
  @override
  late final GeneratedColumn<bool> delivered = GeneratedColumn<bool>(
    'delivered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("delivered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localImagePathMeta = const VerificationMeta(
    'localImagePath',
  );
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
    'local_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentTokenMeta = const VerificationMeta(
    'paymentToken',
  );
  @override
  late final GeneratedColumn<String> paymentToken = GeneratedColumn<String>(
    'payment_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('SOL'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    senderId,
    type,
    textContent,
    imageTempUrl,
    paymentAmount,
    paymentSignature,
    timestamp,
    delivered,
    read,
    localImagePath,
    paymentToken,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    }
    if (data.containsKey('image_temp_url')) {
      context.handle(
        _imageTempUrlMeta,
        imageTempUrl.isAcceptableOrUnknown(
          data['image_temp_url']!,
          _imageTempUrlMeta,
        ),
      );
    }
    if (data.containsKey('payment_amount')) {
      context.handle(
        _paymentAmountMeta,
        paymentAmount.isAcceptableOrUnknown(
          data['payment_amount']!,
          _paymentAmountMeta,
        ),
      );
    }
    if (data.containsKey('payment_signature')) {
      context.handle(
        _paymentSignatureMeta,
        paymentSignature.isAcceptableOrUnknown(
          data['payment_signature']!,
          _paymentSignatureMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('delivered')) {
      context.handle(
        _deliveredMeta,
        delivered.isAcceptableOrUnknown(data['delivered']!, _deliveredMeta),
      );
    }
    if (data.containsKey('read')) {
      context.handle(
        _readMeta,
        read.isAcceptableOrUnknown(data['read']!, _readMeta),
      );
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
        _localImagePathMeta,
        localImagePath.isAcceptableOrUnknown(
          data['local_image_path']!,
          _localImagePathMeta,
        ),
      );
    }
    if (data.containsKey('payment_token')) {
      context.handle(
        _paymentTokenMeta,
        paymentToken.isAcceptableOrUnknown(
          data['payment_token']!,
          _paymentTokenMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMessage(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      chatId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chat_id'],
          )!,
      senderId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sender_id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      ),
      imageTempUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_temp_url'],
      ),
      paymentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}payment_amount'],
      ),
      paymentSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_signature'],
      ),
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
      delivered:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}delivered'],
          )!,
      read:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}read'],
          )!,
      localImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_image_path'],
      ),
      paymentToken:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payment_token'],
          )!,
    );
  }

  @override
  $LocalMessagesTable createAlias(String alias) {
    return $LocalMessagesTable(attachedDatabase, alias);
  }
}

class LocalMessage extends DataClass implements Insertable<LocalMessage> {
  final String id;
  final String chatId;
  final String senderId;
  final String type;
  final String? textContent;
  final String? imageTempUrl;
  final double? paymentAmount;
  final String? paymentSignature;
  final DateTime timestamp;
  final bool delivered;
  final bool read;
  final String? localImagePath;
  final String paymentToken;
  const LocalMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.type,
    this.textContent,
    this.imageTempUrl,
    this.paymentAmount,
    this.paymentSignature,
    required this.timestamp,
    required this.delivered,
    required this.read,
    this.localImagePath,
    required this.paymentToken,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['sender_id'] = Variable<String>(senderId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    if (!nullToAbsent || imageTempUrl != null) {
      map['image_temp_url'] = Variable<String>(imageTempUrl);
    }
    if (!nullToAbsent || paymentAmount != null) {
      map['payment_amount'] = Variable<double>(paymentAmount);
    }
    if (!nullToAbsent || paymentSignature != null) {
      map['payment_signature'] = Variable<String>(paymentSignature);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['delivered'] = Variable<bool>(delivered);
    map['read'] = Variable<bool>(read);
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    map['payment_token'] = Variable<String>(paymentToken);
    return map;
  }

  LocalMessagesCompanion toCompanion(bool nullToAbsent) {
    return LocalMessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      senderId: Value(senderId),
      type: Value(type),
      textContent:
          textContent == null && nullToAbsent
              ? const Value.absent()
              : Value(textContent),
      imageTempUrl:
          imageTempUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(imageTempUrl),
      paymentAmount:
          paymentAmount == null && nullToAbsent
              ? const Value.absent()
              : Value(paymentAmount),
      paymentSignature:
          paymentSignature == null && nullToAbsent
              ? const Value.absent()
              : Value(paymentSignature),
      timestamp: Value(timestamp),
      delivered: Value(delivered),
      read: Value(read),
      localImagePath:
          localImagePath == null && nullToAbsent
              ? const Value.absent()
              : Value(localImagePath),
      paymentToken: Value(paymentToken),
    );
  }

  factory LocalMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMessage(
      id: serializer.fromJson<String>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      type: serializer.fromJson<String>(json['type']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      imageTempUrl: serializer.fromJson<String?>(json['imageTempUrl']),
      paymentAmount: serializer.fromJson<double?>(json['paymentAmount']),
      paymentSignature: serializer.fromJson<String?>(json['paymentSignature']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      delivered: serializer.fromJson<bool>(json['delivered']),
      read: serializer.fromJson<bool>(json['read']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
      paymentToken: serializer.fromJson<String>(json['paymentToken']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatId': serializer.toJson<String>(chatId),
      'senderId': serializer.toJson<String>(senderId),
      'type': serializer.toJson<String>(type),
      'textContent': serializer.toJson<String?>(textContent),
      'imageTempUrl': serializer.toJson<String?>(imageTempUrl),
      'paymentAmount': serializer.toJson<double?>(paymentAmount),
      'paymentSignature': serializer.toJson<String?>(paymentSignature),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'delivered': serializer.toJson<bool>(delivered),
      'read': serializer.toJson<bool>(read),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'paymentToken': serializer.toJson<String>(paymentToken),
    };
  }

  LocalMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? type,
    Value<String?> textContent = const Value.absent(),
    Value<String?> imageTempUrl = const Value.absent(),
    Value<double?> paymentAmount = const Value.absent(),
    Value<String?> paymentSignature = const Value.absent(),
    DateTime? timestamp,
    bool? delivered,
    bool? read,
    Value<String?> localImagePath = const Value.absent(),
    String? paymentToken,
  }) => LocalMessage(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    senderId: senderId ?? this.senderId,
    type: type ?? this.type,
    textContent: textContent.present ? textContent.value : this.textContent,
    imageTempUrl: imageTempUrl.present ? imageTempUrl.value : this.imageTempUrl,
    paymentAmount:
        paymentAmount.present ? paymentAmount.value : this.paymentAmount,
    paymentSignature:
        paymentSignature.present
            ? paymentSignature.value
            : this.paymentSignature,
    timestamp: timestamp ?? this.timestamp,
    delivered: delivered ?? this.delivered,
    read: read ?? this.read,
    localImagePath:
        localImagePath.present ? localImagePath.value : this.localImagePath,
    paymentToken: paymentToken ?? this.paymentToken,
  );
  LocalMessage copyWithCompanion(LocalMessagesCompanion data) {
    return LocalMessage(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      type: data.type.present ? data.type.value : this.type,
      textContent:
          data.textContent.present ? data.textContent.value : this.textContent,
      imageTempUrl:
          data.imageTempUrl.present
              ? data.imageTempUrl.value
              : this.imageTempUrl,
      paymentAmount:
          data.paymentAmount.present
              ? data.paymentAmount.value
              : this.paymentAmount,
      paymentSignature:
          data.paymentSignature.present
              ? data.paymentSignature.value
              : this.paymentSignature,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      delivered: data.delivered.present ? data.delivered.value : this.delivered,
      read: data.read.present ? data.read.value : this.read,
      localImagePath:
          data.localImagePath.present
              ? data.localImagePath.value
              : this.localImagePath,
      paymentToken:
          data.paymentToken.present
              ? data.paymentToken.value
              : this.paymentToken,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessage(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('type: $type, ')
          ..write('textContent: $textContent, ')
          ..write('imageTempUrl: $imageTempUrl, ')
          ..write('paymentAmount: $paymentAmount, ')
          ..write('paymentSignature: $paymentSignature, ')
          ..write('timestamp: $timestamp, ')
          ..write('delivered: $delivered, ')
          ..write('read: $read, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('paymentToken: $paymentToken')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    senderId,
    type,
    textContent,
    imageTempUrl,
    paymentAmount,
    paymentSignature,
    timestamp,
    delivered,
    read,
    localImagePath,
    paymentToken,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMessage &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.senderId == this.senderId &&
          other.type == this.type &&
          other.textContent == this.textContent &&
          other.imageTempUrl == this.imageTempUrl &&
          other.paymentAmount == this.paymentAmount &&
          other.paymentSignature == this.paymentSignature &&
          other.timestamp == this.timestamp &&
          other.delivered == this.delivered &&
          other.read == this.read &&
          other.localImagePath == this.localImagePath &&
          other.paymentToken == this.paymentToken);
}

class LocalMessagesCompanion extends UpdateCompanion<LocalMessage> {
  final Value<String> id;
  final Value<String> chatId;
  final Value<String> senderId;
  final Value<String> type;
  final Value<String?> textContent;
  final Value<String?> imageTempUrl;
  final Value<double?> paymentAmount;
  final Value<String?> paymentSignature;
  final Value<DateTime> timestamp;
  final Value<bool> delivered;
  final Value<bool> read;
  final Value<String?> localImagePath;
  final Value<String> paymentToken;
  final Value<int> rowid;
  const LocalMessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.type = const Value.absent(),
    this.textContent = const Value.absent(),
    this.imageTempUrl = const Value.absent(),
    this.paymentAmount = const Value.absent(),
    this.paymentSignature = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.delivered = const Value.absent(),
    this.read = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.paymentToken = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMessagesCompanion.insert({
    required String id,
    required String chatId,
    required String senderId,
    this.type = const Value.absent(),
    this.textContent = const Value.absent(),
    this.imageTempUrl = const Value.absent(),
    this.paymentAmount = const Value.absent(),
    this.paymentSignature = const Value.absent(),
    required DateTime timestamp,
    this.delivered = const Value.absent(),
    this.read = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.paymentToken = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatId = Value(chatId),
       senderId = Value(senderId),
       timestamp = Value(timestamp);
  static Insertable<LocalMessage> custom({
    Expression<String>? id,
    Expression<String>? chatId,
    Expression<String>? senderId,
    Expression<String>? type,
    Expression<String>? textContent,
    Expression<String>? imageTempUrl,
    Expression<double>? paymentAmount,
    Expression<String>? paymentSignature,
    Expression<DateTime>? timestamp,
    Expression<bool>? delivered,
    Expression<bool>? read,
    Expression<String>? localImagePath,
    Expression<String>? paymentToken,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (senderId != null) 'sender_id': senderId,
      if (type != null) 'type': type,
      if (textContent != null) 'text_content': textContent,
      if (imageTempUrl != null) 'image_temp_url': imageTempUrl,
      if (paymentAmount != null) 'payment_amount': paymentAmount,
      if (paymentSignature != null) 'payment_signature': paymentSignature,
      if (timestamp != null) 'timestamp': timestamp,
      if (delivered != null) 'delivered': delivered,
      if (read != null) 'read': read,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (paymentToken != null) 'payment_token': paymentToken,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? chatId,
    Value<String>? senderId,
    Value<String>? type,
    Value<String?>? textContent,
    Value<String?>? imageTempUrl,
    Value<double?>? paymentAmount,
    Value<String?>? paymentSignature,
    Value<DateTime>? timestamp,
    Value<bool>? delivered,
    Value<bool>? read,
    Value<String?>? localImagePath,
    Value<String>? paymentToken,
    Value<int>? rowid,
  }) {
    return LocalMessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      textContent: textContent ?? this.textContent,
      imageTempUrl: imageTempUrl ?? this.imageTempUrl,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentSignature: paymentSignature ?? this.paymentSignature,
      timestamp: timestamp ?? this.timestamp,
      delivered: delivered ?? this.delivered,
      read: read ?? this.read,
      localImagePath: localImagePath ?? this.localImagePath,
      paymentToken: paymentToken ?? this.paymentToken,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (imageTempUrl.present) {
      map['image_temp_url'] = Variable<String>(imageTempUrl.value);
    }
    if (paymentAmount.present) {
      map['payment_amount'] = Variable<double>(paymentAmount.value);
    }
    if (paymentSignature.present) {
      map['payment_signature'] = Variable<String>(paymentSignature.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (delivered.present) {
      map['delivered'] = Variable<bool>(delivered.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (paymentToken.present) {
      map['payment_token'] = Variable<String>(paymentToken.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('type: $type, ')
          ..write('textContent: $textContent, ')
          ..write('imageTempUrl: $imageTempUrl, ')
          ..write('paymentAmount: $paymentAmount, ')
          ..write('paymentSignature: $paymentSignature, ')
          ..write('timestamp: $timestamp, ')
          ..write('delivered: $delivered, ')
          ..write('read: $read, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('paymentToken: $paymentToken, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _walletAddressMeta = const VerificationMeta(
    'walletAddress',
  );
  @override
  late final GeneratedColumn<String> walletAddress = GeneratedColumn<String>(
    'wallet_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileImageUrlMeta = const VerificationMeta(
    'profileImageUrl',
  );
  @override
  late final GeneratedColumn<String> profileImageUrl = GeneratedColumn<String>(
    'profile_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedMeta = const VerificationMeta(
    'verified',
  );
  @override
  late final GeneratedColumn<bool> verified = GeneratedColumn<bool>(
    'verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    uid,
    nickname,
    walletAddress,
    profileImageUrl,
    verified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('wallet_address')) {
      context.handle(
        _walletAddressMeta,
        walletAddress.isAcceptableOrUnknown(
          data['wallet_address']!,
          _walletAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_walletAddressMeta);
    }
    if (data.containsKey('profile_image_url')) {
      context.handle(
        _profileImageUrlMeta,
        profileImageUrl.isAcceptableOrUnknown(
          data['profile_image_url']!,
          _profileImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('verified')) {
      context.handle(
        _verifiedMeta,
        verified.isAcceptableOrUnknown(data['verified']!, _verifiedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      uid:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}uid'],
          )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      walletAddress:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}wallet_address'],
          )!,
      profileImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_image_url'],
      ),
      verified:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}verified'],
          )!,
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String uid;
  final String? nickname;
  final String walletAddress;
  final String? profileImageUrl;
  final bool verified;
  const LocalUser({
    required this.uid,
    this.nickname,
    required this.walletAddress,
    this.profileImageUrl,
    required this.verified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    map['wallet_address'] = Variable<String>(walletAddress);
    if (!nullToAbsent || profileImageUrl != null) {
      map['profile_image_url'] = Variable<String>(profileImageUrl);
    }
    map['verified'] = Variable<bool>(verified);
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      uid: Value(uid),
      nickname:
          nickname == null && nullToAbsent
              ? const Value.absent()
              : Value(nickname),
      walletAddress: Value(walletAddress),
      profileImageUrl:
          profileImageUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(profileImageUrl),
      verified: Value(verified),
    );
  }

  factory LocalUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      uid: serializer.fromJson<String>(json['uid']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      walletAddress: serializer.fromJson<String>(json['walletAddress']),
      profileImageUrl: serializer.fromJson<String?>(json['profileImageUrl']),
      verified: serializer.fromJson<bool>(json['verified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'nickname': serializer.toJson<String?>(nickname),
      'walletAddress': serializer.toJson<String>(walletAddress),
      'profileImageUrl': serializer.toJson<String?>(profileImageUrl),
      'verified': serializer.toJson<bool>(verified),
    };
  }

  LocalUser copyWith({
    String? uid,
    Value<String?> nickname = const Value.absent(),
    String? walletAddress,
    Value<String?> profileImageUrl = const Value.absent(),
    bool? verified,
  }) => LocalUser(
    uid: uid ?? this.uid,
    nickname: nickname.present ? nickname.value : this.nickname,
    walletAddress: walletAddress ?? this.walletAddress,
    profileImageUrl:
        profileImageUrl.present ? profileImageUrl.value : this.profileImageUrl,
    verified: verified ?? this.verified,
  );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      uid: data.uid.present ? data.uid.value : this.uid,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      walletAddress:
          data.walletAddress.present
              ? data.walletAddress.value
              : this.walletAddress,
      profileImageUrl:
          data.profileImageUrl.present
              ? data.profileImageUrl.value
              : this.profileImageUrl,
      verified: data.verified.present ? data.verified.value : this.verified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('uid: $uid, ')
          ..write('nickname: $nickname, ')
          ..write('walletAddress: $walletAddress, ')
          ..write('profileImageUrl: $profileImageUrl, ')
          ..write('verified: $verified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uid, nickname, walletAddress, profileImageUrl, verified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.uid == this.uid &&
          other.nickname == this.nickname &&
          other.walletAddress == this.walletAddress &&
          other.profileImageUrl == this.profileImageUrl &&
          other.verified == this.verified);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> uid;
  final Value<String?> nickname;
  final Value<String> walletAddress;
  final Value<String?> profileImageUrl;
  final Value<bool> verified;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.uid = const Value.absent(),
    this.nickname = const Value.absent(),
    this.walletAddress = const Value.absent(),
    this.profileImageUrl = const Value.absent(),
    this.verified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String uid,
    this.nickname = const Value.absent(),
    required String walletAddress,
    this.profileImageUrl = const Value.absent(),
    this.verified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uid = Value(uid),
       walletAddress = Value(walletAddress);
  static Insertable<LocalUser> custom({
    Expression<String>? uid,
    Expression<String>? nickname,
    Expression<String>? walletAddress,
    Expression<String>? profileImageUrl,
    Expression<bool>? verified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (nickname != null) 'nickname': nickname,
      if (walletAddress != null) 'wallet_address': walletAddress,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (verified != null) 'verified': verified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith({
    Value<String>? uid,
    Value<String?>? nickname,
    Value<String>? walletAddress,
    Value<String?>? profileImageUrl,
    Value<bool>? verified,
    Value<int>? rowid,
  }) {
    return LocalUsersCompanion(
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      walletAddress: walletAddress ?? this.walletAddress,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      verified: verified ?? this.verified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (walletAddress.present) {
      map['wallet_address'] = Variable<String>(walletAddress.value);
    }
    if (profileImageUrl.present) {
      map['profile_image_url'] = Variable<String>(profileImageUrl.value);
    }
    if (verified.present) {
      map['verified'] = Variable<bool>(verified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('uid: $uid, ')
          ..write('nickname: $nickname, ')
          ..write('walletAddress: $walletAddress, ')
          ..write('profileImageUrl: $profileImageUrl, ')
          ..write('verified: $verified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalContactsTable extends LocalContacts
    with TableInfo<$LocalContactsTable, LocalContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [address, customName, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    } else if (isInserting) {
      context.missing(_customNameMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {address};
  @override
  LocalContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalContact(
      address:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}address'],
          )!,
      customName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}custom_name'],
          )!,
      addedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}added_at'],
          )!,
    );
  }

  @override
  $LocalContactsTable createAlias(String alias) {
    return $LocalContactsTable(attachedDatabase, alias);
  }
}

class LocalContact extends DataClass implements Insertable<LocalContact> {
  final String address;
  final String customName;
  final DateTime addedAt;
  const LocalContact({
    required this.address,
    required this.customName,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['address'] = Variable<String>(address);
    map['custom_name'] = Variable<String>(customName);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  LocalContactsCompanion toCompanion(bool nullToAbsent) {
    return LocalContactsCompanion(
      address: Value(address),
      customName: Value(customName),
      addedAt: Value(addedAt),
    );
  }

  factory LocalContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalContact(
      address: serializer.fromJson<String>(json['address']),
      customName: serializer.fromJson<String>(json['customName']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'address': serializer.toJson<String>(address),
      'customName': serializer.toJson<String>(customName),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  LocalContact copyWith({
    String? address,
    String? customName,
    DateTime? addedAt,
  }) => LocalContact(
    address: address ?? this.address,
    customName: customName ?? this.customName,
    addedAt: addedAt ?? this.addedAt,
  );
  LocalContact copyWithCompanion(LocalContactsCompanion data) {
    return LocalContact(
      address: data.address.present ? data.address.value : this.address,
      customName:
          data.customName.present ? data.customName.value : this.customName,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalContact(')
          ..write('address: $address, ')
          ..write('customName: $customName, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(address, customName, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalContact &&
          other.address == this.address &&
          other.customName == this.customName &&
          other.addedAt == this.addedAt);
}

class LocalContactsCompanion extends UpdateCompanion<LocalContact> {
  final Value<String> address;
  final Value<String> customName;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const LocalContactsCompanion({
    this.address = const Value.absent(),
    this.customName = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalContactsCompanion.insert({
    required String address,
    required String customName,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : address = Value(address),
       customName = Value(customName);
  static Insertable<LocalContact> custom({
    Expression<String>? address,
    Expression<String>? customName,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (address != null) 'address': address,
      if (customName != null) 'custom_name': customName,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalContactsCompanion copyWith({
    Value<String>? address,
    Value<String>? customName,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return LocalContactsCompanion(
      address: address ?? this.address,
      customName: customName ?? this.customName,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalContactsCompanion(')
          ..write('address: $address, ')
          ..write('customName: $customName, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalChatsTable localChats = $LocalChatsTable(this);
  late final $LocalMessagesTable localMessages = $LocalMessagesTable(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $LocalContactsTable localContacts = $LocalContactsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localChats,
    localMessages,
    localUsers,
    localContacts,
  ];
}

typedef $$LocalChatsTableCreateCompanionBuilder =
    LocalChatsCompanion Function({
      required String id,
      required String participants,
      Value<bool> isPrivate,
      Value<bool> isGroup,
      Value<String?> name,
      Value<String?> groupImage,
      Value<String?> roles,
      Value<String?> createdBy,
      Value<String?> lastMessage,
      Value<String> lastMessageType,
      Value<DateTime?> lastMessageTime,
      Value<bool> isLocked,
      Value<int> rowid,
    });
typedef $$LocalChatsTableUpdateCompanionBuilder =
    LocalChatsCompanion Function({
      Value<String> id,
      Value<String> participants,
      Value<bool> isPrivate,
      Value<bool> isGroup,
      Value<String?> name,
      Value<String?> groupImage,
      Value<String?> roles,
      Value<String?> createdBy,
      Value<String?> lastMessage,
      Value<String> lastMessageType,
      Value<DateTime?> lastMessageTime,
      Value<bool> isLocked,
      Value<int> rowid,
    });

final class $$LocalChatsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalChatsTable, LocalChat> {
  $$LocalChatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalMessagesTable, List<LocalMessage>>
  _localMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localMessages,
    aliasName: $_aliasNameGenerator(db.localChats.id, db.localMessages.chatId),
  );

  $$LocalMessagesTableProcessedTableManager get localMessagesRefs {
    final manager = $$LocalMessagesTableTableManager(
      $_db,
      $_db.localMessages,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalChatsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableFilterComposer({
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

  ColumnFilters<String> get participants => $composableBuilder(
    column: $table.participants,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupImage => $composableBuilder(
    column: $table.groupImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roles => $composableBuilder(
    column: $table.roles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageType => $composableBuilder(
    column: $table.lastMessageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localMessagesRefs(
    Expression<bool> Function($$LocalMessagesTableFilterComposer f) f,
  ) {
    final $$LocalMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localMessages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalMessagesTableFilterComposer(
            $db: $db,
            $table: $db.localMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableOrderingComposer({
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

  ColumnOrderings<String> get participants => $composableBuilder(
    column: $table.participants,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupImage => $composableBuilder(
    column: $table.groupImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roles => $composableBuilder(
    column: $table.roles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageType => $composableBuilder(
    column: $table.lastMessageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get participants => $composableBuilder(
    column: $table.participants,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrivate =>
      $composableBuilder(column: $table.isPrivate, builder: (column) => column);

  GeneratedColumn<bool> get isGroup =>
      $composableBuilder(column: $table.isGroup, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get groupImage => $composableBuilder(
    column: $table.groupImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roles =>
      $composableBuilder(column: $table.roles, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get lastMessage => $composableBuilder(
    column: $table.lastMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessageType => $composableBuilder(
    column: $table.lastMessageType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageTime => $composableBuilder(
    column: $table.lastMessageTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  Expression<T> localMessagesRefs<T extends Object>(
    Expression<T> Function($$LocalMessagesTableAnnotationComposer a) f,
  ) {
    final $$LocalMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localMessages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.localMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalChatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalChatsTable,
          LocalChat,
          $$LocalChatsTableFilterComposer,
          $$LocalChatsTableOrderingComposer,
          $$LocalChatsTableAnnotationComposer,
          $$LocalChatsTableCreateCompanionBuilder,
          $$LocalChatsTableUpdateCompanionBuilder,
          (LocalChat, $$LocalChatsTableReferences),
          LocalChat,
          PrefetchHooks Function({bool localMessagesRefs})
        > {
  $$LocalChatsTableTableManager(_$AppDatabase db, $LocalChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> participants = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> groupImage = const Value.absent(),
                Value<String?> roles = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<String> lastMessageType = const Value.absent(),
                Value<DateTime?> lastMessageTime = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChatsCompanion(
                id: id,
                participants: participants,
                isPrivate: isPrivate,
                isGroup: isGroup,
                name: name,
                groupImage: groupImage,
                roles: roles,
                createdBy: createdBy,
                lastMessage: lastMessage,
                lastMessageType: lastMessageType,
                lastMessageTime: lastMessageTime,
                isLocked: isLocked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String participants,
                Value<bool> isPrivate = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> groupImage = const Value.absent(),
                Value<String?> roles = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> lastMessage = const Value.absent(),
                Value<String> lastMessageType = const Value.absent(),
                Value<DateTime?> lastMessageTime = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChatsCompanion.insert(
                id: id,
                participants: participants,
                isPrivate: isPrivate,
                isGroup: isGroup,
                name: name,
                groupImage: groupImage,
                roles: roles,
                createdBy: createdBy,
                lastMessage: lastMessage,
                lastMessageType: lastMessageType,
                lastMessageTime: lastMessageTime,
                isLocked: isLocked,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LocalChatsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({localMessagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localMessagesRefs) db.localMessages,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localMessagesRefs)
                    await $_getPrefetchedData<
                      LocalChat,
                      $LocalChatsTable,
                      LocalMessage
                    >(
                      currentTable: table,
                      referencedTable: $$LocalChatsTableReferences
                          ._localMessagesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$LocalChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).localMessagesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.chatId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalChatsTable,
      LocalChat,
      $$LocalChatsTableFilterComposer,
      $$LocalChatsTableOrderingComposer,
      $$LocalChatsTableAnnotationComposer,
      $$LocalChatsTableCreateCompanionBuilder,
      $$LocalChatsTableUpdateCompanionBuilder,
      (LocalChat, $$LocalChatsTableReferences),
      LocalChat,
      PrefetchHooks Function({bool localMessagesRefs})
    >;
typedef $$LocalMessagesTableCreateCompanionBuilder =
    LocalMessagesCompanion Function({
      required String id,
      required String chatId,
      required String senderId,
      Value<String> type,
      Value<String?> textContent,
      Value<String?> imageTempUrl,
      Value<double?> paymentAmount,
      Value<String?> paymentSignature,
      required DateTime timestamp,
      Value<bool> delivered,
      Value<bool> read,
      Value<String?> localImagePath,
      Value<String> paymentToken,
      Value<int> rowid,
    });
typedef $$LocalMessagesTableUpdateCompanionBuilder =
    LocalMessagesCompanion Function({
      Value<String> id,
      Value<String> chatId,
      Value<String> senderId,
      Value<String> type,
      Value<String?> textContent,
      Value<String?> imageTempUrl,
      Value<double?> paymentAmount,
      Value<String?> paymentSignature,
      Value<DateTime> timestamp,
      Value<bool> delivered,
      Value<bool> read,
      Value<String?> localImagePath,
      Value<String> paymentToken,
      Value<int> rowid,
    });

final class $$LocalMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $LocalMessagesTable, LocalMessage> {
  $$LocalMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalChatsTable _chatIdTable(_$AppDatabase db) =>
      db.localChats.createAlias(
        $_aliasNameGenerator(db.localMessages.chatId, db.localChats.id),
      );

  $$LocalChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<String>('chat_id')!;

    final manager = $$LocalChatsTableTableManager(
      $_db,
      $_db.localChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableFilterComposer({
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

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageTempUrl => $composableBuilder(
    column: $table.imageTempUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paymentAmount => $composableBuilder(
    column: $table.paymentAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentSignature => $composableBuilder(
    column: $table.paymentSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get delivered => $composableBuilder(
    column: $table.delivered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentToken => $composableBuilder(
    column: $table.paymentToken,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalChatsTableFilterComposer get chatId {
    final $$LocalChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.localChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalChatsTableFilterComposer(
            $db: $db,
            $table: $db.localChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageTempUrl => $composableBuilder(
    column: $table.imageTempUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paymentAmount => $composableBuilder(
    column: $table.paymentAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentSignature => $composableBuilder(
    column: $table.paymentSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get delivered => $composableBuilder(
    column: $table.delivered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentToken => $composableBuilder(
    column: $table.paymentToken,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalChatsTableOrderingComposer get chatId {
    final $$LocalChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.localChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalChatsTableOrderingComposer(
            $db: $db,
            $table: $db.localChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageTempUrl => $composableBuilder(
    column: $table.imageTempUrl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get paymentAmount => $composableBuilder(
    column: $table.paymentAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentSignature => $composableBuilder(
    column: $table.paymentSignature,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get delivered =>
      $composableBuilder(column: $table.delivered, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
    column: $table.localImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentToken => $composableBuilder(
    column: $table.paymentToken,
    builder: (column) => column,
  );

  $$LocalChatsTableAnnotationComposer get chatId {
    final $$LocalChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.localChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.localChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMessagesTable,
          LocalMessage,
          $$LocalMessagesTableFilterComposer,
          $$LocalMessagesTableOrderingComposer,
          $$LocalMessagesTableAnnotationComposer,
          $$LocalMessagesTableCreateCompanionBuilder,
          $$LocalMessagesTableUpdateCompanionBuilder,
          (LocalMessage, $$LocalMessagesTableReferences),
          LocalMessage,
          PrefetchHooks Function({bool chatId})
        > {
  $$LocalMessagesTableTableManager(_$AppDatabase db, $LocalMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String?> imageTempUrl = const Value.absent(),
                Value<double?> paymentAmount = const Value.absent(),
                Value<String?> paymentSignature = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> delivered = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                Value<String> paymentToken = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMessagesCompanion(
                id: id,
                chatId: chatId,
                senderId: senderId,
                type: type,
                textContent: textContent,
                imageTempUrl: imageTempUrl,
                paymentAmount: paymentAmount,
                paymentSignature: paymentSignature,
                timestamp: timestamp,
                delivered: delivered,
                read: read,
                localImagePath: localImagePath,
                paymentToken: paymentToken,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chatId,
                required String senderId,
                Value<String> type = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String?> imageTempUrl = const Value.absent(),
                Value<double?> paymentAmount = const Value.absent(),
                Value<String?> paymentSignature = const Value.absent(),
                required DateTime timestamp,
                Value<bool> delivered = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<String?> localImagePath = const Value.absent(),
                Value<String> paymentToken = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMessagesCompanion.insert(
                id: id,
                chatId: chatId,
                senderId: senderId,
                type: type,
                textContent: textContent,
                imageTempUrl: imageTempUrl,
                paymentAmount: paymentAmount,
                paymentSignature: paymentSignature,
                timestamp: timestamp,
                delivered: delivered,
                read: read,
                localImagePath: localImagePath,
                paymentToken: paymentToken,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LocalMessagesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({chatId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                if (chatId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.chatId,
                            referencedTable: $$LocalMessagesTableReferences
                                ._chatIdTable(db),
                            referencedColumn:
                                $$LocalMessagesTableReferences
                                    ._chatIdTable(db)
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

typedef $$LocalMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMessagesTable,
      LocalMessage,
      $$LocalMessagesTableFilterComposer,
      $$LocalMessagesTableOrderingComposer,
      $$LocalMessagesTableAnnotationComposer,
      $$LocalMessagesTableCreateCompanionBuilder,
      $$LocalMessagesTableUpdateCompanionBuilder,
      (LocalMessage, $$LocalMessagesTableReferences),
      LocalMessage,
      PrefetchHooks Function({bool chatId})
    >;
typedef $$LocalUsersTableCreateCompanionBuilder =
    LocalUsersCompanion Function({
      required String uid,
      Value<String?> nickname,
      required String walletAddress,
      Value<String?> profileImageUrl,
      Value<bool> verified,
      Value<int> rowid,
    });
typedef $$LocalUsersTableUpdateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<String> uid,
      Value<String?> nickname,
      Value<String> walletAddress,
      Value<String?> profileImageUrl,
      Value<bool> verified,
      Value<int> rowid,
    });

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletAddress => $composableBuilder(
    column: $table.walletAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileImageUrl => $composableBuilder(
    column: $table.profileImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletAddress => $composableBuilder(
    column: $table.walletAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileImageUrl => $composableBuilder(
    column: $table.profileImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get walletAddress => $composableBuilder(
    column: $table.walletAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileImageUrl => $composableBuilder(
    column: $table.profileImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get verified =>
      $composableBuilder(column: $table.verified, builder: (column) => column);
}

class $$LocalUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUsersTable,
          LocalUser,
          $$LocalUsersTableFilterComposer,
          $$LocalUsersTableOrderingComposer,
          $$LocalUsersTableAnnotationComposer,
          $$LocalUsersTableCreateCompanionBuilder,
          $$LocalUsersTableUpdateCompanionBuilder,
          (
            LocalUser,
            BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>,
          ),
          LocalUser,
          PrefetchHooks Function()
        > {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uid = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String> walletAddress = const Value.absent(),
                Value<String?> profileImageUrl = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion(
                uid: uid,
                nickname: nickname,
                walletAddress: walletAddress,
                profileImageUrl: profileImageUrl,
                verified: verified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uid,
                Value<String?> nickname = const Value.absent(),
                required String walletAddress,
                Value<String?> profileImageUrl = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion.insert(
                uid: uid,
                nickname: nickname,
                walletAddress: walletAddress,
                profileImageUrl: profileImageUrl,
                verified: verified,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUsersTable,
      LocalUser,
      $$LocalUsersTableFilterComposer,
      $$LocalUsersTableOrderingComposer,
      $$LocalUsersTableAnnotationComposer,
      $$LocalUsersTableCreateCompanionBuilder,
      $$LocalUsersTableUpdateCompanionBuilder,
      (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
      LocalUser,
      PrefetchHooks Function()
    >;
typedef $$LocalContactsTableCreateCompanionBuilder =
    LocalContactsCompanion Function({
      required String address,
      required String customName,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });
typedef $$LocalContactsTableUpdateCompanionBuilder =
    LocalContactsCompanion Function({
      Value<String> address,
      Value<String> customName,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

class $$LocalContactsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalContactsTable> {
  $$LocalContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalContactsTable> {
  $$LocalContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalContactsTable> {
  $$LocalContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$LocalContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalContactsTable,
          LocalContact,
          $$LocalContactsTableFilterComposer,
          $$LocalContactsTableOrderingComposer,
          $$LocalContactsTableAnnotationComposer,
          $$LocalContactsTableCreateCompanionBuilder,
          $$LocalContactsTableUpdateCompanionBuilder,
          (
            LocalContact,
            BaseReferences<_$AppDatabase, $LocalContactsTable, LocalContact>,
          ),
          LocalContact,
          PrefetchHooks Function()
        > {
  $$LocalContactsTableTableManager(_$AppDatabase db, $LocalContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LocalContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LocalContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LocalContactsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> address = const Value.absent(),
                Value<String> customName = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalContactsCompanion(
                address: address,
                customName: customName,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String address,
                required String customName,
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalContactsCompanion.insert(
                address: address,
                customName: customName,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalContactsTable,
      LocalContact,
      $$LocalContactsTableFilterComposer,
      $$LocalContactsTableOrderingComposer,
      $$LocalContactsTableAnnotationComposer,
      $$LocalContactsTableCreateCompanionBuilder,
      $$LocalContactsTableUpdateCompanionBuilder,
      (
        LocalContact,
        BaseReferences<_$AppDatabase, $LocalContactsTable, LocalContact>,
      ),
      LocalContact,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalChatsTableTableManager get localChats =>
      $$LocalChatsTableTableManager(_db, _db.localChats);
  $$LocalMessagesTableTableManager get localMessages =>
      $$LocalMessagesTableTableManager(_db, _db.localMessages);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$LocalContactsTableTableManager get localContacts =>
      $$LocalContactsTableTableManager(_db, _db.localContacts);
}
