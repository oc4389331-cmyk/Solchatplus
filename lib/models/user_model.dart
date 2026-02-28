import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String address;
  final String? nickname;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? fcmToken;
  final List<String> blockedUsers;
  final bool hasSeenTutorial;

  UserModel({
    required this.address,
    this.nickname,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
    this.fcmToken,
    this.blockedUsers = const [],
    this.hasSeenTutorial = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'fcmToken': fcmToken,
      'blockedUsers': blockedUsers,
      'hasSeenTutorial': hasSeenTutorial,
    };
  }

  UserModel copyWith({
    String? address,
    String? nickname,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
    String? fcmToken,
    List<String>? blockedUsers,
    bool? hasSeenTutorial,
  }) {
    return UserModel(
      address: address ?? this.address,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      fcmToken: fcmToken ?? this.fcmToken,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      address: map['address'] ?? '',
      nickname: map['nickname'],
      avatarUrl: map['avatarUrl'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
      fcmToken: map['fcmToken'],
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      hasSeenTutorial: map['hasSeenTutorial'] ?? false,
    );
  }
}
