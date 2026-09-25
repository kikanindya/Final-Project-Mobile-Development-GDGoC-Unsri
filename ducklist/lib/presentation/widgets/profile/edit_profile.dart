import 'dart:io'; // Diperlukan untuk mendeteksi file gambar dari galeri
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Library Firestore Backend
import 'package:firebase_auth/firebase_auth.dart';     // Library Auth untuk ambil User ID yang sedang login

import 'profilee.dart';
import '../../../theme/app_theme.dart';

class EditProfileSheet extends StatefulWidget {
  final String name;
  final String bio;
  final String avatar;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onBioChanged;
  final VoidCallback onChangeAvatar;
  final VoidCallback onSaved;

  const EditProfileSheet({
    super.key,
    required this.name,
    required this.bio,
    required this.avatar,
    required this.onNameChanged,
    required this.onBioChanged,
    required this.onChangeAvatar,
    required this.onSaved,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController nameController;
  late final TextEditingController bioController;
  bool _isLoading = false; // Indikator loading saat menyimpan ke backend

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    bioController = TextEditingController(text: widget.bio);
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan perubahan langsung ke backend Firestore murni tanpa nilai paksaan
  Future<void> _updateProfileToBackend() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil data apa adanya dari inputan user
      final updatedName = nameController.text.trim();
      final updatedBio = bioController.text.trim();

      // Update data ke Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': updatedName,
        'bio': updatedBio,
        'avatar': widget.avatar, 
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Gunakan merge agar field lain tidak terhapus

      // Beritahu widget induk (callback)
      widget.onNameChanged(updatedName);
      widget.onBioChanged(updatedBio);
      widget.onSaved();

      if (mounted) {
        Navigator.pop(context); // Tutup bottom sheet setelah sukses
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah avatar berupa file gambar lokal dari galeri atau teks emoji biasa
    bool isImageFile = widget.avatar.startsWith('/') || widget.avatar.contains('image_picker');

    return ProfileSheet(
      title: 'Edit Profile',
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 82,
                height: 82,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.yellow.withOpacity(.25),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.yellow, width: 2),
                  image: isImageFile
                      ? DecorationImage(
                          image: FileImage(File(widget.avatar)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !isImageFile
                    ? Text(widget.avatar, style: const TextStyle(fontSize: 40))
                    : null,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onChangeAvatar();
                },
                child: const Text('Change Avatar'),
              ),
            ],
          ),
        ),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: bioController,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Short Bio'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.yellow,
                  foregroundColor: AppTheme.brown,
                ),
                onPressed: _isLoading ? null : _updateProfileToBackend,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}