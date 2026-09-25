import 'package:flutter/material.dart';

import 'profilee.dart';

void showAccountSettingsSheet(
  BuildContext context, {
  required String email,
  required VoidCallback onChangePassword,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => ProfileSheet(
      title: 'Account Settings',
      children: [
        TextField(
          controller: TextEditingController(text: email),
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock_outline),
          title: const Text('Change Password'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pop(context);
            onChangePassword();
          },
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Cloud Sync'),
          subtitle: const Text('Keep your Ducklist data synced'),
          value: true,
          onChanged: (_) {},
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ),
      ],
    ),
  );
}

void showChangePasswordSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => ProfileSheet(
      title: 'Change Password',
      children: [
        TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Current Password'),
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password'),
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Confirm Password'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Update Password'),
          ),
        ),
      ],
    ),
  );
}
