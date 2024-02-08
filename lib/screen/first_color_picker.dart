import 'package:flutter/material.dart';
import 'dart:math';
import '../fridge_state.dart';
import 'home.dart';

class FirstColorPicker extends StatefulWidget {
  const FirstColorPicker({Key? key}) : super(key: key);

  @override
  _FirstColorPickerState createState() => _FirstColorPickerState();
}

class _FirstColorPickerState extends State<FirstColorPicker> {

  Color userColor = Colors.grey;
  bool userColorSelected = false;

  hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  colorToHex(Color color) {
    String hexColor = '#';
    return hexColor + color.value.toRadixString(16).substring(2, 8);
  }

  Future<void> setFirstUserColor() async {
    await LocalFridge().user.updateUserColor(colorToHex(userColor));
    Navigator.pushReplacementNamed(context, '/home').then((value) {
      LocalFridge().setupFridge();
    });
  }

  @override initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Scegli il tuo colore utente',
                    style: TextStyle(
                      fontSize: theme.textTheme.titleLarge!.fontSize,
                      fontWeight: theme.textTheme.titleLarge!.fontWeight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Ti aiuterà a distinguerti da chi utilizzerà il tuo stesso frigo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: theme.textTheme.labelMedium!.fontSize,
                      fontWeight: theme.textTheme.labelMedium!.fontWeight,
                    ),
                  ),
                ),
              ],
            ),
            CircularWidget(
              radius: 130.0,
              centerWidget: Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: userColor,
                ),
                child: Icon(
                  Icons.color_lens_outlined,
                  size: 100.0,
                  color: Colors.white,
                ),
              ),
              children: <Widget>[
                CircleColor(
                    color: Colors.red,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.green,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.blue,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.yellow,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.purple,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.orange,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.pink,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.teal,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.brown,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.cyan,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.indigo,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
                CircleColor(
                    color: Colors.lime,
                    actualColor: userColor,
                    onPressed: (color) {
                      setState(() {
                        userColor = color;
                        userColorSelected = true;
                      });
                    },
                ),
              ],
            ),
            Text(
              'Non temere! Se non sarai soddisfatto del tuo colore, potrai cambiarlo in seguito dal tuo profilo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: theme.textTheme.labelSmall!.fontSize,
                fontWeight: theme.textTheme.labelSmall!.fontWeight,
                color: theme.colorScheme.secondary,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (userColorSelected) {
                  await setFirstUserColor();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Scegli un colore o resterai tristemente grigio!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                minimumSize: Size(350.0, 72.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36.0),
                ),
              ),
              child: Text(
                'Conferma',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircleColor extends StatelessWidget {
  final Color color;
  final Function(Color) onPressed;
  final Color actualColor;

  const CircleColor({Key? key, required this.color, required this.actualColor, required this.onPressed}) : super(key: key);

  CircleBorder circleBorderShaper() {
    print(actualColor == color);
    if (actualColor == color) {
      return const CircleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 5.0,
        ),
      );
    } else {
      return CircleBorder();
    }
  }

  Widget selectedColor() {
    if (actualColor == color) {
      return Container(
        width: 50.0,
        height: 50.0,
        child: Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.check,
            size: 30.0,
            color: Colors.black,
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      height: 50.0,
      child: ElevatedButton(
        onPressed: () {
          onPressed(color);
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(0.0),
          shape: circleBorderShaper(),
          backgroundColor: color,
        ),
        child: selectedColor(),
      ),
    );
  }
}

class CircularWidget extends StatelessWidget {
  final List<Widget> children;
  final double radius;
  final Widget centerWidget;

  CircularWidget({
    required this.children,
    required this.radius,
    required this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: radius * 2 + 100,
        height: radius * 2 + 100,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            for (int i = 0; i < children.length; i++)
              Positioned(
                left: radius * cos(2 * pi * (i / children.length)) +
                    radius + 25, // Aggiustamento per centrare il cerchio
                top: radius * sin(2 * pi * (i / children.length)) +
                    radius + 25, // Aggiustamento per centrare il cerchio
                child: children[i],
              ),
            centerWidget,
          ],
        ),
      ),
    );
  }
}
