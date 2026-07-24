// lib/bootstrap.dart

import 'dart:async';
import 'dart:developer';

import 'package:ai_agent_api/ai_agent_api.dart';
import 'package:assistant_repository/assistant_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:os_automation_api/os_automation_api.dart';
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

  // إعداد كل الـ APIs والمستودع قبل تشغيل التطبيق باستخدام المفتاح الخاص بك
  final aiClient = AiAgentClient(apiKey: 'AIzaSyAm-OSoQuq6TmIHmrs8RuBn42hrON8UdDE');
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