import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/auth/login_screen.dart';
import 'package:solchat/features/chat/screens/chat_list_screen.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'package:solchat/features/profile/onboarding_screen.dart';
import 'package:solchat/services/notification_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solchat/features/call/call_service.dart';
import 'package:solchat/features/chat/data/chat_repository.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  String? _lastUser;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    
    // Proactive Notification Request: Trigger as soon as user is authenticated
    if (user != null && user != _lastUser) {
      _lastUser = user;
      _initAppServices(user);
    }

    if (user != null) {
      // Use the stream to reactively monitor nickname status
      final userStream = ref.watch(userServiceProvider).getUserStream(user);
      
      return StreamBuilder(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          final userData = snapshot.data;
          final hasNickname = userData?.nickname != null && userData!.nickname!.isNotEmpty;
          
          if (!hasNickname) {
            return const OnboardingScreen();
          }
          
          return const ChatListScreen();
        },
      );
    } else {
      return const LoginScreen();
    }
  }

  Future<void> _initAppServices(String userAddress) async {
    try {
      // Small delay to let the app settle
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;

      // 1. Initialize Notification Service
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();
      
      if (!mounted) return;
      await notificationService.requestPermission();
      
      // 2. Sync Security Info (FCM Token)
      if (!mounted) return;
      final token = notificationService.fcmToken;
      if (token != null) {
        await ref.read(userServiceProvider).syncSecurityInfo(userAddress, token: token);
      }

      if (!mounted) return;

      // 3. Initialize Call Service
      final userDoc = await ref.read(userServiceProvider).getUser(userAddress);
      if (!mounted) return;
      
      final nickname = userDoc?.nickname ?? 'User';
      
      // Initialize Zego
      await ref.read(callServiceProvider).initService(userAddress, nickname);
      
      if (!mounted) return;
      
      // 4. Sync Chats
      ref.read(chatRepositoryProvider).syncChats(userAddress);

      debugPrint('AuthWrapper: All services initialized successfully for $userAddress');
    } catch (e) {
      if (mounted) {
        debugPrint('AuthWrapper: Error initializing app services: $e');
      }
    }
  }
}
