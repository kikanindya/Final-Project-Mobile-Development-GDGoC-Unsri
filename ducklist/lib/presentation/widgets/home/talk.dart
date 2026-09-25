import 'package:flutter/material.dart';

class DailyPepTalk extends StatelessWidget {
  const DailyPepTalk({super.key});

  static const List<String> _messages = [
    "You're doing great! Keep waddling forward! 🦆",
    "One step at a time, you're becoming a pro duck!",
    "Take a break, you've earned it!",
    "Big things start with small quacks!",
    "Keep your head up, little duckling!",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boxColor = theme.brightness == Brightness.light 
        ? const Color(0xFFF5F0E1) 
        : theme.colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Duck Wisdom 🦆"),
          content: Text(_messages[DateTime.now().day % _messages.length]),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Got it!"))],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFFD54F), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.psychology, color: Color(0xFF5D4037), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text("Daily Pep-talk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface))),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
          ],
        ),
      ),
    );
  }
}