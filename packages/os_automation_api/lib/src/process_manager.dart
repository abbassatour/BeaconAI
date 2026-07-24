// packages/os_automation_api/lib/src/process_manager.dart

import 'dart:io';

class OsProcessManager {
  /// يفتح برنامجاً معيناً موجوداً في النظام (مثل: notepad, msedge, calc)
  Future<void> launchApp(String executableName, {List<String> arguments = const []}) async {
    try {
      // نستخدم runInShell لكي يتعرف النظام على مسارات البرامج الافتراضية
      await Process.start(executableName, arguments, runInShell: true);
    } catch (e) {
      throw Exception('فشل في تشغيل البرنامج: $executableName. التفاصيل: $e');
    }
  }

  /// يفتح موقعاً إلكترونياً باستخدام المتصفح الافتراضي للنظام
  Future<void> openUrl(String url) async {
    try {
      // أمر 'start' في ويندوز يقوم بفتح الروابط بالمتصفح الافتراضي
      await Process.run('cmd', ['/c', 'start', url], runInShell: true);
    } catch (e) {
      throw Exception('فشل في فتح الرابط: $url');
    }
  }
}