import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fridge_state.dart';

class AddElement extends StatefulWidget {
  @override
  _AddElementState createState() => _AddElementState();
}

class _AddElementState extends State<AddElement> {
  String barcode = "";
  String name = "";
  int quantity = 0;
  DateTime? expiration;
  int validity = 0;
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerBarcode = TextEditingController();
  TextEditingController _controllerQuantity = TextEditingController();
  TextEditingController _controllerValidity = TextEditingController();
  LocalFridge local_fridge = LocalFridge();
  TextEditingController _controller = TextEditingController();
  List<LocalDictionaryElement> suggestions = [];
  late LocalFridgeElement element;
  final FocusNode _barcodeFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Data iniziale selezionata
      firstDate: DateTime.now(), // Data di inizio del calendario
      lastDate: DateTime(2101), // Data di fine del calendario
    );
    if (picked != null && picked != expiration) {
      setState(() {
        expiration = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _barcodeFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged({String? newBarcode, String? newName}) {
    if (newBarcode != null) {
      setState(() {
        barcode = newBarcode;
      });
      suggestions = local_fridge.localDictionary.search_element_by_barcode(newBarcode);
    } else if (newName != null) {
      setState(() {
        name = newName;
      });
      suggestions = local_fridge.localDictionary.search_element_by_string_name(newName);
    }
  }

  void _onFocusChanged() {
    setState(() {
      // Logica per controllare quale campo di testo è in focus
      if (_barcodeFocusNode.hasFocus) {
        // In base al campo di testo in focus, imposta i suggerimenti
        suggestions = local_fridge.localDictionary.search_element_by_barcode(barcode);
      } else if (_nameFocusNode.hasFocus) {
        suggestions = local_fridge.localDictionary.search_element_by_string_name(name);
      } else {
        // Nascondi i suggerimenti se nessun campo di testo è in focus
        suggestions = [];
      }
    });
  }

  bool checkIfLocalDataIsNotEmpty() {
    if (barcode != "" && name != "" && quantity != "" && expiration != null && validity != 0) {
      return true;
    } else {
      return false;
    }
  }

  void setupLocalData(String name, String barcode, int validity, int quantity, DateTime expiration) {
    print(name);
    print(barcode);
    print(validity);
    print(quantity);
    print(expiration);
    _controllerName.text = name;
    _controllerBarcode.text = barcode;
    _controllerValidity.text = validity.toString();
    _controllerQuantity.text = quantity.toString();
    setState(() {
      this.name = name;
      this.barcode = barcode;
      this.validity = validity;
      this.quantity = quantity;
      this.expiration = expiration;
    });
  }

  void setupCandidateElement() {
    if (checkIfLocalDataIsNotEmpty()) {
      element = LocalFridgeElement(
        name,
        barcode,
        validity.toString(),
        quantity,
        expiration!.toString(),
        local_fridge.user.color,
        int.parse(local_fridge.user.id),
      );
      if (local_fridge.returnIdOfExistingLocalDictionaryElement(element) != null) {
        element.id = local_fridge.returnIdOfExistingLocalDictionaryElement(element);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80.0,
        leading: SizedBox(
          width: 80.0,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nuovo Prodotto',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(
              width: 60.0,
            )
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // qua ci il pulsante per accedere allo scanner del codice a barre, con la preview di ciò che inquadra la fotocamera
                IconButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(CircleBorder()),
                    backgroundColor: MaterialStateProperty.all(theme.colorScheme.primary),
                  ),
                  iconSize: 40.0,
                    color: theme.colorScheme.onPrimary,
                    onPressed: () async {
                      final scanned_barcode = await Navigator.pushNamed(context, '/scan_barcode');
                      setState(() {
                        barcode = scanned_barcode as String;
                        print('barcode scansionato: {$barcode}');
                        _controllerBarcode.text = barcode;
                        if (barcode != "") {
                          suggestions = local_fridge.localDictionary.search_element_by_barcode(barcode);
                          if (suggestions.length > 0) {
                            setupLocalData(
                                suggestions[0].name, suggestions[0].barcode,
                                int.parse(suggestions[0].days_to_expiration), 0,
                                DateTime.now());
                          }
                        }
                      });
                    },
                    icon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.qr_code_scanner),
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Scansiona il barcode",
                    style: TextStyle(
                      fontSize: theme.textTheme.labelLarge!.fontSize,
                      fontWeight: theme.textTheme.labelLarge!.fontWeight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _controllerBarcode,
                        focusNode: _barcodeFocusNode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Barcode",
                          labelStyle: TextStyle(
                            fontSize: theme.textTheme.labelLarge!.fontSize,
                            fontWeight: theme.textTheme.labelLarge!.fontWeight,
                          ),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          fillColor: theme.colorScheme.tertiary,
                          filled: true,
                        ),
                        onChanged: (value) {
                          if (value.length > 0) {
                            _onTextChanged(newBarcode: value);
                          } else {
                            setState(() {
                              barcode = "";
                              suggestions = [];
                            });
                          }
                        },
                      ),
                      if (_barcodeFocusNode.hasFocus && suggestions.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                          ),
                          height: 170.0,
                          child: ListView.builder(
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(suggestions[index].name),
                                subtitle: Text(suggestions[index].barcode),
                                onTap: () {
                                  setupLocalData(suggestions[index].name, suggestions[index].barcode, int.parse(suggestions[index].days_to_expiration), 0, DateTime.now());
                                  // rimuovo il focus dal campo di testo
                                  _barcodeFocusNode.unfocus();
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _controllerName,
                        focusNode: _nameFocusNode,
                        decoration: InputDecoration(
                          labelText: "Nome Prodotto",
                          labelStyle: TextStyle(
                            fontSize: theme.textTheme.labelLarge!.fontSize,
                            fontWeight: theme.textTheme.labelLarge!.fontWeight,
                          ),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          fillColor: theme.colorScheme.tertiary,
                          filled: true,
                        ),
                        onChanged: (value) {
                          if (value.length > 0) {
                            _onTextChanged(newName: value);
                          } else {
                            setState(() {
                              name = "";
                              suggestions = [];
                            });
                          }
                        },
                      ),
                      if (_nameFocusNode.hasFocus && suggestions.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                          ),
                          height: 170.0,
                          child: ListView.builder(
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(suggestions[index].name),
                                subtitle: Text(suggestions[index].barcode),
                                onTap: () {
                                  setupLocalData(suggestions[index].name, suggestions[index].barcode, int.parse(suggestions[index].days_to_expiration), 0, DateTime.now());
                                  // rimuovo il focus dal campo di testo
                                  _nameFocusNode.unfocus();
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(
                        'Data di scadenza',
                        style: TextStyle(
                          fontSize: theme.textTheme.labelLarge!.fontSize,
                          fontWeight: theme.textTheme.labelLarge!.fontWeight,
                        ),
                      ),
                      subtitle: expiration != null
                          ? Text(
                        '${expiration!.day}/${expiration!.month}/${expiration!.year}',
                        style: TextStyle(
                          fontSize: theme.textTheme.labelLarge!.fontSize,
                          fontWeight: theme.textTheme.labelLarge!.fontWeight,
                          color: theme.colorScheme.primary,
                        ),
                      )
                          : Text(
                        'tocca e scegli...',
                        style: TextStyle(
                          fontSize: theme.textTheme.labelLarge!.fontSize,
                          fontWeight: theme.textTheme.labelLarge!.fontWeight,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _controllerValidity,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Validità da aperto",
                      labelStyle: TextStyle(
                        fontSize: theme.textTheme.labelLarge!.fontSize,
                        fontWeight: theme.textTheme.labelLarge!.fontWeight,
                      ),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      fillColor: theme.colorScheme.tertiary,
                      filled: true,
                    ),
                    onChanged: (value) {
                      if (value != "") {
                        setState(() {
                          validity = int.parse(value);
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _controllerQuantity,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Quantità",
                      labelStyle: TextStyle(
                        fontSize: theme.textTheme.labelLarge!.fontSize,
                        fontWeight: theme.textTheme.labelLarge!.fontWeight,
                      ),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      fillColor: theme.colorScheme.tertiary,
                      filled: true,
                    ),
                    onChanged: (value) {
                      if (value != "") {
                        setState(() {
                          quantity = int.parse(value);
                        });
                      }
                    },
                  ),
                ),
                Padding( // Bottone logout
                  padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton( // Logout e ritorno alla pagina di login
                      onPressed: () async {
                        setupCandidateElement();
                        await local_fridge.addElement(element);
                        Provider.of<AddElementModel>(context, listen: false).alertFridge();
                        Navigator.pop(context);
                      },
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
                        "Aggiungi prodotto",
                        style: TextStyle(
                          fontSize: theme.textTheme.labelLarge!.fontSize,
                          fontWeight: theme.textTheme.labelLarge!.fontWeight,
                          color: theme.textTheme.labelLarge!.color,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddElementModel extends ChangeNotifier {
  void alertFridge() {
    notifyListeners();
  }
}