import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/buttons.dart';

class ExerciseTimerScreen extends StatefulWidget {
  const ExerciseTimerScreen({super.key});

  @override
  State<ExerciseTimerScreen> createState() => _ExerciseTimerScreenState();
}

class _ExerciseTimerScreenState extends State<ExerciseTimerScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsLeft = 0;
  String _phase = 'Готовы начать?'; // Вдох, Задержка, Выдох
  int _cycleCount = 0;
  bool _isRunning = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startBreathingCycle() {
    setState(() {
      _isRunning = true;
      _cycleCount = 0;
    });
    _runInhale();
  }

  void _runInhale() {
    setState(() {
      _phase = 'Вдох через нос (4с)';
      _secondsLeft = 4;
    });
    _animController.forward(from: 0.0);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        _runHold();
      }
    });
  }

  void _runHold() {
    setState(() {
      _phase = 'Задержка дыхания (7с)';
      _secondsLeft = 7;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        _runExhale();
      }
    });
  }

  void _runExhale() {
    setState(() {
      _phase = 'Плавный выдох ртом (8с)';
      _secondsLeft = 8;
    });
    _animController.reverse(from: 1.0);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        _cycleCount++;
        if (_cycleCount < 4) {
          _runInhale();
        } else {
          setState(() {
            _isRunning = false;
            _phase = 'Упражнение завершено! Отличная работа.';
          });
        }
      }
    });
  }

  void _stop() {
    _timer?.cancel();
    _animController.stop();
    setState(() {
      _isRunning = false;
      _phase = 'Готовы начать?';
      _secondsLeft = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Дыхание 4-7-8')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Успокаивающая практика 4-7-8',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Снижает частоту сердечных сокращений и моментально снижает стресс.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryTextLight,
                ),
              ),
              const Spacer(),

              // Animated Breathing Circle
              Center(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isRunning ? _scaleAnimation.value : 1.0,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              AppColors.mindcareAccent,
                              Color(0xFF6AD0EE),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mindcareAccent.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_secondsLeft',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (_isRunning)
                                Text(
                                  'Цикл ${_cycleCount + 1}/4',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),

              Text(
                _phase,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mindcareAccent,
                ),
              ),
              const Spacer(),

              if (!_isRunning) ...[
                PrimaryButton(
                  text: 'Начать практику (4 цикла)',
                  icon: Icons.play_arrow_rounded,
                  backgroundColor: AppColors.mindcareAccent,
                  onPressed: _startBreathingCycle,
                ),
              ] else ...[
                SecondaryButton(
                  text: 'Остановить',
                  icon: Icons.stop_rounded,
                  onPressed: _stop,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
