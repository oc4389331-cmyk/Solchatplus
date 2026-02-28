import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyQRCodeScreen extends ConsumerWidget {
  const MyQRCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAddress = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29), // Match theme
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myQRCode, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: userAddress == null
            ? Text(AppLocalizations.of(context)!.walletNotConnected, style: const TextStyle(color: Colors.white))
            : Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF14F195).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: QrImageView(
                        data: userAddress,
                        version: QrVersions.auto,
                        size: 250.0,
                        backgroundColor: Colors.white,
                        // Embedded Image (Optional - causing issues without proper asset)
                        // embeddedImage: const AssetImage('assets/icon.png'),
                        // embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context)!.scanToStartChat,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      userAddress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: userAddress));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.copyAddressClipboard)),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: Text(AppLocalizations.of(context)!.copyAddress),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24243E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
