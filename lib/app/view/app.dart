// lib/app/view/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assistant_repository/assistant_repository.dart';
import '../../voice_assistant/cubit/voice_assistant_cubit.dart';
import '../../voice_assistant/view/voice_assistant_page.dart';

class App extends StatelessWidget {
  const App({required this.assistantRepository, super.key});

  final AssistantRepository assistantRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: assistantRepository,
      child: BlocProvider(
        create: (context) => VoiceAssistantCubit(repository: assistantRepository),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: VoiceAssistantPage(),
        ),
      ),
    );
  }
}