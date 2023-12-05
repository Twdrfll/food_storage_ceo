import 'package:flutter/material.dart';
import '../fridge_state.dart';
import './color_picker.dart';
import '../screen/app_settings.dart';
import 'package:provider/provider.dart';
import './list_item.dart';
import './sort.dart';
import './calendar.dart';
import './add_element.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {

  int _selected_index = 0;
  int _actual_sort_order_fridge = -1;
  bool _actual_sort_order_fridge_init = false;
  late LocalFridge local_fridge;
  late LocalDictionary local_dictionary;
  late LocalShoppingCart local_shopping_cart;
  var userColor;

  void initState() {
    super.initState();
    local_fridge = LocalFridge();
    local_dictionary = LocalDictionary();
    local_shopping_cart = LocalShoppingCart();
    userColor = local_fridge.user.color;
    if (!_actual_sort_order_fridge_init) {
      _actual_sort_order_fridge = 0;
      _actual_sort_order_fridge_init = true;
    }
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return Consumer<ColorPickerModel>(
      builder: (context, colorPickerModel, child) {

        List<Color> _differentColors = [
          Color(0xFFE6AF2F),
          Color(0xFFE6AF2F),
          Color(0xFFE6AF2F),
          hexToColor(colorPickerModel.userColor),
        ];
        List<AppBar> _differentAppBar = [
          AppBar(
            toolbarHeight: 80.0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: theme.colorScheme.primary,
                        isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: FridgeCalendar(localFridgeElements: local_fridge.fridge_elements,),
                            );
                          },
                      );
                    },
                    child: Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(0.0),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<CircleBorder>(CircleBorder(
                        side: BorderSide(
                          color: Colors.white,
                        ),
                      )),
                      minimumSize: MaterialStateProperty.all<Size>(Size(60, 60)),
                    )
                ),
                Text('Il mio frigo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                    onPressed: () {
                      print('Sort');
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Sort(
                          pageIndex: _selected_index,
                          localFridge: local_fridge,
                            changeSortOrder: (newSortOrder) {
                              setState(() {
                                _actual_sort_order_fridge = newSortOrder;
                              });
                            },
                            actualSortOrder: _actual_sort_order_fridge,
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.filter_list_outlined,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(0.0),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<CircleBorder>(CircleBorder(
                        side: BorderSide(
                          color: Colors.white,
                        ),
                      )),
                      minimumSize: MaterialStateProperty.all<Size>(Size(60, 60)),
                    )
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: true,
          ),
          AppBar(
            toolbarHeight: 80.0,
            title: Text('Carrello della spesa',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: true,
          ),
          AppBar(
            toolbarHeight: 80.0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80.0,
                ),
                Text('Dizionario',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                    onPressed: () {},
                    child: Icon(
                      Icons.filter_list_outlined,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(0.0),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<CircleBorder>(CircleBorder(
                        side: BorderSide(
                          color: Colors.white,
                        ),
                      )),
                      minimumSize: MaterialStateProperty.all<Size>(Size(60, 60)),
                    )
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: true,
          ),
          AppBar(
            toolbarHeight: 80.0,
            title: Text('Profilo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            backgroundColor: hexToColor(colorPickerModel.userColor),
            elevation: 0.0,
            centerTitle: true,
          ),
        ];
        List<Icon> _differentIcons = [
          Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
          Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
          Icon(
            Icons.shopping_basket_outlined,
            color: Colors.white,
            size: 30,
          ),
          Icon(
            Icons.palette_outlined,
            color: Colors.white,
            size: 30,
          ),
        ];

        return Scaffold(
          extendBody: true,
          appBar: _differentAppBar[_selected_index],
          body: IndexedStack(
            index: _selected_index,
            children: [
              Center(
                child: FridgeItems(
                  local_fridge: local_fridge,
                ),
              ),
              Center(
                  child: Text('Schermata 2')
              ),
              Center(
                  child: Text('Schermata 3')
              ),
              Center(
                  child: Settings(
                    local_fridge: local_fridge,
                    local_dictionary: local_dictionary,
                    local_shopping_cart: local_shopping_cart,)
              ),
            ],
          ),
          bottomNavigationBar: Container(
            height: 120,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        // Colore dell'ombra
                        spreadRadius: 2,
                        // Estensione dell'ombra
                        blurRadius: 15,
                        // Sfocatura dell'ombra
                        offset: Offset(0,
                            -3), // Offset dell'ombra (positivo verso il basso)
                      ),
                    ],
                  ),
                  child: NavigationBar(
                    labelBehavior: NavigationDestinationLabelBehavior
                        .onlyShowSelected,
                    selectedIndex: _selected_index,
                    destinations: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                        child: NavigationDestination( // dispensa
                          selectedIcon: Icon(
                            Icons.home_filled,
                            color: theme.colorScheme.primary,),
                          icon: Icon(
                            Icons.home_outlined,
                            color: theme.colorScheme.secondary,),
                          label: '•',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 50.0),
                        child: NavigationDestination( // spesa
                          selectedIcon: Icon(
                            Icons.shopping_cart,
                            color: theme.colorScheme.primary,),
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: theme.colorScheme.secondary,),
                          label: '•',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0),
                        child: NavigationDestination( // dizionario
                          selectedIcon: Icon(
                              Icons.menu_book,
                              color: theme.colorScheme.primary),
                          icon: Icon(
                              Icons.menu_book_outlined,
                              color: theme.colorScheme.secondary),
                          // la label è un punto
                          label: '•',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                        child: NavigationDestination( // profilo
                          selectedIcon: Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,),
                          icon: Icon(
                              Icons.person_outlined,
                              color: theme.colorScheme.secondary),
                          label: '•',
                        ),
                      ),
                    ],
                    onDestinationSelected: (index) {
                      setState(() {
                        _selected_index = index;
                      });
                    },
                  ),
                ),
                Positioned(
                  top: 24.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          // Colore dell'ombra
                          spreadRadius: 2,
                          // Estensione dell'ombra
                          blurRadius: 15,
                          // Sfocatura dell'ombra
                          offset: Offset(0,
                              -3), // Offset dell'ombra (positivo verso il basso)
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selected_index == 3) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ColorPickerScreen(userColor: userColor,);
                            },
                          );
                        } else if (_selected_index == 0) {
                          // spingi la schermata AddElement usando la route
                          Navigator.pushNamed(context, '/add_element');
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(
                            _differentColors[_selected_index]),
                        shape: MaterialStateProperty.all<CircleBorder>(
                            CircleBorder(
                              side: BorderSide(
                                color: _differentColors[_selected_index],
                              ),
                            )),
                        minimumSize: MaterialStateProperty.all<Size>(Size(
                            70, 70)),
                        elevation: MaterialStateProperty.all<double>(8.0),
                      ),
                      child: _differentIcons[_selected_index],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}