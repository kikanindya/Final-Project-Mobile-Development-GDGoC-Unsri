import 'package:flutter/material.dart';
import '../widgets/progress/report_header.dart';
import '../widgets/progress/overview_card.dart';
import '../widgets/progress/task_completion_chart.dart';
import '../widgets/progress/focus_time_card.dart';
import '../widgets/progress/growth_insight_card.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mengecek apakah sedang dalam mode gelap (Dark Mode)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Menyesuaikan warna background secara dinamis
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFF9EC);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ReportHeader(),           // 1. Header & Filter Minggu
              SizedBox(height: 16),
              OverviewCard(),           // 2. Lingkaran 78% & 3 Metrik Utama
              SizedBox(height: 20),
              TaskCompletionChart(),    // 3. Grafik Batang Harian
              SizedBox(height: 20),
              FocusTimeCard(),          // 4. Kartu Waktu Fokus
              SizedBox(height: 20),
              GrowthInsightCard(),      // 6. Kartu Wawasan Bebek (Growth Insight)
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}