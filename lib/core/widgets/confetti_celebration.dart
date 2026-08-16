import 'dart:math';
import 'package:flutter/material.dart';

/// Celebration burst effect with animated colorful particles.
class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({
    super.key,
    required this.child,
    required this.trigger,
  });

  final Widget child;
  final bool trigger;

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addListener(() {
        setState(() {});
      });

    if (widget.trigger) {
      _burst();
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _burst();
    }
  }

  void _burst() {
    _particles.clear();
    const colors = [
      Color(0xFFF5C34A), // Gold
      Color(0xFFEDB1FF), // Lavender/Pink
      Color(0xFF4CAF76), // Emerald
      Color(0xFF5B7FD6), // Royal Blue
      Color(0xFFFF7E67), // Coral
      Color(0xFFE9C349), // Amber
    ];

    for (int i = 0; i < 36; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 80 + _random.nextDouble() * 180;
      final size = 4.0 + _random.nextDouble() * 6.0;
      final color = colors[_random.nextInt(colors.length)];
      _particles.add(
        _Particle(
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 60,
          color: color,
          size: size,
          rotation: _random.nextDouble() * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 8,
        ),
      );
    }

    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _controller.isAnimating
          ? _ParticlePainter(
              progress: _controller.value,
              particles: _particles,
            )
          : null,
      child: widget.child,
    );
  }
}

class _Particle {
  _Particle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });

  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.progress, required this.particles});

  final double progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final t = progress;
      final x = center.dx + p.vx * t;
      final y = center.dy + p.vy * t + 0.5 * 300 * t * t; // gravity

      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 1.5,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
