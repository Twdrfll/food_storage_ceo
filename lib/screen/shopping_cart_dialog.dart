import 'package:flutter/material.dart';
import './dictionary_list.dart';
import 'package:provider/provider.dart';

class ShoppingCartRecap extends StatefulWidget {
  const ShoppingCartRecap({Key? key}) : super(key: key);

  @override
  _ShoppingCartRecapState createState() => _ShoppingCartRecapState();
}

class _ShoppingCartRecapState extends State<ShoppingCartRecap> {

  int _number_of_elements = 1;

  Map<int, int> quantityForItem = {}; // il primo valore è l'indice nell'array di elementi selezionati, il secondo è la quantità scelta

  void setAllQuantitiesToOne() {
    for (var i = 0; i < _number_of_elements; i++) {
      quantityForItem.putIfAbsent(i, () => 1);
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
                if (quantityForItem[element_index]! > 1) {
                  quantityForItem[element_index] = actual_quantity - 1;
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
                quantityForItem[element_index] = actual_quantity + 1;
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
      setAllQuantitiesToOne();
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
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
                                    dictionaryItemsModel.selectedElements[index].name,
                                    style: TextStyle(
                                      fontSize: theme.textTheme.labelLarge!.fontSize,
                                      fontWeight: theme.textTheme.labelLarge!.fontWeight,
                                      color: Colors.black,
                                    ),
                                  ),
                                  quantitySelection(quantityForItem[index]!, index, context),
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
            child: Text(
              'Conferma la tua lista della spesa',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: theme.textTheme.titleLarge!.fontSize,
                fontWeight: theme.textTheme.titleLarge!.fontWeight,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          Positioned(
            bottom: 48.0,
            left: 24.0,
            right: 24.0,
            child: ElevatedButton( // Logout e ritorno alla pagina di login
              onPressed: () {},
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