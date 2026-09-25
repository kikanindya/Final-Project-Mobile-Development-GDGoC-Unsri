import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Package untuk fitur share asli bawaan HP
import 'package:intl/intl.dart'; // Digunakan untuk memformat tanggal otomatis

class ReportHeader extends StatefulWidget {
  final Function(String selectedPeriod)? onPeriodChanged; // Dibuat opsional (nullable) agar tidak error

  const ReportHeader({super.key, this.onPeriodChanged});

  @override
  State<ReportHeader> createState() => _ReportHeaderState();
}

class _ReportHeaderState extends State<ReportHeader> {
  String _selectedPeriod = 'This Week';
  late String _dateRangeText;

  @override
  void initState() {
    super.initState();
    _dateRangeText = _getDynamicDateRange('This Week');
  }

  // Fungsi untuk menghasilkan teks rentang tanggal secara dinamis
  String _getDynamicDateRange(String period) {
    final now = DateTime.now();
    
    if (period == 'This Week') {
      // Mencari hari Senin dan Minggu di minggu ini
      int currentWeekday = now.weekday;
      DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      String formattedStart = DateFormat('MMM d').format(startOfWeek);
      String formattedEnd = DateFormat('MMM d').format(endOfWeek);
      return '$formattedStart – $formattedEnd · Your weekly reflection';
    } else if (period == 'This Month') {
      String formattedMonth = DateFormat('MMMM yyyy').format(now);
      return '$formattedMonth · Monthly progress report';
    } else {
      return 'Overall cumulative growth insights';
    }
  }

  // Fungsi untuk memunculkan menu pilihan periode (This Week, This Month, dll)
  void _showPeriodMenu(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Warna adaptif untuk bottom sheet
    final Color sheetBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color sheetTextColor = isDarkMode ? const Color(0xFFF5F5F5) : const Color(0xFF2C1600);
    final Color sheetMutedColor = isDarkMode ? const Color(0xFFAFAFAF) : const Color(0xFF7F7662);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: sheetBgColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Timeframe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: sheetTextColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildPeriodOption('This Week', _getDynamicDateRange('This Week'), sheetTextColor, sheetMutedColor),
              _buildPeriodOption('This Month', _getDynamicDateRange('This Month'), sheetTextColor, sheetMutedColor),
              _buildPeriodOption('All Time', _getDynamicDateRange('All Time'), sheetTextColor, sheetMutedColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodOption(String period, String subtitle, Color textColor, Color mutedColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(period, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: mutedColor)),
      trailing: _selectedPeriod == period 
          ? const Icon(Icons.check_circle, color: Color(0xFFFFD447)) 
          : null,
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _dateRangeText = subtitle;
        });
        
        // Kirim callback jika diimplementasikan di parent widget
        if (widget.onPeriodChanged != null) {
          widget.onPeriodChanged!(period);
        }
        
        Navigator.pop(context);
      },
    );
  }

  // Fungsi untuk memunculkan menu Share bawaan perangkat
  void _shareProgress() {
    final String shareContent = 
        '🚀 My Ducklist Progress Report ($_selectedPeriod)\n'
        '$_dateRangeText\n\n'
        'Checking in on my goals and focus cadence today! Keep growing ✨';
    
    Share.share(shareContent);
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi apakah aplikasi sedang dalam mode gelap atau terang
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Definisikan warna adaptif berdasarkan mode
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? const Color(0xFFF5F5F5) : const Color(0xFF2C1600);
    final Color mutedColor = isDarkMode ? const Color(0xFFAFAFAF) : const Color(0xFF7F7662);
    final Color borderColor = isDarkMode ? const Color(0xFF333333) : const Color(0xFFEFE5CD);
    final Color syncedBgColor = isDarkMode ? const Color(0xFF1C3324) : const Color(0xFFE6F4EA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "See how you're growing.",
                  style: TextStyle(
                    fontSize: 14,
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: IconButton(
                icon: Icon(Icons.share_outlined, color: textColor, size: 20),
                tooltip: 'Share Progress',
                onPressed: _shareProgress, // Tombol share aktif memanggil share sheet
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // TOMBOL DROPDOWN PERIODE
            GestureDetector(
              onTap: () => _showPeriodMenu(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedPeriod,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: textColor),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: syncedBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.fiber_manual_record, size: 10, color: Colors.green),
                  SizedBox(width: 6),
                  Text('SYNCED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _dateRangeText,
          style: TextStyle(fontSize: 12, color: mutedColor),
        ),
      ],
    );
  }
}