// lib/main_development.dart

import 'app/view/app.dart';
import 'bootstrap.dart';

void main() {
  bootstrap((repository) => App(assistantRepository: repository));
}