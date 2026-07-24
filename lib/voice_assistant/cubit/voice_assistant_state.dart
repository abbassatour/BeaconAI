// lib/voice_assistant/cubit/voice_assistant_state.dart

enum AssistantStatus { idle, listening, thinking, executing, speaking, error }

class VoiceAssistantState {
  const VoiceAssistantState({
    this.status = AssistantStatus.idle,
    this.errorMessage,
  });

  final AssistantStatus status;
  final String? errorMessage;

  VoiceAssistantState copyWith({
    AssistantStatus? status,
    String? errorMessage,
  }) {
    return VoiceAssistantState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}