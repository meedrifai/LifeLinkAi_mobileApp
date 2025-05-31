import 'package:flutter/material.dart';
import 'plasma_renderer.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF9A0007),
                Color(0xFFB71C1C),
                Color(0xFFD32F2F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        
        // Animated particles overlay
        PlasmaRenderer(
          type: PlasmaType.infinity,
          particles: 7,
          color: const Color(0xFFFFCDD2),
          blur: 0.4,
          size: 1.0,
          speed: 1.6,
          offset: 0,
          blendMode: BlendMode.plus,
          variation1: 0,
          variation2: 0,
          variation3: 0,
        ),
        
        // Subtle pattern overlay
        Opacity(
          opacity: 0.05,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pattern.png'),
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ),
      ],
    );
  }
}