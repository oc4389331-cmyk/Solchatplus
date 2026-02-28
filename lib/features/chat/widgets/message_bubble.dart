import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final bool showTail;
  final VoidCallback? onLongPress;
  final VoidCallback? onTapImage;
  final Widget? senderNameWidget;

  const MessageBubble({
    super.key,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.showTail = true,
    this.onLongPress,
    this.onTapImage,
    this.senderNameWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Solana Colors & Gradients
    // Me: Green Gradient (Solana Green to darker teal)
    final meGradient = const LinearGradient(
      colors: [Color(0xFF14F195), Color(0xFF0F7A58)], 
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    // Other: Purple Gradient (Solana Purple to deep violet)
    final otherGradient = const LinearGradient(
      colors: [Color(0xFF9945FF), Color(0xFF6E1BFF)], 
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final textColor = Colors.white;
    final timeColor = Colors.white70;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 64 : 16,
          right: isMe ? 16 : 64,
        ),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: CustomPaint(
            painter: showTail ? BubbleTailPainter(
              color: isMe ? const Color(0xFF0F7A58) : const Color(0xFF6E1BFF), // Tail matches end of gradient
              isMe: isMe
            ) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe ? meGradient : otherGradient,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (senderNameWidget != null) ...[
                    senderNameWidget!,
                    const SizedBox(height: 2),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(timestamp),
                        style: GoogleFonts.inter(
                          color: timeColor,
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all, 
                          size: 14,
                          color: Colors.white70, 
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isMe;

  BubbleTailPainter({required this.color, required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    if (isMe) {
      // Right tail
      path.moveTo(size.width, size.height - 16);
      path.quadraticBezierTo(
        size.width + 8,
        size.height,
        size.width + 12,
        size.height,
      );
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      // Left tail
      path.moveTo(0, size.height - 16);
      path.quadraticBezierTo(
        -8,
        size.height,
        -12,
        size.height,
      );
      path.lineTo(0, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
