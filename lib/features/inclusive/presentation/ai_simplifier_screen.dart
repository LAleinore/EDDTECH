import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/inputs.dart';
import '../data/inclusive_repository.dart';
import '../domain/inclusive_material_model.dart';

class AiSimplifierScreen extends ConsumerStatefulWidget {
  const AiSimplifierScreen({super.key});

  @override
  ConsumerState<AiSimplifierScreen> createState() => _AiSimplifierScreenState();
}

class _AiSimplifierScreenState extends ConsumerState<AiSimplifierScreen> {
  final _textController = TextEditingController(
    text:
        'Фотосинтез представляет собой сложный многоступенчатый фотохимический процесс преобразования лучистой энергии видимого света в энергию химических связей органических соединений при участии хлорофилла и ферментов.',
  );
  bool _isLoading = false;
  SimplifiedResultModel? _result;
  final TtsService _ttsService = TtsService();

  @override
  void dispose() {
    _textController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _simplify() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final res = await ref
          .read(inclusiveRepositoryProvider)
          .simplifyText(text: _textController.text.trim());
      setState(() {
        _result = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _speakText(String text) {
    if (_ttsService.isPlaying) {
      _ttsService.stop();
      setState(() {});
    } else {
      _ttsService.speak(text);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Simplifier')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _textController,
                label: 'Сложный учебный текст',
                hint: 'Вставьте параграф из учебника или научную статью...',
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              PrimaryButton(
                text: 'Упростить и адаптировать',
                icon: Icons.auto_stories_rounded,
                backgroundColor: AppColors.inclusiveAccent,
                isLoading: _isLoading,
                onPressed: _simplify,
              ),

              if (_result != null) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _result!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.inclusiveAccent,
                      ),
                      icon: Icon(
                        _ttsService.isPlaying
                            ? Icons.stop_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => _speakText(
                        '${_result!.simpleExplanation}. ${_result!.summary}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Simple Explanation Card
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Простое объяснение',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result!.simpleExplanation,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.bookmark_border_rounded, color: AppColors.primary, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Главная суть:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _result!.summary,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryTextLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Step-by-step
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Пошаговый алгоритм:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._result!.stepByStepGuide.map(
                        (step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            step,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Key Concepts
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Опорные понятия:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._result!.keyConcepts.map(
                        (k) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: '${k.term}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.inclusiveAccent,
                                  ),
                                ),
                                TextSpan(text: k.definition),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
