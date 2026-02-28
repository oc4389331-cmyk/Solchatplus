import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

class LocalChats extends Table {
  TextColumn get id => text()(); // Firestore chat ID
  TextColumn get participants => text()(); // JSON string of participants
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();
  BoolColumn get isGroup => boolean().withDefault(const Constant(false))();
  TextColumn get name => text().nullable()(); // Group name
  TextColumn get groupImage => text().nullable()();
  TextColumn get roles => text().nullable()(); // JSON string of roles mapping {address: role}
  TextColumn get createdBy => text().nullable()();
  TextColumn get lastMessage => text().nullable()();
  TextColumn get lastMessageType => text().withDefault(const Constant('text'))();
  DateTimeColumn get lastMessageTime => dateTime().nullable()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))(); // Group locking

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMessages extends Table {
  TextColumn get id => text()(); // Firestore message ID
  TextColumn get chatId => text().references(LocalChats, #id)();
  TextColumn get senderId => text()();
  TextColumn get type => text().withDefault(const Constant('text'))(); // text, image, payment
  TextColumn get textContent => text().nullable()();
  TextColumn get imageTempUrl => text().nullable()(); // URL or local path
  RealColumn get paymentAmount => real().nullable()();
  TextColumn get paymentSignature => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get delivered => boolean().withDefault(const Constant(false))();
  BoolColumn get read => boolean().withDefault(const Constant(false))();

  TextColumn get localImagePath => text().nullable()(); // Path on device
  TextColumn get paymentToken => text().withDefault(const Constant('SOL'))(); // SOL or SKR

  @override
  Set<Column> get primaryKey => {id};
}

// Optional: Store basic user info for quick lookup in chats
class LocalUsers extends Table {
  TextColumn get uid => text()();
  TextColumn get nickname => text().nullable()();
  TextColumn get walletAddress => text()();
  TextColumn get profileImageUrl => text().nullable()();
  BoolColumn get verified => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {uid};
}

class LocalContacts extends Table {
  TextColumn get address => text()();
  TextColumn get customName => text()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {address};
}

@DriftDatabase(tables: [LocalChats, LocalMessages, LocalUsers, LocalContacts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(localMessages, localMessages.localImagePath);
        }
        if (from < 3) {
          await m.createTable(localContacts);
        }
        if (from < 4) {
          await m.addColumn(localMessages, localMessages.paymentToken);
        }
        if (from < 5) {
          await m.addColumn(localChats, localChats.isGroup);
          await m.addColumn(localChats, localChats.name);
          await m.addColumn(localChats, localChats.groupImage);
          await m.addColumn(localChats, localChats.roles);
        }
        if (from < 6) {
          await m.addColumn(localChats, localChats.isLocked);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temp directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
