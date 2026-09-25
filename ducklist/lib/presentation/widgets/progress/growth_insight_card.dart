import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GrowthInsightCard extends StatelessWidget {
  const GrowthInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi apakah aplikasi sedang dalam mode gelap atau terang
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Definisikan warna adaptif berdasarkan mode
    final Color mainCardColor = isDarkMode ? const Color(0xFF2C2618) : const Color(0xFFFFF4D9);
    final Color mainBorderColor = isDarkMode ? const Color(0xFF42381F) : const Color(0xFFF7E2B0);
    final Color innerContainerColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    
    final Color textColor = isDarkMode ? const Color(0xFFF5F5F5) : const Color(0xFF2C1600);
    final Color mutedColor = isDarkMode ? const Color(0xFFAFAFAF) : const Color(0xFF7F7662);
    final Color headerColor = isDarkMode ? const Color(0xFFFFD54F) : const Color(0xFF8B6B00);

    return StreamBuilder<QuerySnapshot>(
      // Mengambil insight terbaru dari Firestore
      stream: FirebaseFirestore.instance
          .collection('growth_insights')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        // Teks default (bisa dipakai kalau Firestore masih kosong)
        String titleText = 'You were most productive in the morning this week.';
        String bodyText = 'You completed 68% of your tasks before noon. Mornings seem to be your sweet spot for calm, deep work.';
        String actionText = 'Plan around morning focus';
        bool isSaved = true;

        // Kalau ada data dari Firestore / AI, timpa teks defaultnya
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          titleText = data['title'] ?? titleText;
          bodyText = data['body'] ?? bodyText;
          actionText = data['action'] ?? actionText;
          isSaved = data['isSaved'] ?? true;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: mainCardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: mainBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🐥', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GROWTH INSIGHT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: headerColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          titleText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                bodyText,
                style: TextStyle(
                  fontSize: 12,
                  color: mutedColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: innerContainerColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        actionText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 14,
                          color: mutedColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSaved ? 'Saved to reflections' : 'Save insight',
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14, color: textColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}