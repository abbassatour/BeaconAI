// lib/voice_assistant/view/voice_assistant_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/voice_assistant_cubit.dart';
import '../cubit/voice_assistant_state.dart';

class VoiceAssistantPage extends StatelessWidget {
  const VoiceAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('BeaconAI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<VoiceAssistantCubit, VoiceAssistantState>(
                builder: (context, state) {
                  IconData icon;
                  Color color;
                  String text;

                  switch (state.status) {
                    case AssistantStatus.idle:
                      icon = Icons.mic_none;
                      color = Colors.grey;
                      text = 'جاهز للاستماع...';
                      break;
                    case AssistantStatus.listening:
                      icon = Icons.mic;
                      color = Colors.blueAccent;
                      text = 'أتسمعك بوضوح...';
                      break;
                    case AssistantStatus.thinking:
                      icon = Icons.memory;
                      color = Colors.orange;
                      text = 'أفكر...';
                      break;
                    case AssistantStatus.executing:
                      icon = Icons.settings_applications;
                      color = Colors.green;
                      text = 'أنفذ الأمر...';
                      break;
                    case AssistantStatus.speaking:
                      icon = Icons.volume_up;
                      color = Colors.purple;
                      text = 'أتحدث...';
                      break;
                    case AssistantStatus.error:
                      icon = Icons.error_outline;
                      color = Colors.red;
                      text = state.errorMessage ?? 'حدث خطأ!';
                      break;
                  }

                  return Column(
                    children: [
                      // زر الميكروفون (اضغط مطولاً للتحدث)
                      GestureDetector(
                        onTapDown: (_) => context.read<VoiceAssistantCubit>().startListening(),
                        onTapUp: (_) => context.read<VoiceAssistantCubit>().stopListening(),
                        onTapCancel: () => context.read<VoiceAssistantCubit>().stopListening(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(state.status == AssistantStatus.listening ? 40 : 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.2),
                            border: Border.all(color: color, width: 3),
                            boxShadow: state.status == AssistantStatus.listening
                                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 20, spreadRadius: 10)]
                                : [],
                          ),
                          child: Icon(icon, size: 80, color: color),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        text,
                        style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '(اضغط مطولاً على الدائرة للتحدث)',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 60),
              
              // الحقل النصي للتجربة (في حال عدم الرغبة بالتحدث)
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'أو اكتب أمرك هنا...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      context.read<VoiceAssistantCubit>().submitCommand(controller.text);
                      controller.clear();
                    },
                  ),
                ),
                onSubmitted: (value) {
                  context.read<VoiceAssistantCubit>().submitCommand(value);
                  controller.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}