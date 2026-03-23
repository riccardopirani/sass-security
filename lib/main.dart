import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/localization/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = await LocaleController.load();
  String? backendError;
  var backendReady = false;

  if (Env.hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
      backendReady = true;
    } catch (error) {
      backendError = error.toString();
    }
  }

  runApp(
    CyberGuardApp(
      localeController: localeController,
      backendReady: backendReady,
      backendError: backendError,
    ),
  );
}
