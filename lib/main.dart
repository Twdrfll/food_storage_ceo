import 'package:flutter/material.dart';
import 'package:food_storage_ceo/screen/app_settings.dart';
import 'package:food_storage_ceo/screen/sort.dart';
import 'screen/login_signup.dart';
import 'screen/home.dart';
import 'config/app_theme.dart';
import 'screen/color_picker.dart';
import 'screen/sort.dart';
import 'fridge_state.dart';
import 'screen/add_element.dart';
import 'screen/first_color_picker.dart';
import 'screen/scan_barcode.dart';
import 'screen/dictionary_list.dart';
import './fridge_event.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ColorPickerModel(), child: MyApp()),
          ChangeNotifierProvider(create: (context) => SortModel(), child: MyApp()),
          ChangeNotifierProvider(create: (context) => AddElementModel(), child: MyApp()),
          ChangeNotifierProvider(create: (context) => DictionaryItemsModel(), child: MyApp()),
          ChangeNotifierProvider(create: (context) => AddNewElementToShoppingListModel(), child: MyApp()),
          ChangeNotifierProvider(create: (context) => TriggerUpdateModel(), child: MyApp()),
        ],
        child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TriggerUpdateModel>(
        builder: (context, triggerUpdateModel, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            home: LoginAndSignup(),
            theme: mainTheme,
            routes: {
              '/home': (context) => Home(),
              '/login': (context) => LoginAndSignup(),
              '/first_color_picker': (context) => FirstColorPicker(),
              '/add_element': (context) => AddElement(),
              '/scan_barcode': (context) => ScanBarcode(),
            },
          );
        }
    );
  }
}