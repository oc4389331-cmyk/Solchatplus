import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:solchat/main.dart'; // Import navigatorKey

final callServiceProvider = Provider((ref) => CallService());

class CallService {
  Future<void> initService(String userID, String userName) async {
    final appID = int.tryParse(dotenv.env['ZEGO_APP_ID'] ?? '') ?? 0;
    final appSign = dotenv.env['ZEGO_APP_SIGN'] ?? '';

    if (appID == 0 || appSign.isEmpty) {
      debugPrint('ZEGO Cloud credentials missing in .env');
      return;
    }

    try {
      // Ensure we start with a clean state
      await ZegoUIKitPrebuiltCallInvitationService().uninit();

      // Zego ZIM Plugin has a 32-byte limit for UserID.
      // Solana addresses are 44 chars, so we truncate to 32.
      // ideally we should use a hash, but for now truncation works as addresses have high entropy.
      final String zegoUserId = (userID.length > 32) ? userID.substring(0, 32) : userID;

      // Debug credentials (masked)
      debugPrint('Initializing Zego with AppID: $appID, AppSign: ${appSign.substring(0, 5)}***, UserID: $zegoUserId');
      
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: appID,
        appSign: appSign,
        userID: zegoUserId,
        userName: userName.isEmpty ? 'User $userID' : userName,
        plugins: [ZegoUIKitSignalingPlugin()],
        config: ZegoCallInvitationConfig(
          permissions: [
            ZegoCallInvitationPermission.camera,
            ZegoCallInvitationPermission.microphone,
          ],
        ),
        notificationConfig: ZegoCallInvitationNotificationConfig(
          androidNotificationConfig: ZegoAndroidNotificationConfig(
            showFullScreen: false,
            channelID: "zego_video_call",
            channelName: "Video Call",
            sound: "zego_incoming",
          ),
        ),
        requireConfig: (ZegoCallInvitationData data) {
          final config = (data.invitees.length > 1)
              ? ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
          
          // Limit call to 2 minutes (120 seconds) to manage free minutes
          config.duration.isVisible = true;
          config.duration.onDurationUpdate = (Duration duration) {
            final context = navigatorKey.currentContext;
            if (context != null) {
              if (duration.inSeconds == 90) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La llamada terminará en 30 segundos.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              } else if (duration.inSeconds >= 120) {
                ZegoUIKitPrebuiltCallController().hangUp(context);
                debugPrint('Call duration limit reached (2 min). Hanging up.');
              }
            }
          };

          return config;
        },
      );
      
      
      debugPrint('ZegoCloud Service Initialized for $userName ($zegoUserId)');
      
    } catch (e) {
      debugPrint('Error initializing ZegoCloud: $e');
    }
  }

  Future<void> uninitService() async {
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
