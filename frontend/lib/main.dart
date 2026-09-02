import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/ai_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AiConfig().initialize();

  runApp(
    const ProviderScope(
      child: ShilpSetuApp(),
    ),
  );
}
