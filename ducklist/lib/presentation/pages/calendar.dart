import 'package:flutter/material.dart';
import '../widgets/calendar/calendar_widget.dart';
import '../widgets/calendar/agenda_list.dart';

class CalendarPage extends StatefulWidget { // Ubah jadi StatefulWidget
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now(); // State untuk menyimpan tanggal

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Calendar", 
          style: TextStyle(
            color: theme.colorScheme.onSurface, 
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Kirim callback ke widget
            CalendarWidget(
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date; // Update state saat tanggal dipilih
                });
              },
            ), 
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft, 
              child: Text(
                "Agenda", 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                )
              ),
            ),
            const SizedBox(height: 10),
            // Kirim tanggal terpilih ke AgendaList
            AgendaList(selectedDate: _selectedDate), 
          ],
        ),
      ),
    );
  }
}