import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './app_settings.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../fridge_state.dart';
import '../fridge_state.dart';

class ColorPickerScreen extends StatelessWidget {
  final String userColor;

  const ColorPickerScreen({Key? key, required this.userColor}) : super(key: key);

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  String colorToHex(Color color) {
    String hexColor = '#';
    return hexColor + color.value.toRadixString(16).substring(2, 8);
  }

  @override
  Widget build(BuildContext context) {
    final colorPickerModel = Provider.of<ColorPickerModel>(context, listen: false);
    final triggerUpdateModel = Provider.of<TriggerUpdateModel>(context, listen: false);
    var newColor = colorPickerModel.userColor;

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Scegli un colore',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.color_lens),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: hexToColor(userColor),
          onColorChanged: (color) {
            newColor = colorToHex(color);
          },
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () async {
            await colorPickerModel.setUserColor(newColor);
            print('ColorPickerScreen: ${colorPickerModel.userColor}');
            Navigator.of(context).pop(); // Chiude il dialog
          },
        ),
      ],
    );
  }
}

class ColorPickerModel extends ChangeNotifier {
  String _userColor = LocalFridge().user.color;

  String get userColor => _userColor;

  void setModelColor(String newColor) {
    _userColor = newColor;
  }

  Future<void> setUserColor(String newColor) async {
    _userColor = newColor;
    await LocalFridge().user.updateUserColor(newColor);
    print(LocalFridge().fridge_ID);
    await LocalFridge().setupFridge();
    notifyListeners();
  }
}