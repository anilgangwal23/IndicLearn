import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
class CorrectAnswerBurstPainter extends CustomPainter {
  CorrectAnswerBurstPainter({required this.progress, required this.color}):super(repaint: progress);

  final Animation<double> progress;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if(t <= 0 || t >= 1) return;

    final center = Offset(size.width / 2, size.height * 0.38);
    final erased = Curves.easeOut.transform(t);
    final radius = 6.0 + 48.0 * erased;
    final linelength = 7.0 * (1.0-t);
    final paint = Paint()
      ..color = color.withValues(alpha: 1- t)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      final direction = Offset(math.cos(angle) , math.sin(angle) );
      canvas.drawLine( center + direction * radius,center+direction * (radius + linelength), paint);
    }

  }

  @override
  bool shouldRepaint(covariant CorrectAnswerBurstPainter oldDelegate) {
    return oldDelegate.progress != progress ||
      oldDelegate.color != color;
  }


}