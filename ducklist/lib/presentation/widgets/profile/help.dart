import 'package:flutter/material.dart';

import 'profilee.dart';

class HelpSupportSheet extends StatefulWidget {
  const HelpSupportSheet({super.key});

  @override
  State<HelpSupportSheet> createState() => _HelpSupportSheetState();
}

class _HelpSupportSheetState extends State<HelpSupportSheet> {
  final searchController = TextEditingController();
  final expanded = <int>{};

  final faqs = const [
    (
      'How do I create a task?',
      'Tap the centered plus button in the bottom navigation and choose a task.'
    ),
    (
      'How does Focus work?',
      'Focus uses a Pomodoro-style session to help you work in short, consistent blocks.'
    ),
    (
      'How are goals validated?',
      'Ducklist checks whether your target is specific, realistic, and measurable.'
    ),
    (
      'How do streaks work?',
      'Complete your planned daily actions to keep your growth streak going.'
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSheet(
      title: 'Help & Support',
      subtitle: 'Find answers and learn how Ducklist works',
      children: [
        TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Search FAQ',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(faqs.length, (index) {
          final item = faqs[index];
          final visible = searchController.text.trim().isEmpty ||
              item.$1.toLowerCase().contains(
                    searchController.text.trim().toLowerCase(),
                  );

          if (!visible) return const SizedBox.shrink();

          return ExpansionTile(
            tilePadding: EdgeInsets.zero,
            initiallyExpanded: expanded.contains(index),
            onExpansionChanged: (value) {
              setState(() {
                if (value) {
                  expanded.add(index);
                } else {
                  expanded.remove(index);
                }
              });
            },
            title: Text(
              item.$1,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.chat_bubble_outline),
          title: const Text('Contact Support'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Support contact opened.')),
            );
          },
        ),
      ],
    );
  }
}
