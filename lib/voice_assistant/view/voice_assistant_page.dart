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
      backgroundColor: Colors.black, // خلفية داكنة مريحة للعين
      appBar: AppBar(
        title: const Text('BeaconAI - المساعد الذكي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // مؤشر الحالة (يتغير لونه وشكله حسب حالة المساعد)
              BlocBuilder<VoiceAssistantCubit, VoiceAssistantState>(
                builder: (context, state) {
                  IconData icon;
                  Color color;
                  String text;

                  switch (state.status) {
                    case AssistantStatus.idle:
                      icon = Icons.mic_none;
                      color = Colors.grey;
                      text = 'في انتظارك...';
                      break;
                    case AssistantStatus.listening:
                      icon = Icons.mic;
                      color = Colors.blue;
                      text = 'يستمع الآن...';
                      break;
                    case AssistantStatus.thinking:
                      icon = Icons.memory;
                      color = Colors.orange;
                      text = 'يفكر...';
                      break;
                    case AssistantStatus.executing:
                      icon = Icons.settings_applications;
                      color = Colors.green;
                      text = 'ينفذ المهمة...';
                      break;
                    case AssistantStatus.speaking:
                      icon = Icons.volume_up;
                      color = Colors.purple;
                      text = 'يتحدث...';
                      break;
                    case AssistantStatus.error:
                      icon = Icons.error_outline;
                      color = Colors.red;
                      text = 'حدث خطأ!';
                      break;
                  }

                  return Column(
                    children: [
                      Icon(icon, size: 100, color: color),
                      const SizedBox(height: 16),
                      Text(
                        text,
                        style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 50),
              
              // حقل نصي لتجربة الأوامر (مثل: افتح المفكرة واكتب مرحبا)
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'اكتب أمرك هنا للتجربة...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (value) {
                  context.read<VoiceAssistantCubit>().submitCommand(value);
                  controller.clear();
                },
              ),
              const SizedBox(height: 16),
              
              // أزرار التحكم
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<VoiceAssistantCubit>().submitCommand(controller.text);
                      controller.clear();
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('إرسال الأمر'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<VoiceAssistantCubit>().testSpeech('مرحباً، أنا المساعد بيكن، كيف يمكنني مساعدتك اليوم؟');
                    },
                    icon: const Icon(Icons.speaker),
                    label: const Text('تجربة النطق'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}