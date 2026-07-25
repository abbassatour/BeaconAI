// lib/main_production.dart

import 'package:temp_app/app/app.dart';
import 'package:temp_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap((repository) => App(assistantRepository: repository));
}