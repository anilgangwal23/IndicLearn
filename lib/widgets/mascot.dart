
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

@Preview(name: 'Cartoon Mascot', size: Size(390, 844))
Widget previewMascot() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MascotDemo(),
  );
}

class MascotDemo extends StatefulWidget {
  const MascotDemo({super.key});

  @override
  State<MascotDemo> createState() => _MascotDemoState();
}

class _MascotDemoState extends State<MascotDemo>
    with TickerProviderStateMixin {
  late final AnimationController blinkController;
  late final AnimationController spinController;

  bool eyebrowsUp = false;

  @override
  void initState() {
    super.initState();

    blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Blink periodically, with a pause between blinks.
    blinkController.repeat(
      period: const Duration(seconds: 3),
    );

    spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    blinkController.dispose();
    spinController.dispose();
    super.dispose();
  }

  Widget eye() {
    return AnimatedBuilder(
      animation: blinkController,
      builder: (context, child) {
        // Mostly open; closes briefly near the end of each cycle.
        final t = blinkController.value;
        final blink = (t > 0.90 && t < 0.96)
            ? 0.08
            : 1.0;

        return Container(
          width: 30,
          height: 38 * blink,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          alignment: Alignment.center,
          child: blink < 0.5
              ? const SizedBox.shrink()
              : Container(
                  width: 13,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
        );
      },
    );
  }

  Widget eyebrow() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 34,
      height: 6,
      transform: Matrix4.rotationZ(
        eyebrowsUp ? -0.12 : 0.08,
      ),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.brown.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cartoon Mascot')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: Tween<double>(
                begin: 0,
                end: 1,
              ).animate(
                CurvedAnimation(
                  parent: spinController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Head
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade300,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.brown,
                          width: 3,
                        ),
                      ),
                    ),

                    // Eyebrows
                    Positioned(
                      left: 53,
                      top: eyebrowsUp ? 53 : 60,
                      child: eyebrow(),
                    ),
                    Positioned(
                      right: 53,
                      top: eyebrowsUp ? 53 : 60,
                      child: eyebrow(),
                    ),

                    // Eyes
                    Positioned(
                      left: 56,
                      top: 76,
                      child: eye(),
                    ),
                    Positioned(
                      right: 56,
                      top: 76,
                      child: eye(),
                    ),

                    // Smile
                    Positioned(
                      top: 125,
                      child: Container(
                        width: 65,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.brown,
                            width: 2,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(35),
                            bottomRight: Radius.circular(35),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 35),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      eyebrowsUp = !eyebrowsUp;
                    });
                  },
                  child: const Text('Raise eyebrows'),
                ),
                ElevatedButton(
                  onPressed: () {
                    spinController.forward(from: 0);
                  },
                  child: const Text('Spin'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
