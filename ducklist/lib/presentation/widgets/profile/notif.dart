import 'package:flutter/material.dart';
import 'profilee.dart';

class NotificationsSheet extends StatefulWidget {
  final bool taskReminders;
  final bool goalReminders;
  final bool dailySummary;
  final bool achievementNotifications;
  final String reminderTime;
  final void Function({
    required bool taskReminders,
    required bool goalReminders,
    required bool dailySummary,
    required bool achievementNotifications,
    required String reminderTime,
  }) onSave;

  const NotificationsSheet({
    super.key,
    required this.taskReminders,
    required this.goalReminders,
    required this.dailySummary,
    required this.achievementNotifications,
    required this.reminderTime,
    required this.onSave,
  });

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  late bool taskReminders;
  late bool goalReminders;
  late bool dailySummary;
  late bool achievementNotifications;
  late String reminderTime;

  @override
  void initState() {
    super.initState();
    taskReminders = widget.taskReminders;
    goalReminders = widget.goalReminders;
    dailySummary = widget.dailySummary;
    achievementNotifications = widget.achievementNotifications;
    reminderTime = widget.reminderTime;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSheet(
      title: 'Notifications',
      subtitle: 'Gentle nudges that keep you consistent',
      children: [
        _switchRow(
          'Task Reminders',
          'Prompt when scheduled tasks are due',
          taskReminders,
          (v) => setState(() => taskReminders = v),
        ),
        _switchRow(
          'Goal Reminders',
          'Gentle check-ins for milestone habits',
          goalReminders,
          (v) => setState(() => goalReminders = v),
        ),
        _switchRow(
          'Daily Summary',
          'Evening review of what got done',
          dailySummary,
          (v) => setState(() => dailySummary = v),
        ),
        _switchRow(
          'Achievement Notifications',
          'Duck celebration notes when reaching streaks',
          achievementNotifications,
          (v) => setState(() => achievementNotifications = v),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.alarm),
          title: const Text('Reminder Time'),
          subtitle: const Text('Tap to change schedule hourly'),
          trailing: Text(reminderTime),
          onTap: _pickTime, // Sekarang menggunakan TimePicker fleksibel tiap jam
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              widget.onSave(
                taskReminders: taskReminders,
                goalReminders: goalReminders,
                dailySummary: dailySummary,
                achievementNotifications: achievementNotifications,
                reminderTime: reminderTime,
              );
              Navigator.pop(context);
            },
            child: const Text('Save Preferences'),
          ),
        ),
      ],
    );
  }

  Widget _switchRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      value: value,
      onChanged: onChanged,
    );
  }

  // Diperbarui agar pemilih waktu bisa diatur bebas setiap jam (00:00 - 23:59)
  Future<void> _pickTime() async {
    // Parsing string "HH:mm" yang ada saat ini ke TimeOfDay
    final parts = reminderTime.split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 7 : 7;
    final initialMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        // Memaksa format 24 jam agar gampang dibaca format "HH:mm"
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedHour = picked.hour.toString().padLeft(2, '0');
      final formattedMinute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        reminderTime = '$formattedHour:$formattedMinute';
      });
    }
  }
}