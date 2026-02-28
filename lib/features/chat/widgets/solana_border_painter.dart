import 'package:flutter/material.dart';
import 'dart:math' as math;

class SolanaBorderPainter extends CustomPainter {
  final double animationValue;

  SolanaBorderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = SweepGradient(
        colors: const [
          Color(0xFF9945FF), // Solana Purple
          Color(0xFF14F195), // Solana Green
          Color(0xFF00FFA3), // Solana Cyan
          Color(0xFF9945FF), // Back to Purple for seamless loop
        ],
        transform: GradientRotation(animationValue * 2 * math.pi),
      ).createShader(rect);

    canvas.drawCircle(center, radius + 2, paint);
  }

  @override
  bool shouldRepaint(covariant SolanaBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class SolanaAnimatedBorder extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const SolanaAnimatedBorder({
    super.key,
    required this.child,
    required this.isActive,
  });

  @override
  State<SolanaAnimatedBorder> createState() => _SolanaAnimatedBorderState();
}

class _SolanaAnimatedBorderState extends State<SolanaAnimatedBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SolanaAnimatedBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SolanaBorderPainter(animationValue: _controller.value),
          child: Padding(
            padding: const EdgeInsets.all(2.0), // Space for the border
            child: widget.child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
