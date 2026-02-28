import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solchat/main.dart' show navigatorKey;
import 'package:solchat/features/chat/screens/chat_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solchat/features/chat/data/chat_repository.dart';

// Background handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final _messageController = StreamController<String>.broadcast();
  Stream<String> get onChatIdReceived => _messageController.stream;

  bool _isNavigating = false; // Guard for navigation crashes

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Track active chat to suppress notifications
  String? _activeChatId;
  void setActiveChatId(String? id) {
    print('NotificationService: Setting activeChatId to $id');
    _activeChatId = id;
    if (id != null) {
      clearNotifications(id);
    } else {
      // If we are clearing, we want local notifications to work INSTANTLY
      // even before Firestore is updated.
      print('NotificationService: Suppression disabled locally.');
    }
  }

  Future<void> _vibrateAndPlaySound() async {
    try {
      // 1. Vibrate
      await HapticFeedback.mediumImpact();
      
      // 2. Play Sound
      final prefs = await SharedPreferences.getInstance();
      final customPath = prefs.getString('customSoundPath');
      
      if (customPath != null && customPath.isNotEmpty) {
        // Play selected sound from file
        await _audioPlayer.play(DeviceFileSource(customPath));
      } else {
        // Standard sound - since we don't have assets, we use SystemSound
        // Note: For more complex standard sounds, we would add an asset
        await SystemSound.play(SystemSoundType.click);
        // Small delay if we wanted to play a second click to make it more noticeable
        await Future.delayed(const Duration(milliseconds: 100));
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      print('NotificationService: Error playing alert: $e');
    }
  }

  Future<void> initialize() async {
    // 1. Setup Local Notifications (for foreground display)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('NotificationService: Local notification tapped! Payload: ${response.payload}');
        if (response.payload != null) {
          try {
            _handleNotificationClick(jsonDecode(response.payload!));
          } catch (e) {
            print('NotificationService: Error parsing payload: $e');
          }
        }
      },
    );

    // 2. Define Notification Channel (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(channel);

    // 3. Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('NotificationService: Got a message in the foreground!');
      
      final incomingChatId = message.data['chatId'];
      print('NotificationService: Incoming chatId from FCM: $incomingChatId');
      print('NotificationService: Current activeChatId in service: $_activeChatId');
      
      if (incomingChatId != null && incomingChatId.toString() == _activeChatId?.toString()) {
        print('NotificationService: Skipping notification: user is already in this chat (MATCH).');
        _vibrateAndPlaySound();
        return;
      }
      
      // Dispatch to listeners (like ChatRepository) to force sync
      if (incomingChatId != null) {
        _messageController.add(incomingChatId);
      }

      if (message.notification != null) {
        _showLocalNotification(message, channel);
      }
    });

    // 4. Handle clicks when app is in background (but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('NotificationService: Notification tapped from background state!');
      _handleNotificationClick(message.data);
    });

    // 5. Handle click when app is launched from terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('NotificationService: App launched from terminated state via notification!');
        _handleNotificationClick(message.data);
      }
    });

    // 6. Handle click on local notification (foreground-shown)
    final NotificationAppLaunchDetails? details = await _localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      final payload = details.notificationResponse?.payload;
      if (payload != null) {
        _handleNotificationClick(jsonDecode(payload));
      }
    }

    // 7. Background Message Handler (Static task)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 8. Get Token (Silent)
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');
  }

  void _handleNotificationClick(Map<String, dynamic> data) async {
    final String? chatId = data['chatId']?.toString();
    final String? senderId = data['senderId']?.toString();
    final bool isGroup = data['isGroup']?.toString() == 'true';

    print('NotificationService: CLICK DETECTED for $chatId');
    
    if (chatId == null || _isNavigating) return;
    _isNavigating = true;

    // Clear notifications for this chat immediately in tray
    clearNotifications(chatId);

    // PRE-FETCH: Start syncing messages immediately so they are ready when the screen loads
    try {
      final container = ProviderScope.containerOf(navigatorKey.currentContext!);
      container.read(chatRepositoryProvider).syncMessages(chatId);
    } catch (e) {
      print('NotificationService: Could not pre-fetch messages: $e');
    }

    // Standard wait for navigator to initialize in cold starts
    if (navigatorKey.currentState == null) {
      print('NotificationService: Waiting for navigator state...');
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (navigatorKey.currentState != null) {
      print('NotificationService: NAVIGATING TO ChatScreen for $chatId');
      
      // OPTIMIZATION: If we are already in the SAME chat, we don't need to push again
      if (_activeChatId == chatId) {
        print('NotificationService: Already in the target chat. No navigation needed.');
        return;
      }

      try {
        // We use pushAndRemoveUntil to clear previous chat screens but keep the home screen
        // This solves the "multiple bubbles" issue when backing out.
        await navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              otherUserAddress: senderId, 
              isGroup: isGroup,
            ),
          ),
          (route) => route.isFirst, // Keep only the base route (Home/ChatList)
        );
      } finally {
        _isNavigating = false;
      }
    } else {
      print('NotificationService: CRITICAL - Navigator state is null after check.');
      _isNavigating = false;
    }
  }

  Future<bool> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> _showLocalNotification(RemoteMessage message, AndroidNotificationChannel channel) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    final String? chatId = message.data['chatId'];

    if (notification != null && android != null) {
      // Use a consistent ID per chat? NO, use message ID to allow MULTIPLE notifications
      // But we use tag/groupKey for Android to bundle them.
      // We'll use a hash of messageId if available, otherwise chatId
      final String? messageId = message.messageId;
      final int id = messageId != null ? messageId.hashCode.abs() : chatId.hashCode.abs();

      // Pack data into payload for navigation
      final String payload = jsonEncode({
        'chatId': chatId,
        'senderId': message.data['senderId'],
        'isGroup': message.data['isGroup'],
        'type': message.data['type'],
      });

      final List<ActiveNotification> activeNotifications = await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.getActiveNotifications() ?? [];

      // Grouping logic:
      // We want to group by chatId.
      // If we have more than 3 notifications in total, we show a summary.
      
      const String groupKey = 'com.solchat.MESSAGES';
      
      await _localNotifications.show(
        id,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'ic_notification',
            priority: Priority.high,
            importance: Importance.max,
            groupKey: groupKey, 
            setAsGroupSummary: false, 
          ),
          iOS: DarwinNotificationDetails(
            threadIdentifier: chatId,
          ),
        ),
        payload: payload,
      );

      // Show summary if there are multiple notifications
      if (activeNotifications.length >= 2) {
        await _localNotifications.show(
          0, // Summary ID
          'SolChatPlus',
          activeNotifications.length >= 3 
              ? 'Tienes ${activeNotifications.length + 1} mensajes nuevos'
              : 'Nuevos mensajes',
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'ic_notification',
              priority: Priority.high,
              importance: Importance.max,
              groupKey: groupKey,
              setAsGroupSummary: true,
              groupAlertBehavior: GroupAlertBehavior.children,
            ),
          ),
        );
      }
    }
  }

  // --- SENDING LOGIC (V1 API) ---
  // [SECURITY WARNING] This method was disabled because it uses a Service Account Key
  // which is insecure to bundle in a mobile application.
  // Pushes should be sent from a secure backend or Cloud Function.
  Future<void> sendPushNotification({
    required String recipientToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    print('NotificationService: Push sending from client is DISABLED for security.');
    print('Please implement this logic in a Firebase Cloud Function.');
  }

  void clearNotifications(String chatId) {
    // Generate the SAME consistent ID based on the chatId
    final int id = chatId.hashCode.abs();
    print('NotificationService: Explicitly clearing notification $id for chat $chatId');
    _localNotifications.cancel(id);
  }
}
