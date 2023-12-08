import 'package:flutter/material.dart';
import '../fridge_state.dart';
import 'package:provider/provider.dart';

class DictionaryItems extends StatefulWidget {
  final LocalFridge local_fridge;

  DictionaryItems({Key? key, required this.local_fridge}) : super(key: key);

  @override
  _DictionaryItemsState createState() => _DictionaryItemsState();

}

class _DictionaryItemsState extends State<DictionaryItems> {
  Map<int, bool> selectedItems = {};
  Map<int, LocalDictionaryElement> suggestionResult = {};

  @override
  void initState() {
    super.initState();
  }

  void setAllDictionaryItemsToUnselected() {
    for (var i = 0; i < widget.local_fridge.localDictionary.dictionary_elements.length; i++) {
      selectedItems.putIfAbsent(i, () => false);
    }
  }

  void setSuggestedListAsAllDictionaryElements() {
    suggestionResult.clear();
    for (var i = 0; i < widget.local_fridge.localDictionary.dictionary_elements.length; i++) {
      addElementToSuggestedList(i, widget.local_fridge.localDictionary.dictionary_elements[i]);
    }
}

  void addElementToSuggestedList(int og_index, LocalDictionaryElement element) {
    suggestionResult.putIfAbsent(og_index, () => element);
  }

  void searchDictionaryElementByName(String name) {
    suggestionResult.clear();
    for (var i = 0; i < widget.local_fridge.localDictionary.dictionary_elements.length; i++) {
      if (widget.local_fridge.localDictionary.dictionary_elements[i].name.contains(name)) {
        addElementToSuggestedList(i, widget.local_fridge.localDictionary.dictionary_elements[i]);
      }
    }
  }

  void selectedItemsChecker(List<LocalDictionaryElement> elements) {
    print('selectedItemsChecker');
    for (var element in elements) {
      print(element.name);
    }
  }

  Widget listElementBuilder(ThemeData theme, int index) {
    final dictionaryItemsModel = Provider.of<DictionaryItemsModel>(context, listen: false);
    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 130.0, bottom: 12.0, left: 12.0),
        child: ListTile(
          title: Text(
            suggestionResult.values.elementAt(index).name,
            style: TextStyle(
              color: Colors.black,
              fontSize: theme.textTheme.titleMedium!.fontSize,
              fontWeight: theme.textTheme.titleLarge!.fontWeight,
            ),
          ),
          subtitle: Text('Consumare entro ${widget.local_fridge.localDictionary.dictionary_elements[index].days_to_expiration} giorni dall\'apertura'),
          trailing: Checkbox(
            value: selectedItems.values.elementAt(suggestionResult.keys.elementAt(index)),
            onChanged: (bool? value) {
              setState(() {
                selectedItems[suggestionResult.keys.elementAt(index)] = value!;
                if (value) {
                  dictionaryItemsModel.addSelectedElement(suggestionResult.values.elementAt(index));
                } else {
                  dictionaryItemsModel.removeSelectedElement(suggestionResult.values.elementAt(index));
                }
              });
              print('elemento con $index ora è selezionato? ${selectedItems[index]}');
              selectedItemsChecker(dictionaryItemsModel._selectedElements);
            },
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0, left: 12.0),
        child: ListTile(
          title: Text(
            suggestionResult.values.elementAt(index).name,
            style: TextStyle(
              color: Colors.black,
              fontSize: theme.textTheme.titleMedium!.fontSize,
              fontWeight: theme.textTheme.titleLarge!.fontWeight,
            ),
          ),
          subtitle: Text('Consumare entro ${widget.local_fridge.localDictionary.dictionary_elements[index].days_to_expiration} giorni dall\'apertura'),
          trailing: Checkbox(
            value: selectedItems.values.elementAt(suggestionResult.keys.elementAt(index)),
            onChanged: (bool? value) {
              setState(() {
                selectedItems[suggestionResult.keys.elementAt(index)] = value!;
                if (value) {
                  dictionaryItemsModel.addSelectedElement(suggestionResult.values.elementAt(index));
                } else {
                  dictionaryItemsModel.removeSelectedElement(suggestionResult.values.elementAt(index));
                }
              });
              print('elemento con $index ora è selezionato? ${selectedItems[index]}');
              selectedItemsChecker(dictionaryItemsModel._selectedElements);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (selectedItems.isEmpty) {
      setAllDictionaryItemsToUnselected();
      setSuggestedListAsAllDictionaryElements();
    }
    return Stack(
        children: <Widget> [
          SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
              color: Colors.white,
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120.0),
              child: ListView.builder(
                itemCount: suggestionResult.length,
                itemBuilder: (context, index) {
                  return listElementBuilder(theme, index);
                },
              ),
            ),
          ),
        ),
          Positioned(
            top: 25.0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                        child: Icon(
                          Icons.search,
                          color: theme.primaryColor,
                        ),
                      ),
                      labelText: 'Cerca prodotti',
                      labelStyle: TextStyle(color: theme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchDictionaryElementByName(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      );
  }
}

class DictionaryItemsModel extends ChangeNotifier {

  List<LocalDictionaryElement> _selectedElements = [];
  List<LocalDictionaryElement> get selectedElements => _selectedElements;

  void addSelectedElement(LocalDictionaryElement element) {
    _selectedElements.add(element);
    notifyListeners();
  }

  void removeSelectedElement(LocalDictionaryElement element) {
    _selectedElements.remove(element);
    notifyListeners();
  }

  void removeAllSelectedElements() {
    _selectedElements.clear();
    notifyListeners();
  }

}