import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeStats extends StatefulWidget {
  const HomeStats({super.key});

  @override
  State<HomeStats> createState() => _HomeStatsState();
}

class _HomeStatsState extends State<HomeStats> {
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadAndCalculateStreak();
  }

  Future<void> _loadAndCalculateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil tanggal terakhir user aktif menyelesaikan tugas
    String? lastActiveDateStr = prefs.getString('last_active_date');
    int currentStreak = prefs.getInt('current_streak') ?? 1;

    DateTime today = DateTime.now();
    DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    if (lastActiveDateStr != null) {
      DateTime lastActive = DateTime.parse(lastActiveDateStr);
      DateTime lastActiveDateOnly = DateTime(lastActive.year, lastActive.month, lastActive.day);

      // Selisih hari antara hari ini dan terakhir aktif
      int difference = todayDateOnly.difference(lastActiveDateOnly).inDays;

      if (difference == 1) {
        // Pengguna aktif kemarin dan hari ini -> Streak aman
      } else if (difference > 1) {
        // Terlewat 1 hari lebih -> Streak reset ke 1
        currentStreak = 1;
      }
    }

    setState(() {
      _streak = currentStreak;
    });

    await prefs.setInt('current_streak', _streak);
  }

  // Dipanggil saat ada tugas yang diselesaikan
  Future<void> _recordActivity() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastActiveDateStr = prefs.getString('last_active_date');
    
    DateTime today = DateTime.now();
    String todayStr = today.toIso8601String();

    if (lastActiveDateStr != null) {
      DateTime lastActive = DateTime.parse(lastActiveDateStr);
      int difference = DateTime(today.year, today.month, today.day)
          .difference(DateTime(lastActive.year, lastActive.month, lastActive.day))
          .inDays;

      if (difference == 1) {
        int newStreak = (prefs.getInt('current_streak') ?? 0) + 1;
        await prefs.setInt('current_streak', newStreak);
        setState(() => _streak = newStreak);
      }
    } else {
      await prefs.setInt('current_streak', 1);
      setState(() => _streak = 1);
    }

    await prefs.setString('last_active_date', todayStr);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        int done = 0;
        int remaining = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            if (data['isCompleted'] == true) {
              done++;
              _recordActivity();
            } else {
              remaining++;
            }
          }
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Done", 
                value: "$done", 
                icon: Icons.check_circle_outline, 
                color: const Color(0xFFD4EDDA),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: "Remaining", 
                value: "$remaining", 
                icon: Icons.schedule, 
                color: const Color(0xFFFFCC80),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: "Streak", 
                value: "$_streak d", 
                icon: Icons.bolt_rounded, // Menggunakan ikon petir yang lebih bersih
                color: const Color(0xFFFFE082),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title, 
    required this.value, 
    required this.icon, 
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: isDark 
            ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) 
            : color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            icon, 
            size: 20, 
            color: isDark ? Theme.of(context).colorScheme.primary : Colors.black87,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}