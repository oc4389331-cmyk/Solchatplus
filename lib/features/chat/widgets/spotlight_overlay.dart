import 'package:flutter/material.dart';

class SpotlightOverlay extends StatelessWidget {
  final GlobalKey targetKey;
  final String message;
  final VoidCallback onDismiss;

  const SpotlightOverlay({
    super.key,
    required this.targetKey,
    required this.message,
    required this.onDismiss,
  });

  static OverlayEntry? _currentEntry;

  /// Shows the tutorial overlay safely using OverlayEntry
  static void show(BuildContext context, {
    required GlobalKey targetKey,
    required String message,
    required VoidCallback onDismiss,
  }) {
    // Ensure we don't show duplicates
    hide();
    
    _currentEntry = OverlayEntry(
      builder: (context) => SpotlightOverlay(
        targetKey: targetKey,
        message: message,
        onDismiss: () {
          hide();
          onDismiss();
        },
      ),
    );
    
    // Use the root overlay if possible to stay above everything
    final overlay = Overlay.of(context, debugRequiredFor: context.widget);
    overlay.insert(_currentEntry!);
  }

  /// Hides the tutorial overlay if it's currently visible
  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark background with hole
          GestureDetector(
            onTap: onDismiss,
            child: CustomPaint(
              size: Size.infinite,
              painter: _SpotlightPainter(targetKey: targetKey),
            ),
          ),
          // Instruction Text
          _buildInstruction(context),
        ],
      ),
    );
  }

  Widget _buildInstruction(BuildContext context) {
    // We need to position the text relative to the target
    final renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return const SizedBox.shrink();

    final offset = renderBox.localToGlobal(Offset.zero);
    
    return Positioned(
      left: 20,
      right: 20,
      bottom: MediaQuery.of(context).size.height - offset.dy + 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF14F195),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '¡NUEVO CHAT!',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('¡ENTENDIDO!'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Arrow pointing down
          const Icon(Icons.arrow_downward, color: Color(0xFF14F195), size: 40),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final GlobalKey targetKey;

  _SpotlightPainter({required this.targetKey});

  @override
  void paint(Canvas canvas, Size size) {
    final renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    final targetOffset = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;
    final center = Offset(
      targetOffset.dx + targetSize.width / 2,
      targetOffset.dy + targetSize.height / 2,
    );
    final radius = (targetSize.width / 2) + 10;

    final paint = Paint()..color = Colors.black.withOpacity(0.8);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addOval(Rect.fromCircle(center: center, radius: radius))
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
