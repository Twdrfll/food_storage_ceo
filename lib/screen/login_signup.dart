import 'package:flutter/material.dart';

class loginAndSignup extends StatefulWidget {
  const loginAndSignup({super.key});

  _loginAndSignupState createState() => _loginAndSignupState();
}

class _loginAndSignupState extends State<loginAndSignup> {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  // Welcome
                  child: Padding(
                    padding: const EdgeInsets.only(top: 150.0),
                    child: Text(
                      'Benvenut*!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const Center(
                  // Title
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Entra in The Fridge',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  // Choice
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                button_value
                                    ? button_color_enabled
                                    : button_color_disabled),
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(120.0, 46.0)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(23.0),
                                      bottomLeft: Radius.circular(23.0))),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              button_value = true;
                            });
                          },
                          child: Row(
                            children: [
                              ClipRect(
                                child: SizedBox(
                                  width: 120.0,
                                  child: AnimatedCrossFade(
                                    firstChild: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    secondChild: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Icon(Icons.check),
                                        ),
                                        Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    crossFadeState: button_value
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 0.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                button_value
                                    ? button_color_disabled
                                    : button_color_enabled),
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(120.0, 46.0)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(23.0),
                                      bottomRight: Radius.circular(23.0))),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              button_value = false;
                            });
                          },
                          child: Row(
                            children: [
                              ClipRect(
                                child: SizedBox(
                                  width: 120.0,
                                  child: AnimatedCrossFade(
                                    firstChild: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Log In',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    secondChild: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Icon(Icons.check),
                                        ),
                                        Text(
                                          'Log In',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    crossFadeState: button_value
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Column(
                    children: [
                      Padding(
                        // Email
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 20.0, right: 20.0),
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFf7f8f8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide:
                                    BorderSide(color: input_field_background)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide:
                                    BorderSide(color: input_field_background)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide:
                                    BorderSide(color: input_field_background)),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            prefixIcon: Icon(Icons.email_outlined),
                            prefixIconColor: MaterialStateColor.resolveWith(
                                (states) =>
                                    states.contains(MaterialState.focused)
                                        ? button_color_enabled
                                        : Colors.grey),
                          ),
                        ),
                      ),
                      Padding(
                        // Password
                        padding:
                            EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                        child: TextField(
                          obscureText: !password_visibility,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFFf7f8f8),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide(
                                      color: input_field_background)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide(
                                      color: input_field_background)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide(
                                      color: input_field_background)),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              prefixIcon: Icon(Icons.lock_outline),
                              prefixIconColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      states.contains(MaterialState.focused)
                                          ? button_color_enabled
                                          : Colors.grey),
                              suffixIcon: IconButton(
                                  icon: Icon(password_visibility
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  onPressed: () {
                                    setState(() {
                                      password_visibility =
                                          !password_visibility;
                                    });
                                  }),
                              suffixIconColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      states.contains(MaterialState.focused)
                                          ? button_color_enabled
                                          : Colors.grey)),
                        ),
                      ),
                      Padding(
                        // Confirm Password
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 20.0, right: 20.0),
                        child: AnimatedOpacity(
                          opacity: button_value ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            children: [
                              TextField(
                                obscureText: !confirm_password_visibility,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Color(0xFFf7f8f8),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide(
                                            color: input_field_background)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide(
                                            color: input_field_background)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide(
                                            color: input_field_background)),
                                    labelText: 'Conferma password',
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    prefixIcon: Icon(Icons.lock_outline),
                                    prefixIconColor:
                                        MaterialStateColor.resolveWith((states) =>
                                            states.contains(MaterialState.focused)
                                                ? button_color_enabled
                                                : Colors.grey),
                                    suffixIcon: IconButton(
                                        icon: Icon(confirm_password_visibility
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () {
                                          setState(() {
                                            confirm_password_visibility =
                                                !confirm_password_visibility;
                                          });
                                        }),
                                    suffixIconColor:
                                        MaterialStateColor.resolveWith((states) =>
                                            states.contains(MaterialState.focused)
                                                ? button_color_enabled
                                                : Colors.grey)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: button_color_enabled,
                                      value: agreement_value,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      onChanged: (bool? value) {
                                        if (value != null) {
                                          setState(() {
                                            agreement_value = value;
                                          });
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      width: 300.0,
                                      child: Text(
                                        'Continuando, accetti la nostra Politica sulla Privacy e i nostri Termini d\'uso.',
                                        style: TextStyle(
                                          color: text_secondary_color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding( // Button Avanti
            padding: const EdgeInsets.only(bottom: 90.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(button_color_enabled),
                minimumSize: MaterialStateProperty.all<Size>(Size(350.0, 72.0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(36.0))),
                ),
              ),
              onPressed: () {},
              child: Text(
                'Avanti',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
