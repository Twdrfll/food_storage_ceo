import 'package:flutter/material.dart';
import '../fridge_state.dart';
import 'package:provider/provider.dart';

class Sort extends StatefulWidget {
  final int pageIndex;
  final LocalFridge localFridge;
  final Function changeSortOrder;
  final int actualSortOrder;
  const Sort({Key? key, required this.pageIndex, required this.localFridge, required this.changeSortOrder, required this.actualSortOrder}) : super(key: key);

  @override
  _SortState createState() => _SortState();
}

class _SortState extends State<Sort> {
  int selectedSortIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sortModel = Provider.of<SortModel>(context, listen: false);
    selectedSortIndex = widget.actualSortOrder;
    ThemeData theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'Ordinamento',
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
      content: Container(
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Parzialmente funzionante",
              style: TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Alfabetico A-Z"),
                Radio(
                  value: 0,
                  groupValue: selectedSortIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedSortIndex = value as int;
                      // change actual sort order
                      widget.changeSortOrder(selectedSortIndex);
                      sortModel.reorder(selectedSortIndex);
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Alfabetico Z-A"),
                Radio(
                  value: 1,
                  groupValue: selectedSortIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedSortIndex = value as int;
                      widget.changeSortOrder(selectedSortIndex);
                      sortModel.reorder(selectedSortIndex);
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Data di scadenza crescente"),
                Radio(
                  value: 2,
                  groupValue: selectedSortIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedSortIndex = value as int;
                      widget.changeSortOrder(selectedSortIndex);
                      sortModel.reorder(selectedSortIndex);
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Data di scadenza decrescente"),
                Radio(
                  value: 3,
                  groupValue: selectedSortIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedSortIndex = value as int;
                      widget.changeSortOrder(selectedSortIndex);
                      sortModel.reorder(selectedSortIndex);
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SortModel extends ChangeNotifier {
  Future<void> reorder(int sortOrder) async {
    if (sortOrder == 0) {
      LocalFridge().reorder_elements_alphabetically_a_to_z();
      notifyListeners();
    } else if (sortOrder == 1) {
      LocalFridge().reorder_elements_alphabetically_z_to_a();
      notifyListeners();
    } else if (sortOrder == 2) {
      LocalFridge().reorder_elements_by_expiration_date_ascending();
      notifyListeners();
    } else if (sortOrder == 3) {
      LocalFridge().reorder_elements_by_expiration_date_descending();
      notifyListeners();
  }}
}