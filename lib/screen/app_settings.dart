import 'package:flutter/material.dart';
import 'package:food_storage_ceo/screen/color_picker.dart';
import '../fridge_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Settings extends StatelessWidget {
  late String userColor = local_fridge.user.color;
  final LocalFridge local_fridge;
  final LocalDictionary local_dictionary;
  final LocalShoppingCart local_shopping_cart;

  Settings(
      {
        Key? key,
        required this.local_fridge,
        required this.local_dictionary,
        required this.local_shopping_cart
      }) : super(key: key);

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  String colorToHex(Color color) {
    String hexColor = '#';
    return hexColor + color.value.toRadixString(16).substring(2, 8);
  }

  void logoutAndReturnToLogin(BuildContext context) async {
    await local_fridge.user.removeLocalData();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    List<Widget> SettingsListItems = [
      Padding( // Icona colora e dati utente
        padding: const EdgeInsets.only(top: 30.0, bottom: 30.0, left: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Icon(
                Icons.account_circle,
                size: 120.0,
                color: hexToColor(userColor),
              ),
            ),
            Column(
              children: [
                Text(
                  "Ciao " + local_fridge.user.email + "!",
                  style: TextStyle(
                    fontSize: theme.textTheme.titleMedium!.fontSize,
                    fontWeight: theme.textTheme.titleMedium!.fontWeight,
                  ),
                ),
                Text(
                  "Il tuo attuale colore è " + userColor,
                  style: TextStyle(
                    fontSize: theme.textTheme.labelSmall!.fontSize,
                    fontWeight: theme.textTheme.labelSmall!.fontWeight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            "Impostazioni",
            style: TextStyle(
              fontSize: theme.textTheme.titleLarge!.fontSize,
              fontWeight: theme.textTheme.titleLarge!.fontWeight,
            ),
          ),
        ),
      ),
      FridgeChangeWidgetContainer( showErrorFridge: (BuildContext context) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il cambio di dispensa'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }),
      NotificationSettingsWidget(),
      CameraSettingsWidget(),
      Padding( // Bottone logout
        padding: const EdgeInsets.only(bottom: 120.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton( // Logout e ritorno alla pagina di login
            onPressed: () => logoutAndReturnToLogin(context),
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all<Color>(theme.colorScheme.primary),
              minimumSize: MaterialStateProperty.all<Size>(Size(350.0, 72.0)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(36.0))),
              ),
            ),
            child: Text(
              "Logout",
              style: TextStyle(
                fontSize: theme.textTheme.labelLarge!.fontSize,
                fontWeight: theme.textTheme.labelLarge!.fontWeight,
                color: theme.textTheme.labelLarge!.color,
              ),
            ),
          ),
        ),
      )
    ];

    return Consumer<ColorPickerModel>(
      builder: (context, colorPickerModel, child) {
        this.userColor = colorPickerModel.userColor;
        return Container(
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Lista impostazioni
                  child: SettingsList(SettingsListItems, hexToColor(colorPickerModel.userColor)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SettingsList extends StatelessWidget {
  final List<Widget> items;
  final Color userColor;

  SettingsList(this.items, this.userColor);

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: items[index],
        );
      },
    );
  }
}

class FridgeChangeWidget extends StatefulWidget {
  final Function(BuildContext) showErrorFridge;

  const FridgeChangeWidget({Key? key, required this.showErrorFridge}) : super(key: key);
  @override
  _FridgeChangeWidgetState createState() => _FridgeChangeWidgetState();

}

class _FridgeChangeWidgetState extends State<FridgeChangeWidget> {
  late LocalFridge local_fridge;

  void initState() {
    super.initState();
    local_fridge = LocalFridge();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
            "La tua attuale dispensa è: " + local_fridge.user.fridgeID,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Center(
            child: ElevatedButton(
                onPressed: () {
                  final TextEditingController textController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ID del frigo',
                                style: TextStyle(
                                  fontSize: theme.textTheme.titleLarge!.fontSize,
                                  fontWeight: theme.textTheme.titleLarge!.fontWeight,
                                )
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.edit),
                              ),
                            ],
                          )
                        ),
                        content: TextField(
                          controller: textController,
                          decoration: InputDecoration(hintText: 'Nuovo ID del frigo'),
                        ),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                child: Text('Annulla'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }
                              ),
                              TextButton(
                                child: Text('Conferma'),
                                onPressed: () async {
                                  bool result = await local_fridge.user.changeUserFridge(textController.text);
                                  local_fridge.fridge_ID = textController.text;
                                  local_fridge.setupFridge();
                                  local_fridge.user.saveLocalData();
                                  if (!result) {
                                    widget.showErrorFridge(context);
                                  } else {
                                    setState(() {});
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(theme.colorScheme.primary),
                  minimumSize: MaterialStateProperty.all<Size>(Size(200.0, 42.0)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(36.0))),
                  ),
                ),
                child: Text(
                    "Cambia dispensa",
                    style: TextStyle(
                      fontSize: theme.textTheme.labelLarge!.fontSize,
                      fontWeight: theme.textTheme.labelLarge!.fontWeight,
                      color: theme.textTheme.labelLarge!.color,
                    ),
                )
            ),
          ),
        ),
      ],
    );
  }
}

