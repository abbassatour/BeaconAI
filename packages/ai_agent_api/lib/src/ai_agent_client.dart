// packages/ai_agent_api/lib/src/ai_agent_client.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import 'models/agent_action.dart';

class AiAgentClient {
  AiAgentClient({required String apiKey}) {
    // إعداد النموذج مع تعريف الأدوات التي يمكنه استخدامها
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      tools: [_buildTools()],
      systemInstruction: Content.system(
        'أنت مساعد ذكي مخصص لمساعدة المكفوفين وضعاف البصر في استخدام نظام ويندوز. '
        'مهمتك هي تحليل طلب المستخدم واستخدام الأدوات (Tools) المتاحة لك لتنفيذ المهام المطلوبة خطوة بخطوة. '
        'لا تقم بالشرح الطويل، فقط نفذ الأدوات المناسبة بالترتيب.',
      ),
    );
  }

  late final GenerativeModel _model;

  /// تعريف الأدوات (Functions) التي سنرسلها للذكاء الاصطناعي
  static Tool _buildTools() {
    return Tool(functionDeclarations: [
      FunctionDeclaration(
        'open_app',
        'يفتح برنامجاً أو تطبيقاً على اللابتوب.',
        Schema(SchemaType.object, properties: {
          'app_name': Schema(SchemaType.string, description: 'اسم البرنامج بالإنجليزية (مثل notepad, msedge, calc)'),
        }, requiredProperties: ['app_name']),
      ),
      FunctionDeclaration(
        'type_text',
        'يكتب نصاً باستخدام لوحة المفاتيح.',
        Schema(SchemaType.object, properties: {
          'text': Schema(SchemaType.string, description: 'النص المراد كتابته'),
        }, requiredProperties: ['text']),
      ),
      FunctionDeclaration(
        'press_key',
        'يضغط على زر معين في لوحة المفاتيح.',
        Schema(SchemaType.object, properties: {
          'key_name': Schema(SchemaType.string, description: 'اسم الزر (مثل: enter, tab, windows)'),
        }, requiredProperties: ['key_name']),
      ),
    ]);
  }

  /// إرسال أمر المستخدم للذكاء الاصطناعي واستقبال قائمة الأفعال (Actions)
  Future<List<AgentAction>> processUserCommand(String prompt) async {
    final chat = _model.startChat();
    final response = await chat.sendMessage(Content.text(prompt));

    final actions = <AgentAction>[];

    // التحقق مما إذا كان النموذج قرر استدعاء أدوات معينة
    final functionCalls = response.functionCalls.toList();
    
    for (final call in functionCalls) {
      switch (call.name) {
        case 'open_app':
          actions.add(AgentAction(
            type: ActionType.openApp,
            parameters: call.args,
          ));
          break;
        case 'type_text':
          actions.add(AgentAction(
            type: ActionType.typeText,
            parameters: call.args,
          ));
          break;
        case 'press_key':
          actions.add(AgentAction(
            type: ActionType.pressKey,
            parameters: call.args,
          ));
          break;
        default:
          actions.add(AgentAction(
            type: ActionType.unknown,
            parameters: call.args,
          ));
      }
    }

    return actions;
  }
}