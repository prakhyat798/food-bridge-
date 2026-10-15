import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A minimal, elegant animated wave background for hero sections.
class AnimatedWavyHeader extends StatefulWidget {
  final double height;
  final Widget child;
  final Color? waveColor;
  final Color? backgroundColor;

  const AnimatedWavyHeader({
    super.key,
    this.height = 240,
    required this.child,
    this.waveColor,
    this.backgroundColor,
  });

  @override
  State<AnimatedWavyHeader> createState() => _AnimatedWavyHeaderState();
}

class _AnimatedWavyHeaderState extends State<AnimatedWavyHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Color
          Container(
            color: widget.backgroundColor ?? AppColors.primary,
          ),
          
          // Animated Waves
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WavePainter(
                    animationValue: _controller.value,
                    waveColor: widget.waveColor ?? Colors.white.withOpacity(0.15),
                  ),
                );
              },
            ),
          ),
          
          // Content
          SafeArea(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;

  _WavePainter({required this.animationValue, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;
      
    final paint2 = Paint()
      ..color = waveColor.withOpacity(waveColor.opacity * 0.5)
      ..style = PaintingStyle.fill;

    _drawWave(canvas, size, paint1, animationValue, 0.08, 20);
    _drawWave(canvas, size, paint2, animationValue + 0.5, 0.1, 30);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double animationValue, double frequency, double amplitude) {
    final path = Path();
    path.moveTo(0, size.height);
    
    final baseHeight = size.height * 0.75;
    
    for (double x = 0; x <= size.width; x += 3) {
      final y = baseHeight + math.sin((x * frequency) + (animationValue * 2 * math.pi)) * amplitude;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.waveColor != waveColor;
  }
}
