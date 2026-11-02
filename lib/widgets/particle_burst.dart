import 'dart:math';

import 'package:flutter/material.dart';

import '../models/reaction_type.dart';

/// 回响按钮彩色粒子喷射
class ParticleBurstOverlay {
  ParticleBurstOverlay._();

  static void show({
    required BuildContext context,
    required Offset globalPosition,
    required ReactionType type,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        return _ParticleLayer(
          origin: globalPosition,
          color: type.particleColor,
          onDone: () => entry.remove(),
        );
      },
    );
    overlay.insert(entry);
  }
}

class _ParticleLayer extends StatefulWidget {
  const _ParticleLayer({
    required this.origin,
    required this.color,
    required this.onDone,
  });

  final Offset origin;
  final Color color;
  final VoidCallback onDone;

  @override
  State<_ParticleLayer> createState() => _ParticleLayerState();
}

class _ParticleLayerState extends State<_ParticleLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(6, (_) {
      return _Particle(
        dx: _rand.nextDouble() * 80 - 40,
        size: 8 + _rand.nextDouble() * 4,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeOutCubic.transform(_controller.value);
          return Stack(
            children: _particles.map((p) {
              return Positioned(
                left: widget.origin.dx - p.size / 2 + p.dx * t,
                top: widget.origin.dy - p.size / 2 - 75 * t,
                child: Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.6 + 0.6 * t,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _Particle {
  _Particle({required this.dx, required this.size});
  final double dx;
  final double size;
}
