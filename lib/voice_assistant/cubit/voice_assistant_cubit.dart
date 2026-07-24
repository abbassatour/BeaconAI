// lib/voice_assistant/cubit/voice_assistant_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:assistant_repository/assistant_repository.dart';
import 'voice_assistant_state.dart';

class VoiceAssistantCubit extends Cubit<VoiceAssistantState> {
  VoiceAssistantCubit({required AssistantRepository repository})
      : _repository = repository,
        super(const VoiceAssistantState());

  final AssistantRepository _repository;

  /// هذه الدالة لتجربة النظام عبر إرسال نص مكتوب (بديل مؤقت للاستماع الصوتي)
  Future<void> submitCommand(String command) async {
    if (command.trim().isEmpty) return;

    try {
      emit(state.copyWith(status: AssistantStatus.thinking));
      
      // إرسال الأمر للـ Repository ليقوم بالتفكير ثم التنفيذ ثم النطق
      await _repository.executeTextCommand(command);
      
      emit(state.copyWith(status: AssistantStatus.idle));
    } catch (e) {
      emit(state.copyWith(
        status: AssistantStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// إجبار المساعد على النطق لتجربة الصوت
  Future<void> testSpeech(String text) async {
    emit(state.copyWith(status: AssistantStatus.speaking));
    await _repository.speak(text);
    emit(state.copyWith(status: AssistantStatus.idle));
  }
}