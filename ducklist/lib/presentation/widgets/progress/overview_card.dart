import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverviewCard extends StatefulWidget {
  const OverviewCard({Key? key}) : super(key: key);

  @override
  State<OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<OverviewCard> {
  int _streak = 0;
  int _totalFocusMinutes = 0;
  bool _isLoadingFocus = true;

  @override
  void initState() {
    super.initState();
    _loadStreakAndFocusData();
  }

  // Mengambil streak dan total focus time dari Firestore & SharedPreferences
  Future<void> _loadStreakAndFocusData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int currentStreak = prefs.getInt('current_streak') ?? 1;

      // Ambil data Focus Logs dari Firestore untuk menghitung "Focus Time"
      final logSnapshot = await FirebaseFirestore.instance.collection('focus_logs').get();
      int totalMinutes = 0;

      for (var doc in logSnapshot.docs) {
        final data = doc.data();
        final minutes = data['durationMinutes'];
        if (minutes != null) {
          totalMinutes += (minutes as num).toInt();
        }
      }

      if (mounted) {
        setState(() {
          _streak = currentStreak;
          _totalFocusMinutes = totalMinutes;
          _isLoadingFocus = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil data overview: $e");
      if (mounted) setState(() => _isLoadingFocus = false);
    }
  }

  // Helper untuk mengubah total menit menjadi format "Xh Ym"
  String _formatFocusTime(int minutes) {
    if (minutes == 0) return '0m';
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${remainingMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi status Dark Mode dari perangkat
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisikan palet warna adaptif (Light vs Dark)
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? const Color(0xFFF5F5F5) : const Color(0xFF2C1600);
    final Color mutedColor = isDarkMode ? const Color(0xFFAFAFAF) : const Color(0xFF7F7662);
    final Color borderColor = isDarkMode ? const Color(0xFF333333) : const Color(0xFFEFE5CD);
    final Color dividerColor = isDarkMode ? const Color(0xFF333333) : const Color(0xFFF5EEDB);
    final Color progressBgColor = isDarkMode ? const Color(0xFF38301B) : const Color(0xFFFF3CD); // atau warna latar indikator melingkar
    const Color primaryYellow = Color(0xFFFFD447);

    // Menggunakan StreamBuilder agar data task selalu sinkron secara real-time
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        int totalTasks = 0;
        int completedTasks = 0;

        if (snapshot.hasData) {
          totalTasks = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['isCompleted'] == true) {
              completedTasks++;
            }
          }
        }

        double completionPercentage = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;
        int percentageInt = (completionPercentage * 100).round();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: _isLoadingFocus && !snapshot.hasData
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: primaryYellow),
                  ),
                )
              : Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(
                            value: completionPercentage,
                            strokeWidth: 12,
                            backgroundColor: isDarkMode ? const Color(0xFF2C2514) : const Color(0xFFFFF3CD),
                            valueColor: const AlwaysStoppedAnimation<Color>(primaryYellow),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percentageInt%',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor),
                            ),
                            Text(
                              'Task Completion',
                              style: TextStyle(fontSize: 11, color: mutedColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      totalTasks == 0
                          ? 'Belum ada tugas dibuat. Yuk buat target tugasmu! 🐥'
                          : 'Kamu telah menyelesaikan $completedTasks dari $totalTasks target tugas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: mutedColor, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: dividerColor),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricItem('$completedTasks', 'Tasks Done', textColor, mutedColor),
                        _buildMetricItem(_formatFocusTime(_totalFocusMinutes), 'Focus Time', textColor, mutedColor),
                        _buildMetricItem('$_streak d 🔥', 'Streak', textColor, mutedColor),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMetricItem(String value, String label, Color textColor, Color mutedColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: mutedColor, fontWeight: FontWeight.w500)),
      ],
    );
  }
}