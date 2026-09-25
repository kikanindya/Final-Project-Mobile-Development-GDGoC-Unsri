import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  const CalendarWidget({super.key, required this.onDateSelected});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> _days = List.generate(31, (i) => DateTime.now().subtract(const Duration(days: 15)).add(Duration(days: i)));
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int index = _days.indexWhere((d) => isSameDay(d, DateTime.now()));
      if (index != -1 && _scrollController.hasClients) _scrollController.jumpTo(index * 65.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // 1. Table Calendar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDateSelected(selectedDay);
            },
          ),
        ),
        const SizedBox(height: 20),
        // 2. Horizontal Date Cards (Yang hilang tadi)
        SizedBox(
          height: 90,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            itemBuilder: (context, index) {
              DateTime date = _days[index];
              bool isSelected = isSameDay(_selectedDate, date);
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                  widget.onDateSelected(date);
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7], 
                        style: TextStyle(fontSize: 10, color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant)),
                      Text("${date.day}", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}