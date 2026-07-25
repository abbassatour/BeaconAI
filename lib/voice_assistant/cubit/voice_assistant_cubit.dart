// lib/voice_assistant/cubit/voice_assistant_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:assistant_repository/assistant_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'voice_assistant_state.dart';

class VoiceAssistantCubit extends Cubit<VoiceAssistantState> {
  VoiceAssistantCubit({required AssistantRepository repository})
      : _repository = repository,
        super(const VoiceAssistantState());

  final AssistantRepository _repository;

  /// دالة لمعالجة النص المكتوب
  Future<void> submitCommand(String command) async {
    if (command.trim().isEmpty) return;
    await _execute(command);
  }

  /// دالة لبدء تسجيل الصوت
  Future<void> startListening() async {
    try {
      emit(state.copyWith(status: AssistantStatus.listening));
      
      // تحديد مسار حفظ الملف الصوتي المؤقت
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/command.m4a';
      
      await _repository.sttService.startRecording(path);
    } catch (e) {
      emit(state.copyWith(
        status: AssistantStatus.error,
        errorMessage: 'فشل الوصول للميكروفون: $e',
      ));
    }
  }

/// دالة إيقاف التسجيل ومعالجته
  Future<void> stopListening() async {
    try {
      emit(state.copyWith(status: AssistantStatus.thinking));
      
      final audioPath = await _repository.sttService.stopRecording();
      if (audioPath != null) {
        // نرسل مسار الملف الصوتي للـ Repository ليقوم بالتنفيذ
        await _repository.executeAudioCommand(audioPath);
        emit(state.copyWith(status: AssistantStatus.idle));
      } else {
        emit(state.copyWith(status: AssistantStatus.idle));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AssistantStatus.error,
        errorMessage: 'حدث خطأ: $e',
      ));
    }
  }
  /// دالة مركزية للتنفيذ
  Future<void> _execute(String command) async {
    try {
      emit(state.copyWith(status: AssistantStatus.thinking));
      await _repository.executeTextCommand(command);
      emit(state.copyWith(status: AssistantStatus.idle));
    } catch (e) {
      emit(state.copyWith(
        status: AssistantStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> testSpeech(String text) async {
    emit(state.copyWith(status: AssistantStatus.speaking));
    await _repository.speak(text);
    emit(state.copyWith(status: AssistantStatus.idle));
  }
}