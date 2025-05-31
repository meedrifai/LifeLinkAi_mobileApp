import 'dart:math';
import 'package:flutter/material.dart';

// Custom Plasma Animation
enum PlasmaType { infinity, bubbles, circle }

class PlasmaRenderer extends StatefulWidget {
  final PlasmaType type;
  final int particles;
  final Color color;
  final double blur;
  final double size;
  final double speed;
  final double offset;
  final BlendMode blendMode;
  final double variation1;
  final double variation2;
  final double variation3;

  const PlasmaRenderer({
    super.key,
    this.type = PlasmaType.infinity,
    this.particles = 10,
    this.color = Colors.white,
    this.blur = 0.75,
    this.size = 1.0,
    this.speed = 1.0,
    this.offset = 0.0,
    this.blendMode = BlendMode.srcOver,
    this.variation1 = 0.0,
    this.variation2 = 0.0,
    this.variation3 = 0.0,
  });

  @override
  _PlasmaRendererState createState() => _PlasmaRendererState();
}

class _PlasmaRendererState extends State<PlasmaRenderer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: PlasmaPainter(
            value: _controller.value,
            type: widget.type,
            particles: widget.particles,
            color: widget.color,
            blur: widget.blur,
            size: widget.size,
            speed: widget.speed,
            offset: widget.offset,
            blendMode: widget.blendMode,
            variation1: widget.variation1,
            variation2: widget.variation2,
            variation3: widget.variation3,
          ),
          child: Container(),
        );
      },
    );
  }
}

class PlasmaPainter extends CustomPainter {
  final double value;
  final PlasmaType type;
  final int particles;
  final Color color;
  final double blur;
  final double size;
  final double speed;
  final double offset;
  final BlendMode blendMode;
  final double variation1;
  final double variation2;
  final double variation3;

  PlasmaPainter({
    required this.value,
    this.type = PlasmaType.infinity,
    this.particles = 10,
    this.color = Colors.white,
    this.blur = 0.75,
    this.size = 1.0,
    this.speed = 1.0,
    this.offset = 0.0,
    this.blendMode = BlendMode.srcOver,
    this.variation1 = 0.0,
    this.variation2 = 0.0,
    this.variation3 = 0.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill
      ..blendMode = blendMode;

    final blurSigma = blur * 100;
    if (blurSigma > 0) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    }

    final particleSize = size * 50;
    final maxDimension = canvasSize.width > canvasSize.height ? canvasSize.width : canvasSize.height;
    final time = value * speed;
    
    for (int i = 0; i < particles; i++) {
      final progress = (i / particles) + time + offset;
      final modProgress = progress % 1.0;
      
      double x, y;
      double particleSizeFactor = 1.0;
      
      switch (type) {
        case PlasmaType.infinity:
          // Infinity path motion
          final angle = modProgress * 2 * 3.14159;
          final cosAngle = cos(angle);
          final sinAngle = sin(angle * 2);
          x = canvasSize.width * 0.5 + cosAngle * canvasSize.width * 0.3;
          y = canvasSize.height * 0.5 + sinAngle * canvasSize.height * 0.2;
          particleSizeFactor = 0.5 + 0.5 * sin(angle * 3 + variation1);
          break;
          
        case PlasmaType.bubbles:
          // Random bubbling motion
          final seedX = i * 1000.0;
          final seedY = i * 2000.0;
          final radiusSeed = i * 3000.0;
          final radius = canvasSize.width * 0.3;
          
          x = canvasSize.width * 0.5 + sin(seedX + time * 3) * radius;
          y = canvasSize.height * 0.5 + cos(seedY + time * 2) * radius;
          particleSizeFactor = 0.5 + 0.5 * sin(radiusSeed + time * 4);
          break;
          
        case PlasmaType.circle:
          // Circular motion
          final angle = modProgress * 2 * 3.14159;
          x = canvasSize.width * 0.5 + cos(angle) * canvasSize.width * 0.4;
          y = canvasSize.height * 0.5 + sin(angle) * canvasSize.height * 0.4;
          break;
      }
      
      final finalSize = particleSize * particleSizeFactor;
      canvas.drawCircle(Offset(x, y), finalSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PlasmaPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}