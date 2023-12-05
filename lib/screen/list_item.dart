import 'package:flutter/material.dart';
import 'package:food_storage_ceo/screen/sort.dart';
import 'package:provider/provider.dart';
import '../fridge_state.dart';

class FridgeItems extends StatefulWidget {
  final LocalFridge local_fridge;

  const FridgeItems({Key? key, required this.local_fridge}) : super(key: key);

  @override
  _FridgeItemsState createState() => _FridgeItemsState();
}

class _FridgeItemsState extends State<FridgeItems> {

  late List<LocalFridgeElement> local_fridge_elements = [];

  hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  void initState() {
    super.initState();
    widget.local_fridge.dispose();
    loadFridgeData();
  }

  @override
  void dispose() {
    super.dispose();
    widget.local_fridge.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await loadFridgeData();
    }
  }

  Future<void> loadFridgeData() async {
    await widget.local_fridge.setupFridge();
    setState(() {
      local_fridge_elements = widget.local_fridge.fridge_elements;
    });
  }

  bool doesProductExpireBeforeDaysToExpiration(LocalFridgeElement product) {
    DateTime expiration_date = DateTime.parse(product.expiration_date);
    DateTime valid_until = expiration_date.subtract(Duration(days: int.parse(product.days_to_expiration)));
    DateTime now = DateTime.now();
    if (now.isAfter(valid_until)) {
      return true;
    } else {
      return false;
    }
  }

  Widget textOfButton(LocalFridgeElement product) {
    if (doesProductExpireBeforeDaysToExpiration(product)) {
      return Text(
        'Scade!',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      return Text(
        'Apri',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
  }

  Widget openProductButton(LocalFridgeElement product, int index, ThemeData theme) {
    if (doesProductExpireBeforeDaysToExpiration(product)) {
      return ElevatedButton(
          onPressed: () async {
            if (doesProductExpireBeforeDaysToExpiration(product)) {
              null;
            } else {
              await widget.local_fridge.setProductAsOpen(widget.local_fridge.fridge_elements[index]);
              setState(() {});
            }
          },
          style: ElevatedButton.styleFrom(
            primary: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 12.0, bottom: 12.0),
            child: textOfButton(product),
          )
      );
    } else {
      return ElevatedButton(
          onPressed: () async {
            if (doesProductExpireBeforeDaysToExpiration(product)) {
              null;
            } else {
              await widget.local_fridge.setProductAsOpen(widget.local_fridge.fridge_elements[index]);
              setState(() {});
            }
          },
          style: ElevatedButton.styleFrom(
            primary: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 12.0, bottom: 12.0),
            child: textOfButton(product),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    local_fridge_elements = widget.local_fridge.fridge_elements;
    return Consumer<SortModel>(
      builder: (context, sortModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: ListView.builder(
            itemCount: local_fridge_elements.length,
            itemBuilder: (context, index) {
              return Dismissible(
                behavior: HitTestBehavior.translucent,
                key: Key(local_fridge_elements[index].id.toString()),
                onDismissed: (direction) async {
                  await widget.local_fridge.removeElement(widget.local_fridge.fridge_elements[index]);
                  setState(() {});
                },
                background: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: theme.colorScheme.error,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.delete,
                            color: theme.colorScheme.onPrimary,
                          ),
                          Text('Prodotto consumato',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          Icon(
                            Icons.delete,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hexToColor(local_fridge_elements[index].color),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExpansionTile(
                      backgroundColor: theme.colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // box con il conteggio dei prodotti
                      trailing: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            local_fridge_elements[index].quantity.toString(),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: theme.textTheme.titleMedium!.fontSize,
                              fontWeight: theme.textTheme.titleLarge!.fontWeight,
                            ),
                          ),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                            child: Text(
                              local_fridge_elements[index].name,
                              style: TextStyle(
                                fontSize: theme.textTheme.titleMedium!.fontSize,
                                fontWeight: theme.textTheme.titleLarge!
                                    .fontWeight,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                            child: Text('Scadenza: ' +
                                local_fridge_elements[index].expiration_date
                                    .toString()),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 160,
                                  width: 370,
                                  child: GridView.count(
                                    childAspectRatio: 2.7,
                                    primary: false,
                                    padding: const EdgeInsets.all(8),
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 12,
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Modifica il numero di unità:',
                                            style: TextStyle(
                                              fontSize: theme.textTheme.labelMedium!.fontSize,
                                              fontWeight: theme.textTheme.labelMedium!.fontWeight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: 0.9,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (local_fridge_elements[index].quantity > 1) {
                                                  await widget.local_fridge.alter_element_quantity(local_fridge_elements[index], local_fridge_elements[index].quantity - 1);
                                                  setState(() {});
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(20, 50),
                                                  backgroundColor: Colors.white,
                                                  shape: CircleBorder(
                                                    side: BorderSide(
                                                      color: theme.colorScheme.primary,
                                                      width: 2,
                                                    ),
                                                  )
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12.0, bottom: 12.0),
                                                child: Icon(
                                                  Icons.remove,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await widget.local_fridge.alter_element_quantity(local_fridge_elements[index], local_fridge_elements[index].quantity + 1);
                                                setState(() {});
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  minimumSize: Size(20, 50),
                                                  backgroundColor: Colors.white,
                                                  shape: CircleBorder(
                                                    side: BorderSide(
                                                      color: theme.colorScheme.primary,
                                                      width: 2,
                                                    ),
                                                  )
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12.0, bottom: 12.0),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hai aperto una confezione?',
                                            style: TextStyle(
                                              fontSize: theme.textTheme.labelMedium!.fontSize,
                                              fontWeight: theme.textTheme.labelMedium!.fontWeight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: 0.9,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              openProductButton(local_fridge_elements[index], index, theme),
                                            ],
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                                /*Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 90,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // due bottoni per aumentare e diminuire la quantità, rotondi. Uno con un più e uno con un meno
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Modifica il numero di unità:',
                                                style: TextStyle(
                                                  fontSize: theme.textTheme.labelMedium!.fontSize,
                                                  fontWeight: theme.textTheme.labelMedium!.fontWeight,
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        if (local_fridge_elements[index].quantity > 1) {
                                                          await widget.local_fridge.alter_element_quantity(local_fridge_elements[index], local_fridge_elements[index].quantity - 1);
                                                          setState(() {});
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.white,
                                                          shape: CircleBorder(
                                                            side: BorderSide(
                                                              color: theme.colorScheme.primary,
                                                              width: 2,
                                                            ),
                                                          )
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(
                                                            top: 12.0, bottom: 12.0),
                                                        child: Icon(
                                                          Icons.remove,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await widget.local_fridge.alter_element_quantity(local_fridge_elements[index], local_fridge_elements[index].quantity + 1);
                                                        setState(() {});
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.white,
                                                        shape: CircleBorder(
                                                          side: BorderSide(
                                                            color: theme.colorScheme.primary,
                                                            width: 2,
                                                          ),
                                                        )
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(
                                                            top: 12.0, bottom: 12.0),
                                                        child: Icon(
                                                          Icons.add,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),*/
                                /*Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'Hai aperto una confezione?',
                                      style: TextStyle(
                                        fontSize: theme.textTheme.labelMedium!.fontSize,
                                        fontWeight: theme.textTheme.labelMedium!.fontWeight,
                                      ),
                                    ),
                                    openProductButton(local_fridge_elements[index], index, theme),
                                  ],
                                ),*/
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }
}