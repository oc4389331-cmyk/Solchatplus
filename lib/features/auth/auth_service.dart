import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';
import 'package:solana/solana.dart';
import 'package:solchat/features/auth/user_service.dart';
import 'dart:typed_data';
import 'package:solchat/services/notification_provider.dart';
import 'package:solchat/features/call/call_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authServiceProvider = Provider((ref) => AuthService());

final userProvider = StateProvider<String?>((ref) => null);

class AuthService {
  // Enhanced logging to debug ECONNREFUSED
  
  Future<void> signInWithSolana(WidgetRef ref) async {
    // Check for Web or non-Android platform to use mock auth for UI testing
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android)) {
      if (kDebugMode) {
        print('Running on Web/Desktop: Using Mock Authentication for UI Testing');
      }
      await Future.delayed(const Duration(seconds: 1));
      const mockAddress = 'MockWalletAddressForTestingUI123456789';
      ref.read(userProvider.notifier).state = mockAddress;
      return;
    }

    try {
      if (kDebugMode) print('Starting LocalAssociationScenario...');
      
      // Android flow with solana_mobile_client
      final scenario = await LocalAssociationScenario.create();
      
      // REQUIRED: Launch the wallet to start the association
      // ignore: unawaited_futures
      scenario.startActivityForResult(null);
      
      try {
        if (kDebugMode) print('LocalAssociationScenario created. Starting client...');
        
        final client = await scenario.start();
        if (kDebugMode) print('Client started. Authorizing...');

        // Use known-good URIs for testing to avoid metadata fetch failures
        final authResult = await client.authorize(
          identityUri: Uri.parse('https://solana.com'), 
          iconUri: Uri.parse('favicon.ico'),
          identityName: 'Solana',
          cluster: 'mainnet-beta',
        );

        if (kDebugMode) print('Authorization result: $authResult');

        final publicKey = authResult?.publicKey;
        if (publicKey == null) {
           if (kDebugMode) print('Authorization failed: No public key returned.');
           return;
        }

        // 2. Create a message to sign
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final message = 'Sign this message to authenticate with SolChat. Timestamp: $timestamp';
        final messageBytes = Uint8List.fromList(message.codeUnits);

        if (kDebugMode) print('Requesting signature...');

        // 3. Request Signature
        final signResult = await client.signMessages(
          messages: [messageBytes],
          addresses: [publicKey],
        );

        if (kDebugMode) print('Signature result received.');

        // 4. Verify Signature (Simulated/Client-side for now)
        if (signResult.signedMessages.isNotEmpty) {
           final signedMessage = signResult.signedMessages.first;
           // In a real app, verify signature here using the public key

           if (kDebugMode) {
             print('Message signed successfully');
           }

          // For MVP: Treat as authenticated
          // Convert Uint8List public key to Base58 string
          final address = Ed25519HDPublicKey(publicKey).toBase58();
          
          if (kDebugMode) print('Authenticating with Firebase...');
          try {
            // CRITICAL FIX: Sign in to Firebase BEFORE touching Firestore to avoid PERMISSION_DENIED
            final userCredential = await FirebaseAuth.instance.signInAnonymously();
            if (kDebugMode) {
              print('Signed in to Firebase Anonymously: ${userCredential.user?.uid}');
            }
          } catch (firebaseAuthError) {
            print('CRITICAL: Firebase Auth failed: $firebaseAuthError');
            // If Firebase Auth fails, we can't reliably use Firestore with current rules
          }

          // Ensure user document exists in Firestore (Now has permission)
          await ref.read(userServiceProvider).ensureUserExists(address);
          
          // Update State IMMEDIATELY to unblock UI
          ref.read(userProvider.notifier).state = address;

          // Initialize Notifications (Independent)
          try {
            final notificationService = ref.read(notificationServiceProvider);
            await notificationService.initialize();
            final token = notificationService.fcmToken;
            final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
            await ref.read(userServiceProvider).syncSecurityInfo(address, token: token, firebaseUid: firebaseUid);
          } catch (e) {
            print('Error initializing notifications: $e');
          }

          // Initialize Voice Calls (Independent)
          try {
            // Fetch nickname for better call UI
            final userDoc = await ref.read(userServiceProvider).getUser(address);
            final nickname = userDoc?.nickname ?? 'User';
            
            await ref.read(callServiceProvider).initService(address, nickname);
          } catch (e) {
            print('Error initializing calls: $e');
          }
        }
      } finally {
        if (kDebugMode) print('Closing scenario...');
        await scenario.close();
      }

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error signing in with Wallet: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<void> disconnect(WidgetRef ref) async {
    await ref.read(callServiceProvider).uninitService();
    ref.read(userProvider.notifier).state = null;
  }
}
