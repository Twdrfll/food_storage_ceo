import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../fridge_state.dart';

class FridgeCalendar extends StatefulWidget {
  final List<LocalFridgeElement> localFridgeElements;
  const FridgeCalendar({Key? key, required this.localFridgeElements}) : super(key: key);

  @override
  _FridgeCalendarState createState() => _FridgeCalendarState();
}

class _FridgeCalendarState extends State<FridgeCalendar> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late List<LocalFridgeElement> _elementsOnDayViewer = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
          child: Text (
              'Calendario',
              style: TextStyle(
                color: Colors.white,
                fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                fontWeight: Theme.of(context).textTheme.titleLarge!.fontWeight,
              )
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 12, bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: 4.0, right: 4.0),
              child: TableCalendar(
                // il calendario deve avere lo sfondo bianco. Il giorno selezionato dovra avere lo sfondo del colore primario
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                    fontWeight: Theme.of(context).textTheme.titleMedium!.fontWeight,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                    fontWeight: Theme.of(context).textTheme.titleMedium!.fontWeight,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                    fontWeight: Theme.of(context).textTheme.titleMedium!.fontWeight,
                  ),
                  outsideTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                    fontWeight: Theme.of(context).textTheme.titleMedium!.fontWeight,
                  ),
                  outsideDaysVisible: true,
                ),
                rangeSelectionMode: RangeSelectionMode.disabled,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mese',
                },
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                    fontWeight: Theme.of(context).textTheme.titleMedium!.fontWeight,
                  ),
                ),
                firstDay: DateTime.utc(2021, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                // for each element in the list, add a marker on the calendar
                eventLoader: (day) {
                  List<LocalFridgeElement> elements = widget.localFridgeElements;
                  List<LocalFridgeElement> _elementsOnDay = [];
                  for (var element in elements) {
                    if (isSameDay(DateTime.parse(element.expiration_date), day)) {
                      _elementsOnDay.add(element);
                    }
                  }
                  return _elementsOnDay;
                },
              ),
            ),
          ),
        ),
        ExpirationOfTheDay(localFridgeElements: widget.localFridgeElements, selectedDay: _selectedDay,)
      ],
    );
  }
}

class ExpirationOfTheDay extends StatelessWidget {
  final List<LocalFridgeElement> localFridgeElements;
  final DateTime selectedDay;
  ExpirationOfTheDay({Key? key, required this.localFridgeElements, required this.selectedDay}) : super(key: key);

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year && day1.month == day2.month && day1.day == day2.day;
  }

  var localFridgeElementsOnDay = [];

  void getElementsOnDay() {
    for (var element in localFridgeElements) {
      if (isSameDay(DateTime.parse(element.expiration_date), selectedDay)) {
        localFridgeElementsOnDay.add(element);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    getElementsOnDay();
    if (localFridgeElementsOnDay.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: 390,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Center(
          child: Text('Nessun prodotto in scadenza questo giorno'),
        ),
      );
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: ScrollController(),
          physics: PageScrollPhysics(),
          itemCount: localFridgeElementsOnDay.length,
          itemBuilder: (context, index) {
            if (isSameDay(DateTime.parse(localFridgeElementsOnDay[index].expiration_date), selectedDay)) {
              return Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0,),
                child:
                    Container(
                      height: 60,
                      width: 390,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                        color: hexToColor(localFridgeElementsOnDay[index].color),
                        width: 2,
                      ),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiary,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        //DateTime.parse(localFridgeElementsOnDay[index].expiration_date).day.toString(),
                                      (index + 1).toString(),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontSize: theme.textTheme.titleMedium!.fontSize,
                                          fontWeight: theme.textTheme.titleLarge!.fontWeight,
                                          height: 0.8
                                        ),
                                      ),
                                      Text(
                                        //DateFormat.MMMM().format(DateTime.parse(localFridgeElementsOnDay[index].expiration_date)),
                                        'di ${localFridgeElementsOnDay.length}',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontSize: 11,
                                          fontWeight: theme.textTheme.titleMedium!.fontWeight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localFridgeElementsOnDay[index].name,
                                      style: TextStyle(
                                        fontSize: theme.textTheme.titleMedium!.fontSize,
                                        fontWeight: theme.textTheme.titleMedium!.fontWeight,
                                      ),
                                    ),
                                    Text(
                                      'Scadenza: ' + localFridgeElementsOnDay[index].expiration_date,
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: theme.textTheme.labelMedium!.fontSize,
                                        fontWeight: theme.textTheme.titleMedium!.fontWeight,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
              );
            } else {
              return SizedBox(
                height: 0,
                width: 0,
              );
            }
          },
        ),
      );
    }
  }
}
