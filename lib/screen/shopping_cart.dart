import 'package:flutter/material.dart';
import 'package:food_storage_ceo/fridge_event.dart';
import 'package:food_storage_ceo/screen/home.dart';
import './dictionary_list.dart';
import '../fridge_state.dart';
import 'package:provider/provider.dart';

class ShoppingCartWindow extends StatefulWidget {
  final LocalFridge local_fridge;

  const ShoppingCartWindow({Key? key, required this.local_fridge}) : super(key: key);

  @override
  _ShoppingCartWindowState createState() => _ShoppingCartWindowState();
}

class _ShoppingCartWindowState extends State<ShoppingCartWindow> {
  Map<int, bool> selectedItems = {};
  bool newElementFromPlusButton = false;

  /* parametri per il nuovo elemento da aggiungere alla lista della spesa */
  String new_element_barcode = "";
  int new_element_quantity = 0;
  String new_element_name = "";
  String new_element_days_to_exp = "0";
  String new_element_color = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  /* alcuni parametri sono vuoti poiché non sono necessari per la creazione di un nuovo elemento
  * l'utente potrà poi aggiornare i dati come desidera quando inserirà il prodotto acquistato in dispensa */

  @override
  void initState() {
    super.initState();
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  void setEveryElementToUnselected() {
    selectedItems.clear();
    for (var i = 0; i < widget.local_fridge.localShoppingCart.shopping_cart_elements.length; i++) {
      if (!selectedItems.containsKey(i)) {
        selectedItems.putIfAbsent(i, () => false);
      } else {
        selectedItems[i] = false;
      }
    }
  }

  Widget newElementAdder(bool selected, BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (selected) {
      newElementFromPlusButton = true;
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1.0,
              blurRadius: 5.0,
              offset: Offset(0, 3),
            ),
          ],
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Nome',
                  hintStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onChanged: (value) {
                  print(value);
                  new_element_name = nameController.text;
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  hintText: 'Quantità',
                  hintStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onChanged: (value) {
                  print(value);
                  new_element_quantity = int.parse(quantityController.text);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 21.0, bottom: 21.0),
              child: IconButton(
                iconSize: 30.0,
                  color: theme.colorScheme.primary,
                  onPressed: () {
                  print(new_element_name);
                  print(new_element_quantity);
                  if (new_element_name != "" && new_element_quantity != 0) {
                    LocalShoppingCartElement new_element = LocalShoppingCartElement(new_element_name, new_element_barcode, new_element_days_to_exp, new_element_quantity, widget.local_fridge.user.color, int.parse(widget.local_fridge.user.id));
                    widget.local_fridge.localShoppingCart.addElement(new_element).then((value) => setState(() {
                      setEveryElementToUnselected();
                    }));
                  }},
                  icon: Icon(Icons.add)
              ),
            )
          ],
        ),
      );
    } else {
      newElementFromPlusButton = false;
      return Container();
    }
}

  int countSelectedItems() {
    int counter = 0;
    for (var key in selectedItems.keys) {
      if (selectedItems[key] == true) {
        counter++;
      }
    }
    return counter;
  }

  Future<void> removeSelectedElementsFromShoppingList() async {
    List<LocalShoppingCartElement> elements_to_remove = [];
    for (var key in selectedItems.keys) {
      if (selectedItems[key] == true) {
        elements_to_remove.add(widget.local_fridge.localShoppingCart.shopping_cart_elements[key]);
      }
    }
    for (var element in elements_to_remove) {
      await widget.local_fridge.localShoppingCart.removeElement(element);
    }
    setEveryElementToUnselected();
  }

  Widget removeSelectedItemsFromShoppingListButton(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (countSelectedItems() > 0) {
      return Stack(
        children: [
          Container(
            child: IconButton(
                onPressed: () async {
                  removeSelectedElementsFromShoppingList().then((value) => setState(() {
                    print('dopo esecuzione bottone: $selectedItems');
                  }));
                },
                icon: Container(
                  width: 72.0,
                  height: 72.0,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.primary,
                      size: 40.0
                  ),
                ),
            ),
          ),
          Positioned(
            right: 0.0,
              top: 0.0,
              child: Container(
                width: 28.0,
                height: 28.0,
                decoration: BoxDecoration(
                  color: Color(0xFFE6AF2F),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        countSelectedItems().toString(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: theme.textTheme.labelMedium!.fontSize,
                        fontWeight: theme.textTheme.labelSmall!.fontWeight,
                      )
                    ),
                  ],
                ),
              )
          )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget ListElement(int index, BuildContext context) {
    ThemeData theme = Theme.of(context);
    double bottom_padding = 12.0;
    if (index == widget.local_fridge.localShoppingCart.shopping_cart_elements.length - 1) {
      if (newElementFromPlusButton) {
        bottom_padding = 200.0;
      } else {
        bottom_padding = 120.0;
      }
    }
    return Padding(
      padding: EdgeInsets.only(top: 12.0, bottom: bottom_padding, left: 12.0, right: 12.0),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: hexToColor(widget.local_fridge.localShoppingCart.shopping_cart_elements[index].color),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text(
                  widget.local_fridge.localShoppingCart.shopping_cart_elements[index].name,
                style: TextStyle(
                  fontSize: theme.textTheme.titleMedium!.fontSize,
                  fontWeight: theme.textTheme.titleLarge!.fontWeight,
                  color: Colors.black,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Quantità: ${widget.local_fridge.localShoppingCart.shopping_cart_elements[index].quantity.toString()}'),
                  Checkbox(
                    value: selectedItems[index],
                    onChanged: (bool? value) {
                      setState(() {
                        selectedItems[index] = value!;
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build (BuildContext context) {
    return Consumer<TriggerUpdateModel>(
      builder: (context, triggerUpdateModel, child) {
        if (selectedItems.isEmpty || selectedItems.length != widget.local_fridge.localShoppingCart.shopping_cart_elements.length) {
          setEveryElementToUnselected();
        }
        return Consumer<AddNewElementToShoppingListModel>(
            builder: (context, addNewElementToShoppingListModel, child) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Stack(
                  children: [
                    SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: widget.local_fridge.localShoppingCart.shopping_cart_elements.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListElement(index, context);
                              },
                            ),
                          ],
                        )
                    ),
                    Positioned(
                      bottom: 100.0,
                      right: 0.0,
                      left: 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: removeSelectedItemsFromShoppingListButton(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: newElementAdder(addNewElementToShoppingListModel.selected, context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
      }
    );
  }
}