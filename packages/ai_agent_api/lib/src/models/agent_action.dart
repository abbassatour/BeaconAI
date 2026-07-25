// packages/ai_agent_api/lib/src/models/agent_action.dart

/// أنواع الأوامر التي يمكن للذكاء الاصطناعي تنفيذها على اللابتوب
enum ActionType {
  openApp,
  openUrl, // 👈 أضف هذا
  typeText,
  pressKey,
  unknown
}

/// الكائن الذي يمثل الفعل النهائي الذي سيفهمه التطبيق
class AgentAction {
  const AgentAction({
    required this.type,
    required this.parameters,
  });

  final ActionType type;
  final Map<String, dynamic> parameters;

  @override
  String toString() => 'AgentAction(type: $type, parameters: $parameters)';
}