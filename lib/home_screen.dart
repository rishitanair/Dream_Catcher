import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'dream_diary_screen.dart';
import 'lucid_dream_screen.dart';
import 'emotion_journal_screen.dart';
import 'scenery_painter.dart';

class HomeScreen extends StatefulWidget {
  final bool isNight;
  final VoidCallback onToggleTheme;

  const HomeScreen(
      {super.key, required this.isNight, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _mainAnimation;
  final List<Offset> _stars = [];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _mainAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_mainController);

    final random = Random();
    for (int i = 0; i < 50; i++) {
      _stars.add(Offset(
        random.nextDouble() * 400,
        random.nextDouble() * 800,
      ));
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: widget.onToggleTheme,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: widget.isNight
                ? [Colors.indigo.shade800, Colors.purple.shade800]
                : [Colors.orange.shade200, Colors.pink.shade200],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              left: widget.isNight ? 50 : 0,
              right: widget.isNight ? 0 : 50,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.isNight ? Icons.nightlight_round : Icons.wb_sunny,
                    color:
                        widget.isNight ? Colors.indigo.shade800 : Colors.orange,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 10.0, horizontal: 40), // Increased horizontal padding
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 400, // Added fixed width to make buttons shorter horizontally
          padding: const EdgeInsets.all(15), // Reduced padding
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isNight
                  ? [Colors.indigo.shade700, Colors.purple.shade700]
                  : [Colors.blue.shade400, Colors.pink.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(delay: 200.ms).fadeIn(),
    );
  }

  void _navigate(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: anim,
                curve: Curves.easeOutQuart,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _mainAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: SceneryPainter(
                  _mainAnimation.value,
                  isNight: widget.isNight,
                ),
              );
            },
          ),
          if (widget.isNight)
            CustomPaint(
              painter: StarsPainter(
                stars: _stars,
                animationValue: _mainController.value,
              ),
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SvgPicture.asset(
                          widget.isNight ? 'assets/moon.jpg' : 'assets/sun.jpg',
                          width: 80,
                          height: 80,
                        ).animate().scale(delay: 100.ms),
                        const SizedBox(height: 10),
                        Text(
                          'Dream Catcher',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: widget.isNight
                                ? Colors.white
                                : Colors.blue.shade800,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withAlpha(51),
                                offset: const Offset(2, 2),
                              )
                            ],
                          ),
                        ).animate().fadeIn().slideY(duration: 500.ms),
                        Text(
                          'Capture your dreams & emotions',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.isNight
                                ? Colors.grey.shade300
                                : Colors.blue.shade600,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildButton(
                      'Dream Diary',
                      Icons.nightlight_round,
                      () =>
                          _navigate(DreamDiaryScreen(isNight: widget.isNight)),
                    ),
                    _buildButton(
                      'Lucid Dream Trainer',
                      Icons.psychology,
                      () =>
                          _navigate(LucidDreamScreen(isNight: widget.isNight)),
                    ),
                    _buildButton(
                      'Emotion Journal',
                      Icons.emoji_emotions,
                      () => _navigate(
                          EmotionJournalScreen(isNight: widget.isNight)),
                    ),
                    const SizedBox(height: 30),
                    _buildThemeToggle(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StarsPainter extends CustomPainter {
  final List<Offset> stars;
  final double animationValue;

  StarsPainter({required this.stars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          Colors.white.withAlpha((127 * (0.5 + animationValue * 0.5)).toInt());
    for (final star in stars) {
      canvas.drawCircle(star, 1 + animationValue * 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.stars != stars;
  }
}
