import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide Query;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/chat/data/local/app_database.dart';
import 'package:solchat/models/message_model.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb, defaultTargetPlatform

import 'dart:io';
import 'package:solchat/services/storage_service.dart';

import 'package:solchat/services/notification_service.dart';
import 'package:solchat/services/notification_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final notificationService = ref.watch(notificationServiceProvider);
  return ChatRepository(db, firestore, ref, notificationService);
});

class ChatRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final Ref _ref;
  final NotificationService _notificationService;
  final _uuid = const Uuid();

  ChatRepository(this._db, this._firestore, this._ref, this._notificationService) {
    // Listen for incoming notifications in the foreground to force sync
    _notificationService.onChatIdReceived.listen((chatId) {
      print('ChatRepository: Received FCM signal for $chatId, forcing sync...');
      syncMessages(chatId);
    });
  }

  StreamSubscription<QuerySnapshot>? _chatsSubscription;
  final Map<String, StreamSubscription<QuerySnapshot>> _messageSubscriptions = {};

  void dispose() {
    _chatsSubscription?.cancel();
    for (var sub in _messageSubscriptions.values) {
      sub.cancel();
    }
    _messageSubscriptions.clear();
  }

  // --- Chats ---

  Stream<List<LocalChat>> getChats() {
    return _db.select(_db.localChats).watch();
  }

  // Future version for single-time fetching (e.g. for search)
  Future<List<LocalChat>> getChatsFuture() {
    return _db.select(_db.localChats).get();
  }

  Future<void> syncChats(String userAddress) async {
    await _chatsSubscription?.cancel();

    _chatsSubscription = _firestore
        .collection('chats')
        .where('participants', arrayContains: userAddress)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.metadata.hasPendingWrites) {
        // Skip optimistic local events for syncChats to avoid race conditions with deleteChat/clearChat
        // Let the actual server response dictate the final state.
        return;
      }
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          
          // Check if hidden by user
          // Use safer casting
          final rawHidden = data['hiddenBy'];
          List<String> hiddenBy = [];
          if (rawHidden is List) {
             hiddenBy = rawHidden.map((e) => e.toString()).toList();
          }

          if (hiddenBy.contains(userAddress)) {
               // If it exists locally, delete it (case where we just hid it on another device)
               await _db.delete(_db.localChats).delete(LocalChatsCompanion(id: Value(doc.id)));
               continue; 
          }

          await _db.into(_db.localChats).insertOnConflictUpdate(
                LocalChatsCompanion(
                  id: Value(doc.id),
                  participants: Value((data['participants'] as List).join(',')),
                  isPrivate: Value(data['isPrivate'] ?? false),
                  isGroup: Value(data['isGroup'] ?? false),
                  name: Value(data['name']),
                  groupImage: Value(data['groupImage']),
                  roles: Value(data['roles'] != null ? jsonEncode(data['roles']) : null),
                  createdBy: Value(data['createdBy']),
                  lastMessage: Value(data['lastMessage']),
                  lastMessageType: Value(data['lastMessageType'] ?? 'text'),
                  lastMessageTime: Value((data['lastMessageTime'] as Timestamp?)?.toDate()),
                  isLocked: Value(data['isLocked'] ?? false),
                ),
              );
              
          // Trigger message sync for this active chat so that arriving messages are downloaded immediately
          // even if push notifications are disabled.
          syncMessages(doc.id);
        } catch (e) {
          print('Error processing chat doc ${doc.id}: $e');
        }
      }
    }, onError: (e) {
      print('Error listening to chats: $e');
    });
  }

  Future<String> createChat(String userAddress1, String userAddress2, {bool isPrivate = false}) async {
    // 1. Deterministic ID: Sort addresses to ensure unique ID for the pair
    final users = [userAddress1, userAddress2]..sort();
    final chatId = '${users[0]}_${users[1]}';
    
    // Check if chat already exists in Firestore specifically to avoid overriding data if not needed
    // But set() with merge: true or check exists is safer.
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    
    if (!chatDoc.exists) {
      // Create new chat
       await _firestore.collection('chats').doc(chatId).set({
        'chatId': chatId,
        'participants': [userAddress1, userAddress2],
        'isPrivate': isPrivate,
        'isGroup': false,
        'createdBy': userAddress1,
        'lastMessage': '',
        'lastMessageType': 'text',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'hiddenBy': [], // Init empty
      });
      
      // Optimistic local creation
       await _db.into(_db.localChats).insertOnConflictUpdate(
        LocalChatsCompanion(
          id: Value(chatId),
          participants: Value('$userAddress1,$userAddress2'),
          isPrivate: Value(isPrivate),
          lastMessage: const Value(''),
          lastMessageTime: Value(DateTime.now()),
        )
      );
    } else {
      // Chat exists.
      // 1. Unhide if needed (Auto-revive)
      await _firestore.collection('chats').doc(chatId).update({
          'hiddenBy': FieldValue.arrayRemove([userAddress1]) 
      });

      // 2. Ensure local DB has it
       final data = chatDoc.data()!;
       await _db.into(_db.localChats).insertOnConflictUpdate(
        LocalChatsCompanion(
          id: Value(chatId),
          participants: Value((data['participants'] as List).join(',')),
          isPrivate: Value(data['isPrivate'] ?? false),
          lastMessage: Value(data['lastMessage'] ?? ''),
          lastMessageTime: Value((data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now()),
        )
      );
    }
    return chatId;
  }

  Future<String> createGroup({
    required String name,
    required List<String> participants,
    String? groupImage,
    String? paymentSignature,
    String? paymentToken,
  }) async {
    final chatId = _uuid.v4();
    final creatorAddress = _ref.read(userProvider);
    
    if (creatorAddress == null) throw Exception('User not authenticated');

    // Roles: Creator is admin, others are members
    final Map<String, String> roles = {
      for (var p in participants) p: (p == creatorAddress ? 'admin' : 'member'),
    };

    final groupData = {
      'chatId': chatId,
      'name': name,
      'isGroup': true,
      'participants': participants,
      'roles': roles,
      'createdBy': creatorAddress,
      'groupImage': groupImage,
      'paymentSignature': paymentSignature,
      'paymentToken': paymentToken,
      'lastMessage': 'Group created',
      'lastMessageType': 'info',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'hiddenBy': [],
      'isLocked': false,
    };

    await _firestore.collection('chats').doc(chatId).set(groupData);

    // Optimistic local
    await _db.into(_db.localChats).insertOnConflictUpdate(
      LocalChatsCompanion(
        id: Value(chatId),
        participants: Value(participants.join(',')),
        isGroup: const Value(true),
        name: Value(name),
        groupImage: Value(groupImage),
        roles: Value(jsonEncode(roles)),
        createdBy: Value(creatorAddress),
        lastMessage: const Value('Group created'),
        lastMessageType: const Value('info'),
        lastMessageTime: Value(DateTime.now()),
        isLocked: const Value(false),
      )
    );

    return chatId;
  }

  Future<void> deleteChat(String chatId) async {
    // 0. Cancel active message subscription to stop background sync immediately
    await _messageSubscriptions[chatId]?.cancel();
    _messageSubscriptions.remove(chatId);

    // 0.5 Blacklist all currently known messages to absolutely prevent clock drift revivals
    final currentMsgs = await (_db.select(_db.localMessages)
          ..where((t) => t.chatId.equals(chatId)))
        .get();
    if (currentMsgs.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final deletedIds = prefs.getStringList('deleted_messages') ?? [];
      deletedIds.addAll(currentMsgs.map((m) => m.id));
      await prefs.setStringList('deleted_messages', deletedIds.toSet().toList());
    }
    
    // Fallback timestamp just in case
    final fallbackTimeMs = DateTime.now().millisecondsSinceEpoch;

    // 1. Delete locally
    await (_db.delete(_db.localChats)..where((t) => t.id.equals(chatId))).go();
    await (_db.delete(_db.localMessages)..where((t) => t.chatId.equals(chatId))).go();

    // 2. Mark "clearedAt" and "hiddenBy" for current user in Firestore
    try {
       final userAddress = _ref.read(userProvider);
       if (userAddress != null) {
         // Fix: Store locally FIRST to prevent fallback cache misses even if network update fails
         // Use the server-relative fallback time to avoid reviving old messages if local clock is behind
         final prefs = await SharedPreferences.getInstance();
         await prefs.setInt('clearedAt_$chatId', fallbackTimeMs);

         await _firestore.collection('chats').doc(chatId).update({
           'hiddenBy': FieldValue.arrayUnion([userAddress]),
           'clearedAt.$userAddress': FieldValue.serverTimestamp(), // Store deletion time
         });
       }
    } catch (e) {
      print('Error hiding/clearing chat in Firestore: $e');
      rethrow;
    }
  }

  // --- Group Admin Methods ---

  Future<void> leaveGroup(String chatId) async {
    final userAddress = _ref.read(userProvider);
    if (userAddress == null) return;

    try {
      final docId = _firestore.collection('chats').doc(chatId);
      final docSnap = await docId.get();
      if (!docSnap.exists) return;
      
      final data = docSnap.data()!;
      List<String> participants = List<String>.from(data['participants'] ?? []);
      Map<String, dynamic> roles = Map<String, dynamic>.from(data['roles'] ?? {});

      participants.remove(userAddress);
      roles.remove(userAddress);

      await docId.update({
        'participants': participants,
        'roles': roles,
      });

      // Remove local copy as we are no longer part of the group
      await (_db.delete(_db.localChats)..where((t) => t.id.equals(chatId))).go();
      await (_db.delete(_db.localMessages)..where((t) => t.chatId.equals(chatId))).go();
    } catch (e) {
      print('Error leaving group: $e');
    }
  }

  Future<void> removeUserFromGroup(String chatId, String targetUserAddress) async {
    try {
      final docId = _firestore.collection('chats').doc(chatId);
      final docSnap = await docId.get();
      if (!docSnap.exists) return;
      
      final data = docSnap.data()!;
      List<String> participants = List<String>.from(data['participants'] ?? []);
      Map<String, dynamic> roles = Map<String, dynamic>.from(data['roles'] ?? {});

      participants.remove(targetUserAddress);
      roles.remove(targetUserAddress);

      await docId.update({
        'participants': participants,
        'roles': roles,
      });

      // The target user's locally installed app should listen to `syncChats` 
      // where `arrayContains` will fail, or they receive Firebase notification
      // that they are removed. But for now, updating the array here is enough.
    } catch (e) {
      print('Error removing user from group: $e');
    }
  }

  Future<void> grantAdminRole(String chatId, String targetUserAddress) async {
    try {
      final docId = _firestore.collection('chats').doc(chatId);
      
      // Update the specific key in the roles map
      await docId.update({
        'roles.$targetUserAddress': 'admin',
      });
    } catch (e) {
      print('Error granting admin role: $e');
    }
  }

  Future<void> toggleGroupLock(String chatId, bool lock) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isLocked': lock,
      });
    } catch (e) {
      print('Error toggling group lock: $e');
    }
  }

  Future<void> addUserToGroup(String chatId, String newAddress) async {
    try {
      final docId = _firestore.collection('chats').doc(chatId);
      final docSnap = await docId.get();
      if (!docSnap.exists) return;
      
      final data = docSnap.data()!;
      List<String> participants = List<String>.from(data['participants'] ?? []);
      Map<String, dynamic> roles = Map<String, dynamic>.from(data['roles'] ?? {});

      if (!participants.contains(newAddress)) {
        participants.add(newAddress);
        roles[newAddress] = 'member';

        await docId.update({
          'participants': participants,
          'roles': roles,
        });
      }
    } catch (e) {
      print('Error adding user to group: $e');
    }
  }

  // --- Messages ---

  Stream<List<LocalMessage>> getMessages(String chatId) {
    return (_db.select(_db.localMessages)
          ..where((tbl) => tbl.chatId.equals(chatId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> syncMessages(String chatId) async {
    if (_messageSubscriptions.containsKey(chatId)) {
      // Already syncing this chat
      return;
    }

    // 1. Get clear point for user
    final userAddress = _ref.read(userProvider);
    Timestamp? clearedAt;
    
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      final clearedAtMap = chatDoc.data()?['clearedAt'] as Map<String, dynamic>?;
      clearedAt = clearedAtMap?[userAddress] as Timestamp?;
    } catch (e) {
      print('Error getting clear point for chat $chatId: $e');
    }

    // 1.b Resolve local pending cache issues for clearedAt
    final prefs = await SharedPreferences.getInstance();
    final localClearedAtMs = prefs.getInt('clearedAt_$chatId');

    DateTime? effectiveClearedAt;
    if (clearedAt != null) {
      effectiveClearedAt = clearedAt.toDate();
    }
    if (localClearedAtMs != null) {
      final localDate = DateTime.fromMillisecondsSinceEpoch(localClearedAtMs);
      if (effectiveClearedAt == null || localDate.isAfter(effectiveClearedAt)) {
        effectiveClearedAt = localDate;
      }
    }

    // 2. Listen to messages for this chat after clearedAt
    var query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp');
    
    if (effectiveClearedAt != null) {
      query = query.where('timestamp', isGreaterThan: Timestamp.fromDate(effectiveClearedAt));
    }

    final sub = query.snapshots().listen((snapshot) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final deletedIds = prefs.getStringList('deleted_messages') ?? [];

        for (var doc in snapshot.docs) {
          if (deletedIds.contains(doc.id)) continue;

          final data = doc.data() as Map<String, dynamic>;
          final exists = await (_db.select(_db.localMessages)..where((t) => t.id.equals(doc.id))).getSingleOrNull();
          if (exists != null) continue;

          String? localPath;
          if (data['type'] == 'image' && data['imageTempUrl'] != null) {
            try {
              final url = data['imageTempUrl'] as String;
              final storageService = _ref.read(storageServiceProvider);
              final fileName = 'IMG_${doc.id}.jpg';
              localPath = await storageService.downloadAndSaveImage(url, fileName);
              
              final downloadedBy = List<String>.from(data['downloadedBy'] ?? []);
              final myId = _ref.read(userProvider);
              if (myId != null && !downloadedBy.contains(myId)) {
                 downloadedBy.add(myId);
                 await doc.reference.update({'downloadedBy': downloadedBy});
                 if (downloadedBy.length >= 2) {
                   await storageService.deleteFromStorage(url);
                   await doc.reference.update({'imageTempUrl': 'DELETED'});
                 }
              }
            } catch (e) {
              print('Error downloading image for msg ${doc.id}: $e');
            }
          }

          await _db.into(_db.localMessages).insertOnConflictUpdate(
                LocalMessagesCompanion(
                  id: Value(doc.id),
                  chatId: Value(chatId),
                  senderId: Value(data['senderId']),
                  type: Value(data['type'] ?? 'text'),
                  textContent: Value(data['text']),
                  imageTempUrl: Value(data['imageTempUrl']), 
                  localImagePath: Value(localPath),
                  paymentAmount: Value((data['paymentAmount'] as num?)?.toDouble()),
                  paymentToken: Value(data['paymentToken'] ?? 'SOL'),
                  paymentSignature: Value(data['paymentSignature']),
                  timestamp: Value((data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now()),
                  delivered: const Value(true),
                ),
              );
        }
      } catch (e) {
        print('Error processing messages snapshot: $e');
      }
    }, onError: (e) {
      print('Error listening to messages for chat $chatId: $e');
      _messageSubscriptions.remove(chatId);
      if (e.toString().contains('UNAVAILABLE') || e.toString().contains('UnknownHostException')) {
        print('ChatRepository: Transient error detected, retrying sync in 3 seconds...');
        Future.delayed(const Duration(seconds: 3), () => syncMessages(chatId));
      }
    });

    _messageSubscriptions[chatId] = sub;
  }

  Future<void> sendMessage(String chatId, String senderId, {
    String? text,
    String? type = 'text',
    File? imageFile,
    double? paymentAmount,
    String? paymentToken,
    String? paymentSignature,
  }) async {
    final messageId = _uuid.v4();
    final now = DateTime.now();

    // 1. Optimistic Local Save
    final initialMessage = LocalMessagesCompanion(
      id: Value(messageId),
      chatId: Value(chatId),
      senderId: Value(senderId),
      type: Value(type!),
      textContent: Value(text),
      localImagePath: Value(imageFile?.path), // Use original path immediately so it shows up
      paymentAmount: Value(paymentAmount),
      paymentToken: Value(paymentToken ?? 'SOL'),
      paymentSignature: Value(paymentSignature),
      timestamp: Value(now),
      delivered: const Value(false),
    );

    print('ChatRepository: Saving message $messageId optimistically');
    await _db.into(_db.localMessages).insert(initialMessage);

    // Update Chat's last message locally
    await (_db.update(_db.localChats)..where((t) => t.id.equals(chatId))).write(
      LocalChatsCompanion(
        lastMessage: Value(text ?? (type == 'image' ? '📷 Image' : type)),
        lastMessageType: Value(type),
        lastMessageTime: Value(now),
      ),
    );

    // 2. Background Task (Non-awaited for images to be "instant" in UI)
    _processMessageBackground(
      chatId: chatId,
      messageId: messageId,
      senderId: senderId,
      type: type,
      text: text,
      imageFile: imageFile,
      paymentAmount: paymentAmount,
      paymentToken: paymentToken,
      paymentSignature: paymentSignature,
    );
  }

  Future<void> _processMessageBackground({
    required String chatId,
    required String messageId,
    required String senderId,
    required String type,
    String? text,
    File? imageFile,
    double? paymentAmount,
    String? paymentToken,
    String? paymentSignature,
  }) async {
    String? localPath;
    String? tempUrl;

    try {
      // 1. Process Image
      if (type == 'image' && imageFile != null) {
        print('ChatRepository: Background processing for image $messageId');
        final storageService = _ref.read(storageServiceProvider);
        
        final compressedFile = await storageService.compressAndSaveImage(imageFile);
        if (compressedFile != null) {
          localPath = compressedFile.path;
          tempUrl = await storageService.uploadImage(compressedFile, chatId);
          
          // Update local DB with compressed path and URL
          await (_db.update(_db.localMessages)..where((t) => t.id.equals(messageId))).write(
            LocalMessagesCompanion(
              localImagePath: Value(localPath),
              imageTempUrl: Value(tempUrl),
            ),
          );
        } else {
          print('ChatRepository: Image compression failed for $messageId');
        }
      }

      // 2. Sync to Firestore
      print('ChatRepository: Syncing message $messageId to Firestore');

      // BLOCK CHECK: Verify recipient hasn't blocked the sender
      try {
        final chatDoc = await _firestore.collection('chats').doc(chatId).get();
        final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
        final recipientId = participants.firstWhere((id) => id != senderId, orElse: () => '');
        
        if (recipientId.isNotEmpty) {
          final recipientDoc = await _firestore.collection('users').doc(recipientId).get();
          final recipientData = recipientDoc.data();
          if (recipientData != null) {
            final blockedByRecipient = List<String>.from(recipientData['blockedUsers'] ?? []);
            if (blockedByRecipient.contains(senderId)) {
              print('ChatRepository: Aborting send. Recipient $recipientId has blocked sender $senderId');
              // Optionally mark message as "failed" locally or just stop.
              return; 
            }
          }
        }
      } catch (e) {
        print('ChatRepository: Block check error: $e');
      }

      await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).set({
        'messageId': messageId,
        'senderId': senderId,
        'type': type,
        'text': text,
        'imageTempUrl': tempUrl,
        'paymentAmount': paymentAmount,
        'paymentToken': paymentToken ?? 'SOL',
        'paymentSignature': paymentSignature,
        'timestamp': FieldValue.serverTimestamp(),
        'delivered': true,
        'read': false,
        'downloadedBy': [senderId],
      });

      // Update Chat's last message remotely
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text ?? (type == 'image' ? '📷 Image' : type),
        'lastMessageType': type,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'hiddenBy': [], 
      });

      // 3. Mark as delivered locally
      await (_db.update(_db.localMessages)..where((t) => t.id.equals(messageId))).write(
        const LocalMessagesCompanion(delivered: Value(true)),
      );

      // 4. Send Push Notification
      _sendNotification(chatId, senderId, text, type);
      
      print('ChatRepository: Sync successful for $messageId');
    } catch (e) {
      print('ChatRepository: Background processing error for $messageId: $e');
    }
  }
  Future<void> clearChatHistory(String chatId) async {
    // 0. Cancel any active subscription for this chat
    // This is CRITICAL because the old listener might re-insert deleted messages
    await _messageSubscriptions[chatId]?.cancel();
    _messageSubscriptions.remove(chatId);

    // 0.5 Blacklist all currently known messages to absolutely prevent clock drift revivals
    final currentMsgs = await (_db.select(_db.localMessages)
          ..where((t) => t.chatId.equals(chatId)))
        .get();
    if (currentMsgs.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final deletedIds = prefs.getStringList('deleted_messages') ?? [];
      deletedIds.addAll(currentMsgs.map((m) => m.id));
      await prefs.setStringList('deleted_messages', deletedIds.toSet().toList());
    }

    // Fallback timestamp just in case
    final fallbackTimeMs = DateTime.now().millisecondsSinceEpoch;

    // 1. Delete all messages for this chat locally
    await (_db.delete(_db.localMessages)..where((t) => t.chatId.equals(chatId))).go();

    // 2. Insert a 'system' message to mark the clear point locally
    final now = DateTime.now();
    await _db.into(_db.localMessages).insert(
      LocalMessagesCompanion(
        id: Value(_uuid.v4()),
        chatId: Value(chatId),
        senderId: const Value('system'),
        type: const Value('info'),
        textContent: const Value('Chat cleared'),
        timestamp: Value(now),
        delivered: const Value(true),
        read: const Value(true),
      ),
    );

    // 3. Update chat last message text and clearedAt remotely
    try {
       final userAddress = _ref.read(userProvider);
       if (userAddress != null) {
         // Fix: Store locally FIRST to prevent fallback cache misses even if network update fails
         // Use the server-relative fallback time to avoid reviving old messages if local clock is behind
         final prefs = await SharedPreferences.getInstance();
         await prefs.setInt('clearedAt_$chatId', fallbackTimeMs);

         await _firestore.collection('chats').doc(chatId).update({
           'lastMessage': 'Chat cleared',
           'lastMessageType': 'info',
           'lastMessageTime': FieldValue.serverTimestamp(),
           'clearedAt.$userAddress': FieldValue.serverTimestamp(),
         });
       }
    } catch (e) {
      print('Error syncing clearChatHistory to Firestore: $e');
    }

    // 4. Update chat last message text to "Chat cleared" to reflect state in list locally
    await (_db.update(_db.localChats)..where((t) => t.id.equals(chatId))).write(
      LocalChatsCompanion(
        lastMessage: const Value('Chat cleared'),
        lastMessageType: const Value('info'),
        lastMessageTime: Value(now),
      ),
    );

    // 5. Restart sync with the NEW clearedAt timestamp
    // ignore: unawaited_futures
    syncMessages(chatId);
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    // 1. Delete from Local DB (Optimistic)
    await (_db.delete(_db.localMessages)..where((t) => t.id.equals(messageId))).go();

    // 2. Persist faulty suppression (Soft Delete)
    // Even if server delete fails, we will remember to IGNORE this message ID in sync.
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = prefs.getStringList('deleted_messages') ?? [];
    if (!deletedIds.contains(messageId)) {
      deletedIds.add(messageId);
      await prefs.setStringList('deleted_messages', deletedIds);
    }

    // 3. Delete from Firestore
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .delete();
      }
    } catch (e) {
      print('Firestore delete failed: $e');
      // Rethrow to let UI know, but local is already gone so user sees it "deleted"
      rethrow;
    }
  }

  Future<void> updateReadStatus(String chatId) async {
    final userAddress = _ref.read(userProvider);
    if (userAddress == null) return;

    try {
      // 1. Mark persistent Firestore status
      await _firestore.collection('chats').doc(chatId).set({
        'readStatus': {
          userAddress: FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      // 2. Mark local Drift messages as read
      await (_db.update(_db.localMessages)
            ..where((t) => t.chatId.equals(chatId))
            ..where((t) => t.read.equals(false)))
          .write(const LocalMessagesCompanion(read: Value(true)));
      
      print('ChatRepository: Read status updated for $userAddress in chat $chatId');
    } catch (e) {
      print('ChatRepository: Error updating read status: $e');
    }
  }

  Stream<bool> watchUnreadStatus(String chatId) {
    final userAddress = _ref.read(userProvider);
    if (userAddress == null) return Stream.value(false);

    // Watch messages in this chat where sender is NOT me AND read is false
    final query = _db.select(_db.localMessages)
      ..where((t) => t.chatId.equals(chatId))
      ..where((t) => t.senderId.equals(userAddress).not())
      ..where((t) => t.read.equals(false));
    
    return query.watch().map((messages) => messages.isNotEmpty);
  }

  Future<void> _sendNotification(String chatId, String senderId, String? text, String? type) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      final recipientId = participants.firstWhere((id) => id != senderId, orElse: () => '');

      if (recipientId.isNotEmpty) {
        final recipientDoc = await _firestore.collection('users').doc(recipientId).get();
        final recipientToken = recipientDoc.data()?['fcmToken'];

        if (recipientToken != null) {
          // Get sender nickname for better notification
          final senderDoc = await _firestore.collection('users').doc(senderId).get();
          final senderName = senderDoc.data()?['nickname'] ?? 'Someone';

          await _notificationService.sendPushNotification(
            recipientToken: recipientToken,
            title: senderName,
            body: type == 'image' ? '📷 Photo' : (text ?? 'New message'),
            data: {
              'chatId': chatId,
              'type': 'message',
              'senderId': senderId,
            },
          );
        }
      }
    } catch (e) {
      print('Notification Error: $e');
    }
  }
}
