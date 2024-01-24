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
      if (!selectedItems.containsKey(i)){
        selectedItems.putIfAbsent(i, () => false);
      } else {
        selectedItems[i] = false;
      }
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

  void selectedItemsChecker(Map<int, LocalDictionaryElement> elements) {
    if (elements.isEmpty) {
      setAllDictionaryItemsToUnselected();
    } else {
      for (var i = 0; i < selectedItems.length; i++) {
        if (elements.containsKey(i)) {
          selectedItems[i] = true;
        } else {
          selectedItems[i] = false;
        }
      }
    }
  }

  void resetElements() {
    setSuggestedListAsAllDictionaryElements();
    setAllDictionaryItemsToUnselected();
  }

  Widget listElementBuilder(ThemeData theme, int index) {
    if (index == 0) {
      return Consumer<DictionaryItemsModel>(
      builder: (context, dictionaryItemsModel, child) {
        selectedItemsChecker(dictionaryItemsModel._selectedElements);
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
                      dictionaryItemsModel.addSelectedElement(suggestionResult.keys.elementAt(index), suggestionResult.values.elementAt(index));
                    } else {
                      dictionaryItemsModel.removeSelectedElement(suggestionResult.keys.elementAt(index));
                    }
                  });
                },
              ),
            ),
          );
        },
      );
    } else {
      return Consumer<DictionaryItemsModel>(
        builder: (context, dictionaryItemsModel, child) {
          selectedItemsChecker(dictionaryItemsModel._selectedElements);
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
                      dictionaryItemsModel.addSelectedElement(suggestionResult.keys.elementAt(index), suggestionResult.values.elementAt(index));
                    } else {
                      dictionaryItemsModel.removeSelectedElement(suggestionResult.keys.elementAt(index));
                    }
                  });
                },
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (selectedItems.isEmpty) {
      resetElements();
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

  Map<int, LocalDictionaryElement> _selectedElements = {};
  Map<int, LocalDictionaryElement> get selectedElements => _selectedElements;

  void addSelectedElement(int index_in_dictionary, LocalDictionaryElement element) {
    _selectedElements.putIfAbsent(index_in_dictionary, () => element);
    notifyListeners();
  }

  void removeSelectedElement(int index_in_dictionary) {
    _selectedElements.remove(index_in_dictionary);
    notifyListeners();
  }

  void removeAllSelectedElements() {
    _selectedElements.clear();
    notifyListeners();
  }

}