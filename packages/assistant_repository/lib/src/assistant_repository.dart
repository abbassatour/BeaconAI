// packages/assistant_repository/lib/src/assistant_repository.dart

import 'package:ai_agent_api/ai_agent_api.dart';
import 'package:os_automation_api/os_automation_api.dart';
import 'package:speech_api/speech_api.dart';

class AssistantRepository {
  AssistantRepository({
    required AiAgentClient aiClient,
    required OsProcessManager processManager,
    required KeyboardController keyboardController,
    required TtsService ttsService,
    required SttService sttService,
  })  : _aiClient = aiClient,
        _processManager = processManager,
        _keyboardController = keyboardController,
        _ttsService = ttsService,
        _sttService = sttService;

  final AiAgentClient _aiClient;
  final OsProcessManager _processManager;
  final KeyboardController _keyboardController;
  final TtsService _ttsService;
  final SttService _sttService;

  /// دالة التحدث مع المستخدم
  Future<void> speak(String text) async {
    await _ttsService.speak(text);
  }

  /// الدالة الرئيسية التي تأخذ طلب المستخدم (كنص حالياً) وتنفذه بالكامل
  Future<void> executeTextCommand(String command) async {
    try {
      // 1. إخبار المستخدم أننا نفكر
      await speak('جاري تنفيذ طلبك، لحظات من فضلك.');

      // 2. إرسال الطلب للدماغ (Gemini AI)
      final actions = await _aiClient.processUserCommand(command);

      // 3. تنفيذ الأفعال بالترتيب (اليدين)
      for (final action in actions) {
        await _executeAction(action);
        // تأخير بسيط بين كل حركة وأخرى لكي يستوعب نظام التشغيل
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // 4. إخبار المستخدم بنجاح المهمة
      await speak('تم التنفيذ بنجاح.');

    } catch (e) {
      await speak('عذراً، واجهت مشكلة أثناء التنفيذ.');
      print('Error executing command: $e');
    }
  }

  /// دالة داخلية لترجمة أمر الذكاء الاصطناعي إلى حركة فعلية على الويندوز
  Future<void> _executeAction(AgentAction action) async {
    switch (action.type) {
      case ActionType.openApp:
        final appName = action.parameters['app_name'] as String?;
        if (appName != null) {
          await _processManager.launchApp(appName);
          // ننتظر قليلاً حتى يفتح البرنامج
          await Future.delayed(const Duration(seconds: 2));
        }
        break;

      case ActionType.typeText:
        final text = action.parameters['text'] as String?;
        if (text != null) {
          _keyboardController.typeText(text);
        }
        break;

      case ActionType.pressKey:
        final keyName = (action.parameters['key_name'] as String?)?.toLowerCase();
        if (keyName == 'enter') {
          _keyboardController.pressEnter();
        } else if (keyName == 'tab') {
          _keyboardController.pressTab();
        } else if (keyName == 'windows') {
          _keyboardController.pressWindowsKey();
        }
        break;

      case ActionType.unknown:
      default:
        print('إجراء غير معروف: ${action.parameters}');
    }
  }
}