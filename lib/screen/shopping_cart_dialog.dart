import 'package:flutter/material.dart';
import './dictionary_list.dart';
import '../fridge_state.dart';
import 'package:provider/provider.dart';

class ShoppingCartRecap extends StatefulWidget {
  final LocalFridge local_fridge;

  const ShoppingCartRecap({Key? key, required this.local_fridge}) : super(key: key);

  @override
  _ShoppingCartRecapState createState() => _ShoppingCartRecapState();
}

class _ShoppingCartRecapState extends State<ShoppingCartRecap> {

  int _number_of_elements = 1;
  // il primo valore è l'indice dell'elemento nell'array di elementi presenti nel dizionario, il secondo è la quantità scelta
  Map<int, int> quantityForItem = {};

  /*void setAllQuantitiesToOne() {
    for (var i = 0; i < _number_of_elements; i++) {
      quantityForItem.putIfAbsent(i, () => 1);
    }
  }*/

  void setAllQuantitiesToOne(Map<int, LocalDictionaryElement> elements) {
    for (var key in elements.keys) {
      quantityForItem.putIfAbsent(key, () => 1);
    }
  }

  Future<void> addElementToShoppingCart(LocalDictionaryElement element, int quantity) async {
    String shoppingCartElementName = element.name;
    String shoppingCartBarcode = element.barcode;
    String shoppingCartElementDaysToExp = element.days_to_expiration;
    int shoppingCartElementQuantity = quantity;
    String shoppingCartElementColor = widget.local_fridge.user.color;
    int shoppingCartUserID = int.parse(widget.local_fridge.user.id);
    LocalShoppingCartElement shoppingCartElement = LocalShoppingCartElement(
        shoppingCartElementName,
        shoppingCartBarcode,
        shoppingCartElementDaysToExp,
        shoppingCartElementQuantity,
        shoppingCartElementColor,
        shoppingCartUserID
    );
    await widget.local_fridge.localShoppingCart.addElement(shoppingCartElement);
  }

  Future<void> addElementsToShoppingCart() async {
    print(quantityForItem);
    for (var key in quantityForItem.keys) {
      await addElementToShoppingCart(widget.local_fridge.localDictionary.dictionary_elements[key], quantityForItem[key]!);
    }
  }

  Widget quantitySelection(int actual_quantity, int element_index, BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      width: 150.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                if (quantityForItem.values.elementAt(element_index) > 1) {
                  int element_key = quantityForItem.keys.elementAt(element_index);
                  quantityForItem[element_key] = actual_quantity - 1;
                }
              });
            },
            icon: Icon(
                Icons.remove,
              color: actual_quantity == 1 ? theme.colorScheme.secondary : theme.colorScheme.primary,
            ),
          ),
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary,
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  actual_quantity.toString(),
                  style: TextStyle(
                    fontSize: 24.0,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                int element_key = quantityForItem.keys.elementAt(element_index);
                quantityForItem[element_key] = actual_quantity + 1;
              });
            },
            icon: Icon(
                Icons.add,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final dictionaryItemsModel = Provider.of<DictionaryItemsModel>(
        context, listen: false);
    if (dictionaryItemsModel.selectedElements.isNotEmpty) {
      _number_of_elements = dictionaryItemsModel.selectedElements.length;
      setAllQuantitiesToOne(dictionaryItemsModel.selectedElements);
    }
    return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120.0, right: 12.0, left: 12.0, bottom: 140.0),
            child: ListView.builder(
                itemCount: _number_of_elements,
                itemBuilder: (context, index) {
                  if (dictionaryItemsModel.selectedElements.isEmpty) {
                    return ListTile(
                      title: Text(
                        'Non hai ancora selezionato nessun elemento',
                        style: TextStyle(
                          fontSize: theme.textTheme.labelLarge!.fontSize,
                          fontWeight: theme.textTheme.labelLarge!.fontWeight,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                      child: Container(
                        height: 72.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.only(left: 24.0, right: 0.0), // metto a zero a destra per posizionare il quantitySelection a destra
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dictionaryItemsModel.selectedElements.values.elementAt(index).name,
                                    style: TextStyle(
                                      fontSize: theme.textTheme.labelLarge!.fontSize,
                                      fontWeight: theme.textTheme.labelLarge!.fontWeight,
                                      color: Colors.black,
                                    ),
                                  ),
                                  quantitySelection(quantityForItem.values.elementAt(index), index, context),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:12.0, right: 12.0, top: 24.0, bottom: 24.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                'Conferma il tuo carrello della spesa',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: theme.textTheme.titleLarge!.fontSize,
                  fontWeight: theme.textTheme.titleLarge!.fontWeight,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 48.0,
            left: 24.0,
            right: 24.0,
            child: ElevatedButton( // Logout e ritorno alla pagina di login
              onPressed: () async {
                await addElementsToShoppingCart();
                dictionaryItemsModel.removeAllSelectedElements();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(theme.colorScheme.onPrimary),
                minimumSize: MaterialStateProperty.all<Size>(Size(350.0, 72.0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(36.0))),
                ),
              ),
              child: Text(
                "Conferma",
                style: TextStyle(
                  fontSize: theme.textTheme.labelLarge!.fontSize,
                  fontWeight: theme.textTheme.titleLarge!.fontWeight,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          )
        ],
    );
  }
}