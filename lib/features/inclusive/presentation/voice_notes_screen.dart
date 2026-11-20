import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/widgets/cards.dart';

class VoiceNotesScreen extends StatefulWidget {
  const VoiceNotesScreen({super.key});

  @override
  State<VoiceNotesScreen> createState() => _VoiceNotesScreenState();
}

class _VoiceNotesScreenState extends State<VoiceNotesScreen> {
  final _textController = TextEditingController();
  final SttService _sttService = SttService();
  final TtsService _ttsService = TtsService();

  bool _isRecording = false;
  double _speechRate = 0.5;

  @override
  void dispose() {
    _textController.dispose();
    _sttService.stopListening();
    _ttsService.stop();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isRecording) {
      await _sttService.stopListening();
      setState(() => _isRecording = false);
    } else {
      setState(() => _isRecording = true);
      await _sttService.startListening(
        onResult: (text) {
          setState(() {
            _textController.text = text;
          });
        },
      );
    }
  }

  void _playTts() {
    if (_textController.text.trim().isEmpty) return;
    _ttsService.setRate(_speechRate);
    _ttsService.speak(_textController.text.trim());
  }

  void _stopTts() {
    _ttsService.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Голосовой ввод и озвучивание')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Microphone Recording Banner
              Center(
                child: GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? AppColors.error : AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isRecording
                                      ? AppColors.error
                                      : AppColors.primary)
                                  .withOpacity(0.35),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isRecording
                    ? 'Идет запись... Говорите'
                    : 'Нажмите на микрофон для записи речи',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isRecording
                      ? AppColors.error
                      : AppColors.secondaryTextLight,
                ),
              ),
              const SizedBox(height: 24),

              // Transcribed Text Field
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Текст заметки',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 20),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _textController.text),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Текст скопирован в буфер обмена',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText:
                            'Здесь появится распознанный текст или введите свой...',
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // TTS Controls Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Озвучивание текста (TTS)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Скорость речи:',
                          style: TextStyle(fontSize: 13),
                        ),
                        Expanded(
                          child: Slider(
                            value: _speechRate,
                            min: 0.2,
                            max: 1.0,
                            divisions: 4,
                            label: '${(_speechRate * 2).toStringAsFixed(1)}x',
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setState(() => _speechRate = val),
                          ),
                        ),
                        Text(
                          '${(_speechRate * 2).toStringAsFixed(1)}x',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            onPressed: _playTts,
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Озвучить',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _stopTts,
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text('Стоп'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
