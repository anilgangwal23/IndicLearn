
import 'dart:math';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

class WinScreen extends StatefulWidget {
  const WinScreen({super.key});

  @override
  State<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<WinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _controller.forward();
  }

  void _replay() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF17132F),
      body: Stack(
        children: [
          // Animated confetti explosion.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ConfettiPainter(
                  progress: _controller,
                ),
              ),
            ),
          ),

          // Victory content.
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final p = Curves.elasticOut.transform(
                  (_controller.value * 1.5).clamp(0.0, 1.0),
                );

                return Opacity(
                  opacity: _controller.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.35 + 0.65 * p,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.celebrationTrophy,
                    style: const TextStyle(fontSize: 100),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.celebrationWon,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Color(0xFFFFD54F),
                      shadows: [
                        Shadow(
                          color: Colors.orange,
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.celebrationAmazingJob,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton.icon(
                    onPressed: _replay,
                    icon: const Icon(Icons.celebration),
                    label: Text(l10n.celebrationCelebrateAgain),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC857),
                      foregroundColor: const Color(0xFF21183F),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  ConfettiPainter({required this.progress})
      : particles = List.generate(180, (i) {
          final random = Random(i * 17 + 42);

          return _Particle(
            angle: random.nextDouble() * 2 * pi,
            speed: 100 + random.nextDouble() * 430,
            size: 4 + random.nextDouble() * 8,
            rotation: random.nextDouble() * 2 * pi,
            spin: (random.nextDouble() - 0.5) * 12,
            color: [
              const Color(0xFFFF5252),
              const Color(0xFFFFD740),
              const Color(0xFF69F0AE),
              const Color(0xFF40C4FF),
              const Color(0xFFE040FB),
              Colors.white,
              const Color(0xFFFF9100),
            ][random.nextInt(7)],
            shape: random.nextInt(3),
          );
        }),
        super(repaint: progress);

  final Animation<double> progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0) return;

    final origin = Offset(size.width / 2, size.height * 0.38);

    for (final particle in particles) {
      // Particles travel outward and then fall under gravity.
      final distance = particle.speed * t;

      final x = origin.dx +
          cos(particle.angle) * distance;

      final y = origin.dy +
          sin(particle.angle) * distance +
          260 * t * t;

      // Fade away near the end.
      final fade = (1.0 - t).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: fade)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(
        particle.rotation + particle.spin * t,
      );

      switch (particle.shape) {
        case 0:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 1.8,
              height: particle.size * 0.7,
            ),
            paint,
          );
          break;

        case 1:
          canvas.drawCircle(
            Offset.zero,
            particle.size * 0.5,
            paint,
          );
          break;

        default:
          final path = Path()
            ..moveTo(0, -particle.size)
            ..lineTo(particle.size * 0.8, particle.size)
            ..lineTo(-particle.size * 0.8, particle.size)
            ..close();

          canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.spin,
    required this.color,
    required this.shape,
  });

  final double angle;
  final double speed;
  final double size;
  final double rotation;
  final double spin;
  final Color color;
  final int shape;
}
