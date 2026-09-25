import 'package:flutter/material.dart';
import 'profilee.dart';

void showAboutSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => ProfileSheet(
      title: 'About Ducklist',
      subtitle: 'Your Growth Friend',
      children: [
        const Center(
          child: Text('🦆', style: TextStyle(fontSize: 58)),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Ducklist helps you grow through small, consistent actions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 18),
        
        // 1. Version ListTile
        const Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
        ),
        
        // 2. Made for ListTile
        const Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Made for'),
            trailing: Text('Daily growth'),
          ),
        ),
        
        // 3. Terms & Conditions ListTile
        Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
        
        // 4. Privacy Policy ListTile
        Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ],
    ),
  );
}