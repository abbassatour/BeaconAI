// packages/speech_api/lib/src/stt/stt_service.dart

import 'package:record/record.dart';

class SttService {
  SttService({AudioRecorder? audioRecorder}) : _audioRecorder = audioRecorder ?? AudioRecorder();

  final AudioRecorder _audioRecorder;

  /// التحقق من صلاحيات الميكروفون
  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  /// بدء تسجيل صوت المستخدم وحفظه في مسار محدد
  Future<void> startRecording(String path) async {
    if (await hasPermission()) {
      // إعدادات التسجيل بصيغة M4A وجودة مناسبة لتحليل الذكاء الاصطناعي
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        numChannels: 1,
      );
      await _audioRecorder.start(config, path: path);
    } else {
      throw Exception('Microphone permission not granted');
    }
  }

  /// إيقاف التسجيل وإرجاع مسار الملف الصوتي
  Future<String?> stopRecording() async {
    if (await _audioRecorder.isRecording()) {
      return await _audioRecorder.stop();
    }
    return null;
  }
  
  /// التخلص من الكائنات بالذاكرة عند إغلاق التطبيق
  void dispose() {
    _audioRecorder.dispose();
  }
}