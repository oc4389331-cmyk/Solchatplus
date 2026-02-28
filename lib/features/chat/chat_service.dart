import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/models/message_model.dart';

// Wrapper to handle both Firestore Snapshots and Mock Data
class ChatEntity {
  final String id;
  final Map<String, dynamic> _data;

  ChatEntity({required this.id, required Map<String, dynamic> data}) : _data = data;

  Map<String, dynamic> data() => _data;

  factory ChatEntity.fromSnapshot(DocumentSnapshot doc) {
    return ChatEntity(id: doc.id, data: doc.data() as Map<String, dynamic>);
  }
}

final chatServiceProvider = Provider((ref) => ChatService());

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getMessages(chatId);
});

final userChatsProvider = StreamProvider.family<List<ChatEntity>, String>((ref, userAddress) {
  if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) {
    // Mock Data for Web/Desktop UI Testing
    return Stream.value([
      ChatEntity(
        id: 'mock_chat_1',
        data: {
          'participants': [userAddress, 'MockWalletRecipient'],
          'lastMessage': 'Welcome to SolChat Web!',
          'lastMessageTime': DateTime.now(),
        },
      ),
       ChatEntity(
        id: 'mock_chat_2',
        data: {
          'participants': [userAddress, 'SatoshiNakamoto'],
          'lastMessage': 'Bitcoin to the moon? 🚀',
          'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)),
        },
      ),
    ]);
  }

  // Real Firestore Data
  return FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: userAddress)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => ChatEntity.fromSnapshot(doc)).toList());
});

class ChatService {
  // Use a getter to access instance to avoid issues if initialized before Firebase.initializeApp
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<List<MessageModel>> getMessages(String chatId) {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) {
      // Mock Messages for Web
      return Stream.value([
        MessageModel(
          id: 'msg_1',
          senderAddress: 'MockWalletRecipient',
          text: 'Hello! This is a mock message on Web.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        MessageModel(
          id: 'msg_2',
          senderAddress: 'MockWalletRecipient',
          text: 'You can test the UI here without Android emulator.',
          timestamp: DateTime.now(),
        ),
      ]);
    }

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) {
      print('[Mock] Sending message: ${message.text}');
      return;
    }

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }
  
  // Create or get a chat between two users
  Future<String> createChat(String userAddress1, String userAddress2) async {
     if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) {
       return 'mock_new_chat_${DateTime.now().millisecondsSinceEpoch}';
     }

     // Logic to find existing chat or create new one
     // For simplicity, we can use a composite ID or query
     final chatId = userAddress1.compareTo(userAddress2) < 0 
         ? '${userAddress1}_$userAddress2' 
         : '${userAddress2}_$userAddress1';
         
     final chatDoc = _firestore.collection('chats').doc(chatId);
     
     // Check if exists, if not create basic info
     final snapshot = await chatDoc.get();
     if (!snapshot.exists) {
       await chatDoc.set({
         'participants': [userAddress1, userAddress2],
         'lastMessage': '',
         'lastMessageTime': FieldValue.serverTimestamp(),
       });
     }
     
     return chatId;
  }
}
