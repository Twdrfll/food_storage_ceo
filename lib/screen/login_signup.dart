import 'package:flutter/material.dart';
import 'home.dart';
import '../fridge_state.dart';

class LoginAndSignup extends StatefulWidget {
  const LoginAndSignup({super.key});

  _LoginAndSignupState createState() => _LoginAndSignupState();

}

class _LoginAndSignupState extends State<LoginAndSignup> {

  late LocalFridge local_fridge;
  late LocalDictionary local_dictionary;
  late LocalShoppingCart local_shopping_cart;
  bool button_value = false;
  bool agreement_value = false;
  bool password_visibility = false;
  bool confirm_password_visibility = false;

  final emailInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  final confirmPasswordInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    local_fridge = LocalFridge();
    local_dictionary = LocalDictionary();
    local_shopping_cart = LocalShoppingCart();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await local_fridge.user.retrieveSavedData();
    if (_checkLocalDataPresence()) {
      await _login_no_textfields();
      local_fridge.dispose();
      print(local_fridge.user.email);
      print(local_fridge.user.password);
      local_fridge.fridge_ID = local_fridge.user.fridgeID;
    }
  }

  bool _isSignup() {
    return button_value;
  }

  bool _checkLocalDataPresence() {
    return local_fridge.user.email.isNotEmpty && local_fridge.user.password.isNotEmpty;
  }

  Future<void> _login_no_textfields() async {
    if (await local_fridge.user.login()) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(context);
    }
  }

  Future<void> _login() async {
    local_fridge.user.setEmail(emailInputController.text);
    local_fridge.user.setPassword(passwordInputController.text);
    if (await local_fridge.user.login()) {
      await local_fridge.user.saveLocalData();
      local_fridge.fridge_ID = local_fridge.user.fridgeID;
      print('lunghezza in login ' + local_fridge.fridge_elements.length.toString());
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(context);
    }
  }

  Future<void> _signup() async {
    if (passwordInputController.text ==
        confirmPasswordInputController.text) {
      local_fridge.user.setEmail(emailInputController.text);
      local_fridge.user.setPassword(passwordInputController.text);
      if (await local_fridge.user.signup()) {
        await local_fridge.createFridgeAndDictionary();
        await local_fridge.user.saveLocalData();
        Navigator.pushReplacementNamed(context, '/first_color_picker');
      } else {
        _showError(context);
      }
    } else {
      _showError(context);
    }
  }

  void _showError(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Errore durante il login/signup.'),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
    await local_fridge.user.removeLocalData();
    local_fridge.user.dispose();
    /* frigo locale resettato */
    local_fridge.dispose();
    local_fridge.fridge_ID = "";
    /* shopping cart locale resettato */
    local_fridge.localShoppingCart.dispose();
    local_fridge.localShoppingCart.fridge_ID = "";
    /* dizionario locale resettato */
    local_fridge.localDictionary.dispose();
    local_fridge.localDictionary.fridge_ID = "";
  }

  void _showCompletionError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Devi accettare i termini e le condizioni.'),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  OutlineInputBorder _noInputBorder(BuildContext context) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.secondaryContainer)
    );
  }

  OutlineInputBorder _primaryColorInputBorder(BuildContext context) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide:
        BorderSide(color: Theme.of(context).colorScheme.primary)
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
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
                Center(
                  // Welcome
                  child: Padding(
                    padding: const EdgeInsets.only(top: 150.0),
                    child: Text(
                      'Benvenut*!',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                Center(
                  // Title
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Entra in The Fridge',
                      style: theme.textTheme.titleLarge,
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
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.tertiaryContainer),
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
                                          style: theme.textTheme.labelLarge,
                                        ),
                                      ],
                                    ),
                                    secondChild: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Icon(Icons.check,
                                          color: Colors.white
                                          ),
                                        ),
                                        Text(
                                          'Sign Up',
                                          style: theme.textTheme.labelLarge,
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
                                    ? theme.colorScheme.tertiaryContainer
                                    : theme.colorScheme.primary),
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
                                          style: theme.textTheme.labelLarge,
                                        ),
                                      ],
                                    ),
                                    secondChild: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Icon(Icons.check,
                                              color: Colors.white
                                          ),
                                        ),
                                        Text(
                                          'Log In',
                                          style: theme.textTheme.labelLarge,
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
                          controller: emailInputController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFf7f8f8),
                            border: _noInputBorder(context),
                            enabledBorder: _noInputBorder(context),
                            focusedBorder: _primaryColorInputBorder(context),
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            prefixIconColor: MaterialStateColor.resolveWith(
                                (states) =>
                                    states.contains(MaterialState.focused)
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.secondary),
                          ),
                        ),
                      ),
                      Padding(
                        // Password
                        padding:
                            EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                        child: TextField(
                          controller: passwordInputController,
                          obscureText: !password_visibility,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFFf7f8f8),
                              border: _noInputBorder(context),
                              enabledBorder: _noInputBorder(context),
                              focusedBorder: _primaryColorInputBorder(context),
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              prefixIconColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      states.contains(MaterialState.focused)
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.secondary),
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
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.secondary)),
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
                                controller: confirmPasswordInputController,
                                obscureText: !confirm_password_visibility,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Color(0xFFf7f8f8),
                                    border: _noInputBorder(context),
                                    enabledBorder: _noInputBorder(context),
                                    focusedBorder: _primaryColorInputBorder(context),
                                    labelText: 'Conferma password',
                                    prefixIcon: Icon(Icons.lock_outline),
                                    prefixIconColor:
                                        MaterialStateColor.resolveWith((states) =>
                                            states.contains(MaterialState.focused)
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.secondary),
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
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.secondary)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: theme.colorScheme.primary,
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
                                          color: theme.colorScheme.secondary,
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
                    MaterialStateProperty.all<Color>(theme.colorScheme.primary),
                minimumSize: MaterialStateProperty.all<Size>(Size(350.0, 72.0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(36.0))),
                ),
              ),
              onPressed: () async {
                if (_isSignup()) {
                  if (agreement_value) {
                    await _signup();
                  } else {
                    _showCompletionError(context);
                  }
                } else {
                  await _login();
                }
              },
              child: Text(
                'Avanti',
                style: TextStyle(
                  color: Colors.white,
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
