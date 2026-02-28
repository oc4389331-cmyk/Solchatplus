import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderAddress;
  final String text;
  final DateTime timestamp;
  final String type; // 'text', 'image', 'payment'
  final double? paymentAmount;
  final String? paymentSignature;
  final String? imageUrl;
  final String? localImagePath;

  MessageModel({
    required this.id,
    required this.senderAddress,
    required this.text,
    required this.timestamp,
    this.type = 'text',
    this.paymentAmount,
    this.paymentSignature,
    this.imageUrl,
    this.localImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderAddress': senderAddress,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'paymentAmount': paymentAmount,
      'paymentSignature': paymentSignature,
      'imageUrl': imageUrl,
      // 'localImagePath' is typically local-only, not synced to Firestore directly unless as a temp field
    };
  }

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderAddress: map['senderAddress'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: map['type'] ?? 'text',
      paymentAmount: (map['paymentAmount'] as num?)?.toDouble(),
      paymentSignature: map['paymentSignature'],
      imageUrl: map['imageUrl'],
    );
  }
}
