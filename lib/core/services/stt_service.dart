import 'package:speech_to_text/speech_to_text.dart' as stt;

class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  Future<bool> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        onError: (_) {
          _isListening = false;
        },
      );
      return _isAvailable;
    } catch (_) {
      _isAvailable = false;
      return false;
    }
  }

  Future<void> startListening({
    required Function(String text) onResult,
    String localeId = 'ru_RU',
  }) async {
    if (!_isAvailable) {
      final initialized = await initialize();
      if (!initialized) {
        onResult(
          "Внимание: микрофон или распознавание речи не поддерживается в данной среде.",
        );
        return;
      }
    }

    try {
      _isListening = true;
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    } catch (_) {
      _isListening = false;
    }
  }

  Future<void> stopListening() async {
    try {
      _isListening = false;
      await _speech.stop();
    } catch (_) {}
  }
}
