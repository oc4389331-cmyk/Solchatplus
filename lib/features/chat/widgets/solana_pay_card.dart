import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SolanaPayCard extends StatelessWidget {
  final double amount;
  final String status; // "Confirmando pago..." | "Pago realizado"
  final bool isMe;
  final String tokenSymbol;
  final String? signature;

  const SolanaPayCard({
    super.key,
    required this.amount,
    required this.status,
    required this.isMe,
    this.tokenSymbol = 'SOL',
    this.signature,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Me: Green Gradient (Solana Green to darker teal)
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        onTap: () async {
          if (signature != null && signature!.isNotEmpty) {
            final url = Uri.parse('https://solscan.io/tx/$signature');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 250,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF1B1B3A), Color(0xFF0F0C29)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9945FF).withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Row(
                    children: [
                      // Solana Pay Icon (Restored)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          // gradient: LinearGradient(colors: [Color(0xFF9945FF), Color(0xFF14F195)]),
                        ),
                        child: Image.asset(
                          tokenSymbol == 'SKR' 
                            ? 'assets/skr.png' 
                            : 'assets/solana-sol-seeklogo.png',
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.flash_on, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SolchatPay',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (signature != null)
                    const Icon(Icons.open_in_new, color: Colors.white38, size: 14),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Enviando $amount $tokenSymbol',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '$amount $tokenSymbol',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status,
                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 10),
                  ),
                  Row(
                    children: [
                      _buildDot(true),
                      _buildDot(true),
                      _buildDot(false),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.white : Colors.white24,
      ),
    );
  }
}
