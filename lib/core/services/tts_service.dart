import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String? _currentVoiceName;
  String? get currentVoiceName => _currentVoiceName;

  double _currentRate = 0.9;
  double get currentRate => _currentRate;

  final ValueNotifier<bool> playingStateNotifier = ValueNotifier<bool>(false);

  TtsService() {
    _initTts();
  }

  void _initTts() async {
    try {
      // Natural conversational tempo for speech synthesis
      await _flutterTts.setSpeechRate(0.9);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.02);

      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        playingStateNotifier.value = true;
      });
      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        playingStateNotifier.value = false;
      });
      _flutterTts.setCancelHandler(() {
        _isPlaying = false;
        playingStateNotifier.value = false;
      });
      _flutterTts.setErrorHandler((_) {
        _isPlaying = false;
        playingStateNotifier.value = false;
      });

      await configureBestRussianVoice();
    } catch (_) {}
  }

  /// Finds and applies the highest quality natural human voice available on the device/browser.
  Future<void> configureBestRussianVoice() async {
    try {
      await _flutterTts.setLanguage('ru-RU');

      final dynamic rawVoices = await _flutterTts.getVoices;
      if (rawVoices is List && rawVoices.isNotEmpty) {
        final ruVoices = <Map<String, String>>[];
        for (final v in rawVoices) {
          if (v is Map) {
            final name = v['name']?.toString() ?? '';
            final locale = v['locale']?.toString() ?? '';
            if (locale.toLowerCase().startsWith('ru') ||
                name.toLowerCase().contains('russ') ||
                name.toLowerCase().contains('русск')) {
              ruVoices.add({'name': name, 'locale': locale});
            }
          }
        }

        if (ruVoices.isNotEmpty) {
          // Priority 1: Natural / Online / Neural voices (Edge / Chrome Azure Neural)
          final bestVoice = ruVoices.firstWhere(
            (v) {
              final n = v['name']!.toLowerCase();
              return n.contains('natural') ||
                  n.contains('online') ||
                  n.contains('neural');
            },
            orElse: () => ruVoices.firstWhere(
              // Priority 2: Google русский (Warm natural neural voice)
              (v) => v['name']!.toLowerCase().contains('google'),
              orElse: () => ruVoices.firstWhere(
                // Priority 3: Svetlana / Dariya / Elena natural female voice
                (v) {
                  final n = v['name']!.toLowerCase();
                  return n.contains('svetlana') ||
                      n.contains('dariya') ||
                      n.contains('elena') ||
                      n.contains('irina');
                },
                orElse: () => ruVoices.first,
              ),
            ),
          );

          _currentVoiceName = bestVoice['name'];
          await _flutterTts.setVoice({
            'name': bestVoice['name']!,
            'locale': bestVoice['locale']!.isNotEmpty ? bestVoice['locale']! : 'ru-RU',
          });
        }
      }
    } catch (_) {}
  }

  Future<void> speak(String text, {String language = 'ru-RU'}) async {
    try {
      if (_isPlaying) {
        await stop();
      }
      if (language != 'ru-RU') {
        await _flutterTts.setLanguage(language);
      } else {
        await configureBestRussianVoice();
      }

      _isPlaying = true;
      playingStateNotifier.value = true;
      await _flutterTts.speak(text);
    } catch (_) {
      _isPlaying = false;
      playingStateNotifier.value = false;
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isPlaying = false;
      playingStateNotifier.value = false;
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
      playingStateNotifier.value = false;
    } catch (_) {}
  }

  Future<void> setRate(double rate) async {
    try {
      _currentRate = rate.clamp(0.2, 1.5);
      await _flutterTts.setSpeechRate(_currentRate);
    } catch (_) {}
  }
}
