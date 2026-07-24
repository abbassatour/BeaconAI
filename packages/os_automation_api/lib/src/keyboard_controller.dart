// packages/os_automation_api/lib/src/keyboard_controller.dart

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class KeyboardController {
  /// محاكاة كتابة نص كامل (يدعم العربية والإنجليزية)
  void typeText(String text) {
    for (var i = 0; i < text.length; i++) {
      final charCode = text.codeUnitAt(i);
      _sendUnicodeChar(charCode);
    }
  }

  /// محاكاة الضغط على زر الإدخال (Enter)
  void pressEnter() {
    _sendVirtualKey(VK_RETURN);
  }

  /// محاكاة الضغط على زر المسافة (Tab)
  void pressTab() {
    _sendVirtualKey(VK_TAB);
  }
  
  /// محاكاة الضغط على زر الويندوز (Windows Key)
  void pressWindowsKey() {
    _sendVirtualKey(VK_LWIN);
  }

  /// دالة داخلية لإرسال أحرف النصوص باستخدام تقنية Unicode
  void _sendUnicodeChar(int charCode) {
    final inputs = calloc<INPUT>(2);

    // حدث ضغط الزر (Key Down)
    inputs[0].type = INPUT_KEYBOARD;
    inputs[0].ki.wVk = 0;
    inputs[0].ki.wScan = charCode;
    inputs[0].ki.dwFlags = KEYEVENTF_UNICODE;

    // حدث إفلات الزر (Key Up)
    inputs[1].type = INPUT_KEYBOARD;
    inputs[1].ki.wVk = 0;
    inputs[1].ki.wScan = charCode;
    inputs[1].ki.dwFlags = KEYEVENTF_UNICODE | KEYEVENTF_KEYUP;

    SendInput(2, inputs, sizeOf<INPUT>());
    free(inputs);
  }

  /// دالة داخلية للضغط على أزرار النظام (Virtual Keys)
  void _sendVirtualKey(int keyCode) {
    final inputs = calloc<INPUT>(2);

    // Key Down
    inputs[0].type = INPUT_KEYBOARD;
    inputs[0].ki.wVk = keyCode;
    inputs[0].ki.wScan = 0;
    inputs[0].ki.dwFlags = 0;

    // Key Up
    inputs[1].type = INPUT_KEYBOARD;
    inputs[1].ki.wVk = keyCode;
    inputs[1].ki.wScan = 0;
    inputs[1].ki.dwFlags = KEYEVENTF_KEYUP;

    SendInput(2, inputs, sizeOf<INPUT>());
    free(inputs);
  }
}