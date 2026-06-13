import 'package:flutter/material.dart';

import 'config/supabase_config.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}