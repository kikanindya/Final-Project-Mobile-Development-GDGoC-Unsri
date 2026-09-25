import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../theme/app_theme.dart';
import '../../../auth/login_screen.dart';
import '../../../../main.dart'; 
import '../widgets/profile/about.dart';
import '../widgets/profile/account_settings.dart';
import '../widgets/profile/appearance_sheet.dart';
import '../widgets/profile/avatar.dart';
import '../widgets/profile/edit_profile.dart';
import '../widgets/profile/help.dart';
import '../widgets/profile/language.dart';
import '../widgets/profile/logout.dart';
import '../widgets/profile/notif.dart';
import '../widgets/profile/profilee.dart';

class MePage extends StatefulWidget {
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const MePage({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  String reminderTime = '08:00';
  bool taskReminders = true;
  bool goalReminders = true;
  bool dailySummary = false;
  bool achievementNotifications = true;

  String language = 'en';
  String appearance = 'Light';

  @override
  void initState() {
    super.initState();
    appearance = widget.themeMode == ThemeMode.dark ? 'Dark' : 'Light';
  }

  bool get isId => language == 'id';
  String tr(String en, String id) => isId ? id : en;

  Color get cardColor =>
      Theme.of(context).brightness == Brightness.dark
          ? AppTheme.nightCard
          : AppTheme.cream50;

  Color get textColor =>
      Theme.of(context).brightness == Brightness.dark
          ? AppTheme.nightText
          : AppTheme.brown;

  Color get mutedColor =>
      Theme.of(context).brightness == Brightness.dark
          ? AppTheme.nightMuted
          : AppTheme.muted;

  void toast(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🦆', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _checkAndCreateUserDoc(String uid, String email) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        await docRef.set({
          'name': email.split('@').first,
          'bio': 'Keep growing, one step at a time.',
          'avatar': '🐣',
          'email': email,
        }, SetOptions(merge: true));
      }
    } catch (_) {
      // Ditangani secara senyap tanpa print debug
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? 'user@example.com';
    final String uid = user?.uid ?? '';

    if (uid.isNotEmpty) {
      _checkAndCreateUserDoc(uid, email);
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: uid.isNotEmpty
              ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
              : null,
          builder: (context, snapshot) {
            String name = user?.displayName ?? email.split('@').first;
            String bio = 'Keep growing, one step at a time.';
            String avatar = '🐣';

            if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data != null) {
                name = data['name'] ?? name;
                bio = data['bio'] ?? bio;
                avatar = data['avatar'] ?? avatar;
              }
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  titleSpacing: 20,
                  title: Row(
                    children: [
                      Text(
                        tr('Me', 'Saya'),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text('🦆', style: TextStyle(fontSize: 21)),
                    ],
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => toast('Ducklist v1.0.0 • Connected'),
                      icon: const Icon(Icons.qr_code_2),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ProfileCard(
                        name: name,
                        bio: bio,
                        avatar: avatar,
                        onEdit: () => _editProfile(uid, name, bio, avatar),
                      ),
                      const SizedBox(height: 24),
                      ProfileSection(
                        title: tr('Preferences', 'Preferensi'),
                        children: [
                          ProfileSettingTile(
                            icon: Icons.notifications_outlined,
                            iconBg: Colors.amber.shade100,
                            iconColor: Colors.amber.shade800,
                            title: tr('Notifications', 'Notifikasi'),
                            subtitle: tr(
                              'Manage your reminders',
                              'Atur pengingatmu',
                            ),
                            trailing:
                                '$reminderTime (${taskReminders ? 'Active' : 'Off'})',
                            onTap: _notifications,
                          ),
                          ProfileSettingTile(
                            icon: Icons.palette_outlined,
                            iconBg: Colors.purple.shade100,
                            iconColor: Colors.purple.shade700,
                            title: tr('Appearance', 'Tampilan'),
                            subtitle: tr(
                              'Choose how Ducklist looks',
                              'Pilih tampilan Ducklist',
                            ),
                            trailing: appearance,
                            onTap: _appearance,
                          ),
                          ProfileSettingTile(
                            icon: Icons.translate,
                            iconBg: Colors.blue.shade100,
                            iconColor: Colors.blue.shade700,
                            title: tr('Language', 'Bahasa'),
                            subtitle: tr(
                              'Change app interface language',
                              'Ubah bahasa antarmuka aplikasi',
                            ),
                            trailing: language == 'en'
                                ? 'English'
                                : 'Bahasa Indonesia',
                            onTap: _language,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ProfileSection(
                        title: tr('Account', 'Akun'),
                        children: [
                          ProfileSettingTile(
                            icon: Icons.manage_accounts_outlined,
                            iconBg: Colors.teal.shade100,
                            iconColor: Colors.teal.shade700,
                            title: tr('Account Settings', 'Pengaturan Akun'),
                            subtitle: email,
                            onTap: _account,
                          ),
                          ProfileSettingTile(
                            icon: Icons.help_outline,
                            iconBg: Colors.orange.shade100,
                            iconColor: Colors.orange.shade700,
                            title: tr('Help & Support', 'Bantuan & Dukungan'),
                            subtitle: tr(
                              'FAQs and contact support',
                              'FAQ dan hubungi dukungan',
                            ),
                            onTap: _help,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _aboutAndLogout(),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _aboutAndLogout() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.nightBorder
                  : AppTheme.cream300,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              onTap: () => showAboutSheet(context),
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🦆', style: TextStyle(fontSize: 21)),
              ),
              title: Text(
                tr('About Ducklist', 'Tentang Ducklist'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Version 1.0.0 • Your Growth Friend',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 11,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 19),
            label: Text(tr('Log Out', 'Keluar')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(color: Colors.redAccent.shade100),
              backgroundColor: Colors.redAccent.withOpacity(.06),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _editProfile(String uid, String currentName, String currentBio, String currentAvatar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(
        name: currentName,
        bio: currentBio,
        avatar: currentAvatar,
        onNameChanged: (value) async {
          if (uid.isNotEmpty) {
            try {
              await FirebaseFirestore.instance.collection('users').doc(uid).set({
                'name': value,
              }, SetOptions(merge: true));
            } catch (_) {}
          }
        },
        onBioChanged: (value) async {
          if (uid.isNotEmpty) {
            try {
              await FirebaseFirestore.instance.collection('users').doc(uid).set({
                'bio': value,
              }, SetOptions(merge: true));
            } catch (_) {}
          }
        },
        onChangeAvatar: () => _avatar(uid, currentAvatar),
        onSaved: () => toast(
          tr('Profile updated.', 'Profil diperbarui.'),
        ),
      ),
    );
  }

  void _avatar(String uid, String currentAvatar) {
    showAvatarSheet(
      context,
      currentAvatar: currentAvatar,
      onSelected: (value) async {
        if (uid.isNotEmpty) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'avatar': value,
            }, SetOptions(merge: true));
            toast(tr('Avatar updated.', 'Avatar diperbarui.'));
          } catch (_) {}
        }
      },
    );
  }

  void _notifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsSheet(
        taskReminders: taskReminders,
        goalReminders: goalReminders,
        dailySummary: dailySummary,
        achievementNotifications: achievementNotifications,
        reminderTime: reminderTime,
        onSave: ({
          required taskReminders,
          required goalReminders,
          required dailySummary,
          required achievementNotifications,
          required reminderTime,
        }) {
          setState(() {
            this.taskReminders = taskReminders;
            this.goalReminders = goalReminders;
            this.dailySummary = dailySummary;
            this.achievementNotifications =
                achievementNotifications;
            this.reminderTime = reminderTime;
          });
        },
      ),
    );
  }

  void _appearance() {
    showAppearanceSheet(
      context,
      current: appearance,
      onSelected: (value) {
        setState(() => appearance = value);

        if (value == 'Light') {
          themeNotifier.value = ThemeMode.light;
          widget.onThemeChanged(ThemeMode.light);
        } else if (value == 'Dark') {
          themeNotifier.value = ThemeMode.dark;
          widget.onThemeChanged(ThemeMode.dark);
        }
      },
    );
  }

  void _language() {
    showLanguageSheet(
      context,
      current: language,
      onSelected: (value) {
        setState(() => language = value);
        widget.onLocaleChanged(Locale(value));
        toast(
          value == 'id'
              ? 'Bahasa diubah ke Bahasa Indonesia.'
              : 'Language changed to English.',
        );
      },
    );
  }

  void _account() {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? 'user@example.com';
    showAccountSettingsSheet(
      context,
      email: email,
      onChangePassword: () => showChangePasswordSheet(context),
    );
  }

  void _help() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const HelpSupportSheet(),
    );
  }

  void _logout() {
    showLogoutDialog(
      context,
      onConfirm: () async {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
    );
  }
}