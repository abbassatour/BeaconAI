// packages/ai_agent_api/lib/src/ai_agent_client.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'models/agent_action.dart';

class AiAgentClient {
  AiAgentClient({
    required String apiKey,
    this.model = 'google/gemini-3.5-flash',
  }) : _apiKey = apiKey;

  final String _apiKey;
  final String model;

  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  /// إرسال أمر نصي إلى OpenRouter مع الأدوات المتاحة
  Future<List<AgentAction>> processUserCommand(String prompt) async {
    final body = {
      'model': model,
      'max_tokens': 1000,
      'messages': [
        {
          'role': 'system',
          'content':
              'أنت مساعد ذكي مخصص لمساعدة المكفوفين وضعاف البصر في استخدام نظام ويندوز. '
              'مهمتك هي تحليل طلب المستخدم واستخدام الأدوات (Tools) المتاحة لك لتنفيذ المهام المطلوبة خطوة بخطوة. '
              'لا تقم بالشرح الطويل، فقط نفذ الأدوات المناسبة بالترتيب.',
        },
        {'role': 'user', 'content': prompt}
      ],
      'tools': _buildTools(),
      'tool_choice': 'auto',
    };

    return _sendRequest(body);
  }

  /// إرسال تسجيل صوتي إلى OpenRouter
  Future<List<AgentAction>> processAudioCommand(String audioPath) async {
    final audioBytes = await File(audioPath).readAsBytes();
    final base64Audio = base64Encode(audioBytes);

    final body = {
      'model': model,
      'max_tokens': 1000,
      'messages': [
        {
          'role': 'system',
          'content':
              'أنت مساعد ذكي مخصص لمساعدة المكفوفين وضعاف البصر في استخدام نظام ويندوز. '
              'استمع إلى هذا التسجيل الصوتي واستخدم الأدوات المناسبة لتنفيذ الأمر المطلوب.',
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'استمع للأمر واستخرج الأدوات المناسبة لتنفيذه:'
            },
            {
              'type': 'input_audio',
              'input_audio': {
                'data': base64Audio,
                'format': 'm4a',
              }
            }
          ]
        }
      ],
      'tools': _buildTools(),
      'tool_choice': 'auto',
    };

    return _sendRequest(body);
  }

  /// إرسال الطلب وإعادة قائمة الأفعال (AgentActions)
  Future<List<AgentAction>> _sendRequest(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://beaconai.app',
        'X-Title': 'BeaconAI Desktop',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenRouter API Error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;

    if (choices == null || choices.isEmpty) {
      return [];
    }

    final message = choices.first['message'] as Map<String, dynamic>;
    final toolCalls = message['tool_calls'] as List<dynamic>?;

    final actions = <AgentAction>[];

    if (toolCalls != null) {
      for (final call in toolCalls) {
        final function = call['function'] as Map<String, dynamic>;
        final name = function['name'] as String;
        final argsString = function['arguments'] as String;
        final args = jsonDecode(argsString) as Map<String, dynamic>;

        switch (name) {
          case 'open_app':
            actions.add(AgentAction(type: ActionType.openApp, parameters: args));
            break;
          case 'open_url':
            actions.add(AgentAction(type: ActionType.openUrl, parameters: args));
            break;
          case 'type_text':
            actions.add(AgentAction(type: ActionType.typeText, parameters: args));
            break;
          case 'press_key':
            actions.add(AgentAction(type: ActionType.pressKey, parameters: args));
            break;
          default:
            actions.add(AgentAction(type: ActionType.unknown, parameters: args));
        }
      }
    }

    return actions;
  }

  /// تعريف الأدوات بصيغة OpenRouter / OpenAI Standard Tools
  List<Map<String, dynamic>> _buildTools() {
    return [
      {
        'type': 'function',
        'function': {
          'name': 'open_app',
          'description': 'يفتح برنامجاً أو تطبيقاً على اللابتوب.',
          'parameters': {
            'type': 'object',
            'properties': {
              'app_name': {
                'type': 'string',
                'description': 'اسم البرنامج بالإنجليزية (مثل notepad, msedge, calc)'
              }
            },
            'required': ['app_name']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'open_url',
          'description': 'يفتح رابطاً أو موقعاً إلكترونياً في المتصفح الافتراضي.',
          'parameters': {
            'type': 'object',
            'properties': {
              'url': {
                'type': 'string',
                'description': 'الرابط الكامل للموقع (مثل https://youtube.com أو https://google.com)'
              }
            },
            'required': ['url']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'type_text',
          'description': 'يكتب نصاً باستخدام لوحة المفاتيح.',
          'parameters': {
            'type': 'object',
            'properties': {
              'text': {
                'type': 'string',
                'description': 'النص المراد كتابته'
              }
            },
            'required': ['text']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'press_key',
          'description': 'يضغط على زر معين في لوحة المفاتيح.',
          'parameters': {
            'type': 'object',
            'properties': {
              'key_name': {
                'type': 'string',
                'description': 'اسم الزر (مثل: enter, tab, windows)'
              }
            },
            'required': ['key_name']
          }
        }
      }
    ];
  }
}