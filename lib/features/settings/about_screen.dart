import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:solchat/config/constants.dart';
import 'package:solchat/features/auth/auth_service.dart';
import 'package:solchat/features/solana/solana_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  bool _isDonating = false;

  Future<void> _handleDonation() async {
    final l10n = AppLocalizations.of(context)!;
    final userAddress = ref.read(userProvider);
    if (userAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.connectWalletToDonate)),
      );
      return;
    }

    setState(() => _isDonating = true);
    try {
      final signature = await ref.read(solanaServiceProvider).sendSolPayment(
        senderAddress: userAddress,
        recipientAddress: AppConstants.projectFeeWallet,
        amount: 0.01, // Default donation amount
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.donationSent(signature.substring(0, 8)))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.donationError(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDonating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text(l10n.aboutTitle, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // App Logo & Name
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14F195).withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Image.asset(
                  'assets/logos/solana_logo.png', // Fallback to solana logo if app icon not available
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.flash_on, size: 50, color: Color(0xFF14F195)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Solchatplus',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'v1.0.0',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              // Information Cards
              _buildInfoCard(
                icon: Icons.account_tree_outlined,
                title: l10n.architecture,
                content: l10n.architectureDesc,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.copyright,
                title: l10n.copyright,
                content: l10n.copyrightDesc,
              ),
              const SizedBox(height: 32),
              
              // Donation Section
              Text(
                l10n.supportProject,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.donationDesc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white70, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              
              // QR Code
              GestureDetector(
                onTap: _handleDonation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9945FF).withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: QrImageView(
                    data: AppConstants.projectFeeWallet,
                    version: QrVersions.auto,
                    size: 180.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Wallet Address
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppConstants.projectFeeWallet,
                        style: GoogleFonts.robotoMono(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18, color: Color(0xFF14F195)),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: AppConstants.projectFeeWallet));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.addressCopied)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Direct Donation Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDonating ? null : _handleDonation,
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  label: Text(_isDonating ? l10n.processing : l10n.donateButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24243E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Color(0xFF14F195), width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF14F195), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
