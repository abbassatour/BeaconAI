// lib/bootstrap.dart

import 'dart:async';
import 'dart:developer';
import 'dart:io';

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
  // 1. تهيئة محرك Flutter
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // 2. محاولة قراءة المفتاح من الخيارات
  String apiKey = const String.fromEnvironment('OPENROUTER_API_KEY');

  // إذا لم يجد المفتاح عبر الـ Command Line، سيقرأ ملف .env مباشرة من المجلد
  if (apiKey.isEmpty) {
    try {
      final envFile = File('.env');
      if (envFile.existsSync()) {
        final lines = envFile.readAsLinesSync();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('OPENROUTER_API_KEY=')) {
            apiKey = trimmed.substring('OPENROUTER_API_KEY='.length).trim();
            break;
          } else if (trimmed.startsWith('GEMINI_API_KEY=')) {
            apiKey = trimmed.substring('GEMINI_API_KEY='.length).trim();
            break;
          }
        }
      }
    } catch (e) {
      log('لم نتمكن من قراءة ملف .env يدويًا: $e');
    }
  }

  // إذا ظل المفتاح فارغاً بعد كل المحاولات
  if (apiKey.isEmpty) {
    throw Exception(
      'لم يتم العثور على مفتاح الـ API! يرجي التأكد من وجود ملف .env ويحتوي على OPENROUTER_API_KEY',
    );
  }

  final aiClient = AiAgentClient(apiKey: apiKey);
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