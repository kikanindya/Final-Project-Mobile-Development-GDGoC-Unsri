import 'package:flutter/material.dart';

import 'profilee.dart';

void showLanguageSheet(
  BuildContext context, {
  required String current,
  required ValueChanged<String> onSelected,
}) {
  String selected = current;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) => ProfileSheet(
        title: 'Language',
        subtitle: 'Change app interface language',
        children: [
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: const Text('English'),
            value: 'en',
            groupValue: selected,
            onChanged: (v) {
              if (v != null) setSheetState(() => selected = v);
            },
          ),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: const Text('Bahasa Indonesia'),
            value: 'id',
            groupValue: selected,
            onChanged: (v) {
              if (v != null) setSheetState(() => selected = v);
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                onSelected(selected);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    ),
  );
}
