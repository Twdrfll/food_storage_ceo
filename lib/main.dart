import 'package:flutter/material.dart';
import 'screen/login_signup.dart';
import 'screen/user_settings.dart';
import 'config/app_theme.dart';
import 'fridge_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: LoginAndSignup(),
      theme: mainTheme,
      routes: {
        '/user_settings': (context) => UserSettings(), // Definisci qui la tua schermata UserSettings
      },
    );
  }

}