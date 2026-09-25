import 'dart:io'; // Diperlukan untuk mendeteksi file gambar dari galeri
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Package untuk pilih gambar dari galeri

import 'profilee.dart';
import '../../../theme/app_theme.dart';

void showAvatarSheet(
  BuildContext context, {
  required String currentAvatar,
  required ValueChanged<String> onSelected,
}) async {
  final List<String> avatars = ['🐣', '🦆', '🐥', '👒', '🪿', '🌱', '☕', '✨'];

  // Fungsi untuk membuka galeri HP
  Future<void> _pickImageFromGallery(BuildContext ctx) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Kirim path file gambar lokal kembali ke onSelected
      onSelected(image.path);
      Navigator.pop(ctx); // Tutup bottom sheet
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (modalContext) => ProfileSheet(
      title: 'Pick Your Duck Companion Avatar',
      children: [
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            // 1. TOMBOL KHUSUS AMBIL DARI GALERI
            InkWell(
              onTap: () => _pickImageFromGallery(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.nightElevated
                      : AppTheme.cream200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.cream300,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_rounded, size: 24, color: Color(0xFF7F7662)),
                    SizedBox(height: 4),
                    Text(
                      'Gallery',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7F7662)),
                    ),
                  ],
                ),
              ),
            ),

            // 2. LIST EMOJI BAWAAN
            ...avatars.map((item) {
              final selected = item == currentAvatar;
              return InkWell(
                onTap: () {
                  onSelected(item);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.yellow.withOpacity(.22)
                        : Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.nightElevated
                            : AppTheme.cream200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? AppTheme.yellow : AppTheme.cream300,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(item, style: const TextStyle(fontSize: 30)),
                ),
              );
            }).toList(),
          ],
        ),
      ],
    ),
  );
}