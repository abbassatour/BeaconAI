// packages/speech_api/lib/src/tts/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService({FlutterTts? flutterTts}) : _flutterTts = flutterTts ?? FlutterTts() {
    _initTts();
  }

  final FlutterTts _flutterTts;

  Future<void> _initTts() async {
    // إعداد اللغة العربية كافتراضي
    await _flutterTts.setLanguage("ar-SA"); 
    // ضبط سرعة ونبرة الصوت
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  /// نطق نص معين
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  /// إيقاف النطق
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// تغيير لغة النطق (مثلاً 'en-US' أو 'ar-SA')
  Future<void> setLanguage(String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
  }
}