class FridgeChangeWidgetContainer extends StatelessWidget {
  final Function(BuildContext) showErrorFridge;

  const FridgeChangeWidgetContainer({Key? key, required this.showErrorFridge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ExpansionTile(
      backgroundColor: theme.colorScheme.tertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        'Dispensa',
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
          fontWeight: Theme.of(context).textTheme.titleMedium!.fontWeight,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FridgeChangeWidget(showErrorFridge: showErrorFridge),
        ),
      ],
    );
  }
}

class NotificationSettingsWidget extends StatefulWidget {

  @override
  _NotificationSettingsWidgetState createState() => _NotificationSettingsWidgetState();

}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget> {

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // pannello che si espande e mostra le impostazioni di notifica
    return ExpansionTile(
      backgroundColor: theme.colorScheme.tertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        'Notifiche',
        style: TextStyle(
          fontSize: theme.textTheme.titleMedium!.fontSize,
          fontWeight: theme.textTheme.titleMedium!.fontWeight,
        ),
      ),
      children: [
        // tre radio buttons, uno per ogni opzione di notifica
        ListTile(
          title: const Text('Consenti'),
          leading: Radio(
            value: 0,
            groupValue: _selectedIndex,
            onChanged: (int? value) {
              setState(() {
                _selectedIndex = value!;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Silenziose'),
          leading: Radio(
            value: 1,
            groupValue: _selectedIndex,
            onChanged: (int? value) {
              setState(() {
                _selectedIndex = value!;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Non consentire'),
          leading: Radio(
            value: 2,
            groupValue: _selectedIndex,
            onChanged: (int? value) {
              setState(() {
                _selectedIndex = value!;
              });
            },
          ),
        ),
      ],
    );
  }

}

class CameraSettingsWidget extends StatefulWidget {

  @override
  _CameraSettingsWidgetState createState() => _CameraSettingsWidgetState();

}

class _CameraSettingsWidgetState extends State<CameraSettingsWidget> {

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // pannello che si espande e mostra le impostazioni di notifica
    return ExpansionTile(
      backgroundColor: theme.colorScheme.tertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        'Fotocamera',
        style: TextStyle(
          fontSize: theme.textTheme.titleMedium!.fontSize,
          fontWeight: theme.textTheme.titleMedium!.fontWeight,
        ),
      ),
      children: [
        // tre radio buttons, uno per ogni opzione di notifica
        ListTile(
          title: const Text('Consenti l\'uso'),
          leading: Radio(
            value: 0,
            groupValue: _selectedIndex,
            onChanged: (int? value) {
              setState(() {
                _selectedIndex = value!;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Non consentire'),
          leading: Radio(
            value: 1,
            groupValue: _selectedIndex,
            onChanged: (int? value) {
              setState(() {
                _selectedIndex = value!;
              });
            },
          ),
        ),
      ],
    );
  }

}