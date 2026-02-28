import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/models/user_model.dart';
import 'package:flutter/foundation.dart';

final userServiceProvider = Provider((ref) => UserService());

final userInfoProvider = FutureProvider.family<UserModel?, String>((ref, address) {
  return ref.watch(userServiceProvider).getUser(address);
});

final userProfileProvider = StreamProvider.family<UserModel?, String>((ref, address) {
  return ref.watch(userServiceProvider).getUserStream(address);
});

class UserService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<UserModel?> getUser(String address) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) {
      // Mock data for web/desktop
      return UserModel(address: address, nickname: 'Mock User');
    }

    try {
      final doc = await _firestore.collection('users').doc(address).get().timeout(const Duration(seconds: 10));
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<bool> isNicknameAvailable(String nickname, String currentAddress) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) return true;

    final query = nickname.trim().toLowerCase();
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('nickname_lowercase', isEqualTo: query)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      if (querySnapshot.docs.isEmpty) {
        return true;
      }

      // If it exists, check if it's the current user themselves
      final existingUserAddress = querySnapshot.docs.first.id;
      return existingUserAddress == currentAddress;
    } catch (e) {
      print('Error checking nickname availability: $e');
      return true; // Fallback to true on error to not block user
    }
  }

  Future<void> updateNickname(String address, String nickname) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) return;

    await _firestore.collection('users').doc(address).set({
      'address': address,
      'nickname': nickname,
      'nickname_lowercase': nickname.trim().toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));
  }

  Future<void> ensureUserExists(String address) async {
     if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) return;

     final docRef = _firestore.collection('users').doc(address);
     final doc = await docRef.get().timeout(const Duration(seconds: 10));
     
     if (!doc.exists) {
       await docRef.set({
         'address': address,
         'createdAt': FieldValue.serverTimestamp(),
       }).timeout(const Duration(seconds: 10));
     }
  }
  Future<void> updateOnlineStatus(String address, bool isOnline, {String? activeChatId}) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) return;

    final data = <String, dynamic>{
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    };
    
    // Explicitly set activeChatId (can be null to clear it)
    data['activeChatId'] = activeChatId;

    try {
      print('UserService: Updating online status for $address. isOnline: $isOnline, activeChatId: $activeChatId');
      await _firestore.collection('users').doc(address).set(data, SetOptions(merge: true)).timeout(const Duration(seconds: 10));
      print('UserService: Online status updated successfully.');
    } catch (e) {
      print('UserService: Error updating online status: $e');
    }
  }

  Stream<UserModel?> getUserStream(String address) {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) {
       return Stream.value(UserModel(address: address, nickname: 'Mock User', isOnline: true));
    }
    return _firestore.collection('users').doc(address).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  Future<void> updateProfileImage(String address, String imageUrl) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) return;

    await _firestore.collection('users').doc(address).set({
      'avatarUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));
  }
  Future<void> syncSecurityInfo(String address, {String? token, String? firebaseUid}) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) return;

    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (token != null) data['fcmToken'] = token;
    if (firebaseUid != null) data['firebaseUid'] = firebaseUid;

    await _firestore.collection('users').doc(address).set(data, SetOptions(merge: true)).timeout(const Duration(seconds: 10));
  }
  Future<List<UserModel>> searchUsers(String query) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) {
       // Mock search
       await Future.delayed(const Duration(milliseconds: 500));
       if ('mock user'.contains(query.toLowerCase())) {
         return [UserModel(address: 'mock_address_123', nickname: 'Mock User', avatarUrl: null)];
       }
       return [];
    }

    try {
      query = query.trim(); // Remove leading/trailing spaces
      final results = <UserModel>[];
      final lowerQuery = query.toLowerCase();
      // Note: Firestore text search is limited. 
      // We are searching by 'nickname' field which is case sensitive.
      // If the user types 'oscar' and the db has 'Oscar', it won't match with standard queries unless we rely on exact match or have a normalized field.
      
      // Strategy 1: Search by lowercase nickname (Exact/Prefix)
      final queryAsIs = await _firestore
          .collection('users')
          .where('nickname_lowercase', isGreaterThanOrEqualTo: lowerQuery)
          .where('nickname_lowercase', isLessThan: '$lowerQuery\uf8ff')
          .limit(20)
          .get()
          .timeout(const Duration(seconds: 10));

      for (var doc in queryAsIs.docs) {
        results.add(UserModel.fromMap(doc.data()));
      }
      
      // Strategy 2: Capitalized
      if (query.isNotEmpty && query == query.toLowerCase()) {
         String capitalized = query[0].toUpperCase() + query.substring(1);
         print('Searching capitalized: $capitalized');
         final queryCap = await _firestore
            .collection('users')
            .where('nickname', isGreaterThanOrEqualTo: capitalized)
            .where('nickname', isLessThan: '$capitalized\uf8ff')
            .limit(10)
            .get();
            
         for (var doc in queryCap.docs) {
           if (!results.any((u) => u.address == doc.data()['address'])) {
              results.add(UserModel.fromMap(doc.data()));
           }
         }
      }

      // Strategy 3: UPPERCASE (e.g. searching "chupi" finds "CHUPITO")
      if (query.isNotEmpty) {
         String upper = query.toUpperCase();
         print('Searching uppercase: $upper');
         final queryUpper = await _firestore
            .collection('users')
            .where('nickname', isGreaterThanOrEqualTo: upper)
            .where('nickname', isLessThan: '$upper\uf8ff')
            .limit(10)
            .get();
            
         for (var doc in queryUpper.docs) {
           if (!results.any((u) => u.address == doc.data()['address'])) {
              results.add(UserModel.fromMap(doc.data()));
           }
         }
      }

      // 4. Search by Address (Prefix/Partial)
      if (query.length >= 3) { // Lower limit to allow partial address search
         print('Searching address prefix: $query');
         final addressQuery = await _firestore
           .collection('users')
           .where('address', isGreaterThanOrEqualTo: query)
           .where('address', isLessThan: '$query\uf8ff')
           .limit(10)
           .get();
         
         for (var doc in addressQuery.docs) {
           if (!results.any((u) => u.address == doc.data()['address'])) {
              results.add(UserModel.fromMap(doc.data()));
           }
         }
      }

      print('Found ${results.length} users for query: $query');
      print('Found ${results.length} users with specific queries');

      // 5. Fallback: Client-side filtering (Robustness for partial matches/case issues during dev)
      if (results.isEmpty) {
         print('Attempting fallback client-side search...');
         // Use createdAt as it's set on creation. orderBy updatedAt might exclude users who never updated.
         final allRecentUsers = await _firestore
             .collection('users')
             .orderBy('createdAt', descending: true)
             .limit(100) // Increase limit to catch more users
             .get();
             
         print('Fallback pulled ${allRecentUsers.docs.length} users.');
         
         for (var doc in allRecentUsers.docs) {
            final user = UserModel.fromMap(doc.data());
            // Debug print to see what's being checked
            // print('Checking fallback user: ${user.address} (${user.nickname})');

            // Check nickname match (contains, case-insensitive)
            if (user.nickname != null && user.nickname!.toLowerCase().contains(lowerQuery)) {
               if (!results.any((u) => u.address == user.address)) {
                  results.add(user);
               }
            }
            // Check address match - Case Insensitive Check!
            if (user.address.toLowerCase().contains(lowerQuery)) {
               if (!results.any((u) => u.address == user.address)) {
                  results.add(user);
               }
            }
         }
      }

      print('Final results count: ${results.length}');
      return results;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<void> blockUser(String currentAddress, String targetAddress) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) return;

    await _firestore.collection('users').doc(currentAddress).update({
      'blockedUsers': FieldValue.arrayUnion([targetAddress]),
    });
  }

  Future<void> unblockUser(String currentAddress, String targetAddress) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) return;

    await _firestore.collection('users').doc(currentAddress).update({
      'blockedUsers': FieldValue.arrayRemove([targetAddress]),
    });
  }
  Future<void> markTutorialAsSeen(String userAddress) async {
    await _firestore.collection('users').doc(userAddress).update({
      'hasSeenTutorial': true,
    });
  }
}
