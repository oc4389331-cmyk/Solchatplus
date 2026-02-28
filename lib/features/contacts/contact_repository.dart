import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/chat/data/local/app_database.dart';

// Provider for the repository
final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ContactRepository(db);
});

// Stream provider to watch a specific contact's custom name
final contactNameProvider = StreamProvider.family<String?, String>((ref, address) {
  final repo = ref.watch(contactRepositoryProvider);
  return repo.watchContactName(address);
});

final contactsProvider = StreamProvider<List<LocalContact>>((ref) {
  final repo = ref.watch(contactRepositoryProvider);
  return repo.watchAllContacts();
});

final suggestedMembersProvider = StreamProvider<List<LocalContact>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final contactsAsync = ref.watch(contactsProvider);
  
  return db.select(db.localChats).watch().map((chats) {
    final contacts = contactsAsync.value ?? [];
    final contactAddresses = contacts.map((c) => c.address).toSet();
    
    final suggested = [...contacts];
    final seenAddresses = {...contactAddresses};
    
    for (var chat in chats) {
      if (chat.isGroup) continue; // Skip group participants for now to avoid noise
      
      final participants = chat.participants.split(',');
      for (var addr in participants) {
        // Skip self (this will be filtered in UI anyway, but good to be clean)
        if (!seenAddresses.contains(addr) && addr.isNotEmpty) {
          seenAddresses.add(addr);
          suggested.add(LocalContact(
            address: addr,
            customName: addr, // Default to address if no name saved
            addedAt: chat.lastMessageTime ?? DateTime.now(),
          ));
        }
      }
    }
    
    return suggested;
  });
});

class ContactRepository {
  final AppDatabase _db;

  ContactRepository(this._db);

  // Save or update a contact
  Future<void> saveContact(String address, String name) async {
    await _db.into(_db.localContacts).insertOnConflictUpdate(
      LocalContactsCompanion(
        address: Value(address),
        customName: Value(name),
        addedAt: Value(DateTime.now()),
      ),
    );
  }

  // Get a contact's name (one-shot)
  Future<String?> getContactName(String address) async {
    final query = _db.select(_db.localContacts)
      ..where((tbl) => tbl.address.equals(address));
    final result = await query.getSingleOrNull();
    return result?.customName;
  }

  // Watch for changes to a contact's name
  Stream<String?> watchContactName(String address) {
    final query = _db.select(_db.localContacts)
      ..where((tbl) => tbl.address.equals(address));
    
    return query.watchSingleOrNull().map((record) => record?.customName);
  }
  
  // Get all contacts
  Future<List<LocalContact>> getAllContacts() async {
    return await _db.select(_db.localContacts).get();
  }

  // Search local contacts by custom name or address
  Future<List<LocalContact>> searchContacts(String query) async {
    final lowerQuery = query.toLowerCase();
    return await (_db.select(_db.localContacts)
      ..where((tbl) => 
          tbl.customName.like('%$query%') | 
          tbl.customName.like('%$lowerQuery%') |
          tbl.address.like('%$query%') // Also search by address
      ))
      .get();
  }

  // Watch all contacts
  Stream<List<LocalContact>> watchAllContacts() {
    return _db.select(_db.localContacts).watch();
  }
}
