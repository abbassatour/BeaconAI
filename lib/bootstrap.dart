// lib/bootstrap.dart

import 'dart:async';
import 'dart:developer';

import 'package:ai_agent_api/ai_agent_api.dart';
import 'package:assistant_repository/assistant_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:os_automation_api/os_automation_api.dart'; // هذا السطر جديد
import 'package:speech_api/speech_api.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function(AssistantRepository) builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  if (geminiApiKey.isEmpty) {
    throw Exception(
      'GEMINI_API_KEY is missing! Please run the app with --dart-define-from-file=.env',
    );
  }

  final aiClient = AiAgentClient(apiKey: geminiApiKey);
  final processManager = OsProcessManager();
  final keyboardController = KeyboardController();
  final ttsService = TtsService();
  final sttService = SttService();

  final repository = AssistantRepository(
    aiClient: aiClient,
    processManager: processManager,
    keyboardController: keyboardController,
    ttsService: ttsService,
    sttService: sttService,
  );

  runApp(await builder(repository));
}