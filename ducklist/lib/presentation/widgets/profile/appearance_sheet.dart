import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart'; 
import 'profilee.dart';

void showAppearanceSheet(
  BuildContext context, {
  required String current,
  required ValueChanged<String> onSelected,
}) {
  String selected = current;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) => ProfileSheet(
        title: 'Appearance',
        subtitle: 'Choose how Ducklist looks',
        children: [
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.yellow, 
            title: const Text('Light'),
            secondary: const Icon(Icons.light_mode_outlined),
            value: 'Light',
            groupValue: selected,
            onChanged: (value) {
              if (value != null) {
                setSheetState(() => selected = value);
              }
            },
          ),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.yellow,
            title: const Text('Dark'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: 'Dark',
            groupValue: selected,
            onChanged: (value) {
              if (value != null) {
                setSheetState(() => selected = value);
              }
            },
          ),
          const SizedBox(height: 20),
          // Tombol Simpan / Apply
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.yellow,
                foregroundColor: const Color(0xFF2C1600),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                // Jalankan fungsi perubahan tema & tutup sheet
                onSelected(selected);
                Navigator.pop(context);
              },
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}