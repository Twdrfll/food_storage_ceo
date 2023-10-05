import 'package:flutter/material.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {

  bool button_value = false;
  bool agreement_value = false;
  bool password_visibility = false;
  bool confirm_password_visibility = false;
  Color button_color_enabled = Color(0xFF01689D);
  Color button_color_disabled = Color(0xFFC4C4C4);
  Color text_secondary_color = Color(0xFFAEA7A7);
  Color input_field_background = Color(0xFFF7F8F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}