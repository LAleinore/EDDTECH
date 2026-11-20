import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  TtsService() {
    _initTts();
  }

  void _initTts() async {
    try {
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isPlaying = true;
      });
      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
      });
      _flutterTts.setCancelHandler(() {
        _isPlaying = false;
      });
      _flutterTts.setErrorHandler((_) {
        _isPlaying = false;
      });
    } catch (_) {}
  }

  Future<void> speak(String text, {String language = 'ru-RU'}) async {
    try {
      if (_isPlaying) {
        await stop();
      }
      await _flutterTts.setLanguage(language);
      _isPlaying = true;
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isPlaying = false;
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
    } catch (_) {}
  }

  Future<void> setRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.1, 1.0));
    } catch (_) {}
  }
}
