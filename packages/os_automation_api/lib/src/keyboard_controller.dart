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

  /// محاكاة الضغط على مفتاحين معاً (مثل Ctrl + Key)
  void pressCombination(int modifier, int key) {
    final inputs = calloc<INPUT>(4);

    // 1. الضغط على المفتاح المساعد (مثل Ctrl)
    inputs[0].type = INPUT_KEYBOARD;
    inputs[0].ki.wVk = VIRTUAL_KEY(modifier);

    // 2. الضغط على المفتاح الرئيسي
    inputs[1].type = INPUT_KEYBOARD;
    inputs[1].ki.wVk = VIRTUAL_KEY(key);

    // 3. رفع المفتاح الرئيسي
    inputs[2].type = INPUT_KEYBOARD;
    inputs[2].ki.wVk = VIRTUAL_KEY(key);
    inputs[2].ki.dwFlags = KEYEVENTF_KEYUP;

    // 4. رفع المفتاح المساعد
    inputs[3].type = INPUT_KEYBOARD;
    inputs[3].ki.wVk = VIRTUAL_KEY(modifier);
    inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;

    SendInput(4, inputs, sizeOf<INPUT>());
    free(inputs);
  }

  /// فتح تبويب جديد (Ctrl + T)
  void pressCtrlT() => pressCombination(VK_CONTROL, 0x54); // 0x54 هو حرف T

  /// الانتقال لشريط العنوان في المتصفح (Ctrl + L)
  void pressCtrlL() => pressCombination(VK_CONTROL, 0x4C); // 0x4C هو حرف L

  /// دالة داخلية لإرسال أحرف النصوص باستخدام تقنية Unicode
  void _sendUnicodeChar(int charCode) {
    final inputs = calloc<INPUT>(2);

    // حدث ضغط الزر (Key Down)
    inputs[0].type = INPUT_KEYBOARD;
    inputs[0].ki.wScan = charCode;
    inputs[0].ki.dwFlags = KEYEVENTF_UNICODE;

    // حدث إفلات الزر (Key Up)
    inputs[1].type = INPUT_KEYBOARD;
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
    inputs[0].ki.wVk = VIRTUAL_KEY(keyCode);

    // Key Up
    inputs[1].type = INPUT_KEYBOARD;
    inputs[1].ki.wVk = VIRTUAL_KEY(keyCode);
    inputs[1].ki.dwFlags = KEYEVENTF_KEYUP;

    SendInput(2, inputs, sizeOf<INPUT>());
    free(inputs);
  }
}