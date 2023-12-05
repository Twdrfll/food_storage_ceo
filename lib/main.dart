import 'package:flutter/material.dart';
import 'package:food_storage_ceo/screen/sort.dart';
import 'screen/login_signup.dart';
import 'screen/home.dart';
import 'config/app_theme.dart';
import 'screen/color_picker.dart';
import 'screen/sort.dart';
import 'fridge_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ColorPickerModel(), child: MyApp()),
          ChangeNotifierProvider(create: (context) => SortModel(), child: MyApp()),
        ],
        child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    LocalFridge().dispose();
    // LocalFridge().setupFridge();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: LoginAndSignup(),
      theme: mainTheme,
      routes: {
        '/home': (context) => Home(),
        '/login': (context) => LoginAndSignup(),
      },
    );
  }

}