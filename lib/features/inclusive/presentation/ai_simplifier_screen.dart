import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _openVideo(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (_) {
      await launchUrl(uri);
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

                // Step-by-step Guide
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

                // Educational Video Explainer Card (Дополнительный видеоролик)
                if (_result!.videoUrl != null && _result!.videoUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.play_circle_fill_rounded,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Обучающее видео по теме',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Наглядная анимация и видеоразбор',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondaryTextLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Interactive Video Thumbnail Banner
                        InkWell(
                          onTap: () => _openVideo(_result!.videoUrl),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E272E), Color(0xFF0F1418)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  bottom: 12,
                                  left: 14,
                                  right: 14,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _result!.videoTitle ?? 'Смотреть обучающий ролик',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'YouTube • Обучающая анимация для детей',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Big Play Button
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.5),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Action Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _openVideo(_result!.videoUrl),
                          icon: const Icon(Icons.smart_display_rounded, size: 20),
                          label: const Text(
                            'Открыть видео в YouTube',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
