import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCompletionChart extends StatelessWidget {
  const TaskCompletionChart({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? const Color(0xFFF5F5F5) : const Color(0xFF2C1600);
    final Color mutedColor = isDarkMode ? const Color(0xFFAFAFAF) : const Color(0xFF7F7662);
    final Color borderColor = isDarkMode ? const Color(0xFF333333) : const Color(0xFFEFE5CD);
    
    final Color barInactiveColor = isDarkMode ? const Color(0xFF38301B) : const Color(0xFFFFEDB3);
    final Color barActiveColor = const Color(0xFFFFD447); // Tetap kuning cerah khas aksen
    final Color momentumBgColor = isDarkMode ? const Color(0xFF2C2514) : const Color(0xFFFFFBEA);
    final Color highlightDotColor = isDarkMode ? const Color(0xFFF5F5F5) : const Color(0xFF2C1600);
    final Color momentumTextColor = isDarkMode ? const Color(0xFFE6C657) : const Color(0xFFB8860B);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        List<int> weeklyCounts = [0, 0, 0, 0, 0, 0, 0];
        
        final List<String> daysLabel = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            
            if (data['isCompleted'] == true) {
              DateTime? completedDate;
              
              // Cek apakah ada field 'completedAt' di database
              if (data['completedAt'] != null && data['completedAt'] is Timestamp) {
                completedDate = (data['completedAt'] as Timestamp).toDate();
              } else {
                // Fallback jika belum ada field completedAt, gunakan waktu update dokumen/hari ini
                completedDate = DateTime.now(); 
              }

              // DateTime.weekday mengembalikan 1 (Senin) sampai 7 (Minggu)
              int dayIndex = completedDate.weekday - 1; 
              if (dayIndex >= 0 && dayIndex < 7) {
                weeklyCounts[dayIndex]++;
              }
            }
          }
        }

        // Cari nilai tertinggi untuk menentukan tinggi relatif bar (skala chart)
        int maxTasks = weeklyCounts.reduce((a, b) => a > b ? a : b);
        if (maxTasks == 0) maxTasks = 1; // Hindari pembagian dengan nol

        // Cari hari apa yang memiliki task terbanyak untuk teks momentum
        int peakDayIndex = 0;
        int peakCount = weeklyCounts[0];
        for (int i = 0; i < weeklyCounts.length; i++) {
          if (weeklyCounts[i] > peakCount) {
            peakCount = weeklyCounts[i];
            peakDayIndex = i;
          }
        }

        final List<String> fullDayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        String peakDayName = fullDayNames[peakDayIndex];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Task Completion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                      Text('Daily distribution of completed tasks', style: TextStyle(fontSize: 11, color: mutedColor)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1C3324) : const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  int count = weeklyCounts[index];
                  // Hitung tinggi proporsional (maksimal tinggi bar 80 pixel)
                  double heightFactor = (count / maxTasks).clamp(0.15, 1.0); 
                  if (count == 0) heightFactor = 0.1; // Biar bar kecil tetap terlihat sedikit

                  bool isHighlighted = (index == peakDayIndex && peakCount > 0);

                  return _buildBarColumn(
                    daysLabel[index], 
                    heightFactor, 
                    count.toString(), 
                    isHighlighted,
                    textColor,
                    mutedColor,
                    barActiveColor,
                    barInactiveColor,
                    highlightDotColor,
                  );
                }),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: momentumBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      peakCount > 0 
                          ? '$peakDayName was your highest momentum' 
                          : 'Belum ada task selesai minggu ini', 
                      style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500)
                    ),
                    Text('$peakCount tasks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: momentumTextColor)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarColumn(
    String day, 
    double heightFactor, 
    String count, 
    bool isHighlighted,
    Color textColor,
    Color mutedColor,
    Color barActiveColor,
    Color barInactiveColor,
    Color highlightDotColor,
  ) {
    return Column(
      children: [
        if (isHighlighted)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: highlightDotColor, shape: BoxShape.circle),
          ),
        if (!isHighlighted) const SizedBox(height: 6),
        const SizedBox(height: 4),
        Container(
          width: 22,
          height: 80 * heightFactor,
          decoration: BoxDecoration(
            color: isHighlighted ? barActiveColor : barInactiveColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(fontSize: 11, color: mutedColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}