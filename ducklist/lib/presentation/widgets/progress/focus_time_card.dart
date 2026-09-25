import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; 

class FocusTimeCard extends StatelessWidget {
  const FocusTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? const Color(0xFFF5F5F5) : const Color(0xFF2C1600);
    final Color mutedColor = isDarkMode ? const Color(0xFFAFAFAF) : const Color(0xFF7F7662);
    final Color borderColor = isDarkMode ? const Color(0xFF333333) : const Color(0xFFEFE5CD);
    final Color chartBgColor = isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFFFF9EC);
    const Color primaryYellow = Color(0xFFFFD447);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('focus_logs').snapshots(),
      builder: (context, snapshot) {
        int totalSessions = 0;
        int totalMinutes = 0;
        double avgMinutes = 0;

        // List untuk menampung total jam fokus per hari (Senin = indeks 0, Minggu = indeks 6)
        List<double> weeklyData = [0, 0, 0, 0, 0, 0, 0];
        String peakDayText = 'Peak: -';

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;
          totalSessions = docs.length;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final int duration = data['durationMinutes'] ?? 0;
            totalMinutes += duration;

            // Ambil timestamp untuk memetakan ke grafik mingguan
            Timestamp? timestamp = data['timestamp'];
            if (timestamp != null) {
              DateTime date = timestamp.toDate();
              int weekday = date.weekday; // 1 = Senin, 7 = Minggu
              weeklyData[weekday - 1] += (duration / 60); // Konversi ke jam
            }
          }

          if (totalSessions > 0) {
            avgMinutes = totalMinutes / totalSessions;
          }

          // Menentukan hari terproduktif (Peak Day)
          List<String> daysName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          double maxVal = 0;
          int maxIndex = 0;
          for (int i = 0; i < weeklyData.length; i++) {
            if (weeklyData[i] > maxVal) {
              maxVal = weeklyData[i];
              maxIndex = i;
            }
          }
          if (maxVal > 0) {
            peakDayText = 'Peak: ${daysName[maxIndex]}';
          }
        }

        final int hours = totalMinutes ~/ 60;
        final int minutes = totalMinutes % 60;
        final String formattedTotalTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

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
                  Text(
                    'Focus Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '$totalSessions sessions',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formattedTotalTime,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              Text(
                'total concentrated flow',
                style: TextStyle(fontSize: 11, color: mutedColor),
              ),
              const SizedBox(height: 16),
              
              // KOTAK GRAFIK GARIS DINAMIS
              Container(
                height: 85,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                decoration: BoxDecoration(
                  color: chartBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WEEKLY CADENCE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: mutedColor,
                          ),
                        ),
                        Text(
                          peakDayText,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? const Color(0xFFFFD700) : const Color(0xFFB8860B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, weeklyData[0]),
                                FlSpot(1, weeklyData[1]),
                                FlSpot(2, weeklyData[2]),
                                FlSpot(3, weeklyData[3]),
                                FlSpot(4, weeklyData[4]),
                                FlSpot(5, weeklyData[5]),
                                FlSpot(6, weeklyData[6]),
                              ],
                              isCurved: true,
                              color: primaryYellow,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: primaryYellow.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: mutedColor),
                  const SizedBox(width: 6),
                  Text(
                    'Avg. ${avgMinutes.round()}m per focus session',
                    style: TextStyle(fontSize: 11, color: mutedColor),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}