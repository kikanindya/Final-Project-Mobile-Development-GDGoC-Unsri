import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> with WidgetsBindingObserver {
  static const int workTime = 25 * 60;
  static const int breakTime = 5 * 60;

  int _seconds = workTime;
  bool _isRunning = false;
  bool _isPaused = false; // Status baru untuk melacak apakah timer sedang dipause
  bool _isBreakTime = false;
  Timer? _timer;
  
  String? _selectedTaskId;
  String? _selectedTaskTitle;

  static const Color duckYellow = Color(0xFFFFD83D);
  static const Color duckCream = Color(0xFFFFFBEA);
  static const Color duckBrown = Color(0xFF302A20);
  static const Color duckGrey = Color(0xFF817A6D);
  static const Color duckGreen = Color(0xFF7D9A72);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Penalti hanya diberikan jika timer benar-benar sedang berjalan (_isRunning = true dan bukan sedang dipause)
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached) &&
        _isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
        _isPaused = true;
      });
      _recordFailurePenalty();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _recordFailurePenalty() async {
    final prefs = await SharedPreferences.getInstance();
    int streak = prefs.getInt('current_streak') ?? 1;

    if (streak > 1) {
      await prefs.setInt('current_streak', streak - 1);
    }
  }

  void _toggleTimer() {
    if (_selectedTaskId == null && !_isBreakTime) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Pilih task terlebih dahulu 🐥',
            style: TextStyle(
              color: duckBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: duckYellow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isRunning = !_isRunning;
      // Jika _isRunning jadi false berarti di-pause, maka _isPaused jadi true. 
      // Tapi kalau timer baru pertama kali dipilih (belum pernah jalan), _isPaused jadi false.
      _isPaused = !_isRunning;
    });

    if (_isRunning) {
      _startLoop();
    } else {
      _timer?.cancel();
    }
  }

  void _startLoop() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_seconds > 0) {
          setState(() {
            _seconds--;
          });
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isPaused = false;

          // Jika waktu habis secara normal (25 menit penuh)
          if (!_isBreakTime && _selectedTaskTitle != null) {
            _saveLogToFirestore(_selectedTaskTitle!, workTime);
          }

          setState(() {
            _isBreakTime = !_isBreakTime;
            _seconds = _isBreakTime ? breakTime : workTime;
          });
        }
      },
    );
  }

  // Fungsi Finish Early dengan minimal durasi 1 menit (60 detik)
  void _finishEarly() {
    int elapsedSeconds = workTime - _seconds; // Total detik yang sudah berjalan

    if (!_isBreakTime && elapsedSeconds >= 60 && _selectedTaskTitle != null) {
      int minutesToSave = (elapsedSeconds / 60).floor();

      _saveLogToFirestore(_selectedTaskTitle!, minutesToSave * 60);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sesi fokus disimpan ($minutesToSave menit) 🐥',
            style: const TextStyle(color: duckBrown, fontWeight: FontWeight.w600),
          ),
          backgroundColor: duckYellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!_isBreakTime && elapsedSeconds < 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fokus minimal 1 menit ya sebelum bisa diselesaikan 🐥',
            style: TextStyle(color: duckBrown, fontWeight: FontWeight.w600),
          ),
          backgroundColor: duckYellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _seconds = _isBreakTime ? breakTime : workTime;
    });
  }

  Future<void> _saveLogToFirestore(String taskTitle, int durationSeconds) async {
    try {
      await FirebaseFirestore.instance.collection('focus_logs').add({
        'taskTitle': taskTitle,
        'durationMinutes': (durationSeconds / 60).round(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Gagal simpan log: $e');
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _seconds = _isBreakTime ? breakTime : workTime;
    });
  }

  String _formatTime() {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final int total = _isBreakTime ? breakTime : workTime;
    final double progress = 1 - (_seconds / total);
    final Color progressColor = _isBreakTime ? duckGreen : duckYellow;
    
    int elapsedSeconds = workTime - _seconds;
    bool canFinishEarly = elapsedSeconds >= 60;

    return PopScope(
      // Boleh keluar (pop) jika timer sedang tidak berjalan ATAU sedang dipause
      canPop: !_isRunning,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Mode fokus sedang aktif. Jeda atau selesaikan timer dulu untuk keluar 🐥',
                style: TextStyle(color: duckBrown, fontWeight: FontWeight.w600),
              ),
              backgroundColor: duckYellow,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: duckCream,
        appBar: AppBar(
          backgroundColor: duckCream,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Focus',
            style: TextStyle(
              color: duckBrown,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildTaskSelector(),
                const Spacer(),
                Text(
                  _isBreakTime ? '☕  REST TIME' : '🐥  FOCUS SESSION',
                  style: TextStyle(
                    color: _isBreakTime ? duckGreen : duckBrown,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 245,
                  height: 245,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 245,
                        height: 245,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 9,
                          color: const Color(0xFFEDE5CE),
                        ),
                      ),
                      SizedBox(
                        width: 245,
                        height: 245,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 9,
                          strokeCap: StrokeCap.round,
                          color: progressColor,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(),
                            style: const TextStyle(
                              color: duckBrown,
                              fontSize: 55,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isBreakTime 
                                ? 'Take a little break' 
                                : (_isPaused ? 'Paused' : 'Stay focused'),
                            style: const TextStyle(
                              color: duckGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_selectedTaskTitle != null)
                  Text(
                    _selectedTaskTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: duckBrown,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  const Text(
                    'Choose a task to begin',
                    style: TextStyle(
                      color: duckGrey,
                      fontSize: 13,
                    ),
                  ),
                const Spacer(),
                
                // Baris Kontrol Tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol Reset
                    GestureDetector(
                      onTap: _isRunning ? null : _resetTimer,
                      child: Opacity(
                        opacity: _isRunning ? 0.3 : 1,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5DCC3)),
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: duckBrown,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tombol Play / Pause (Sekarang tombol ini berfungsi untuk toggle Play & Pause)
                    GestureDetector(
                      onTap: _toggleTimer,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: duckYellow,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: duckBrown,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tombol Finish Early
                    if (!_isBreakTime)
                      GestureDetector(
                        onTap: canFinishEarly ? _finishEarly : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Selesaikan minimal 1 menit dulu ya 🐥',
                                style: TextStyle(color: duckBrown, fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: duckYellow,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Opacity(
                          opacity: canFinishEarly ? 1.0 : 0.3,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: duckGreen,
                              shape: BoxShape.circle,
                              boxShadow: canFinishEarly ? [
                                BoxShadow(
                                  color: duckGreen.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ] : [],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 52),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  _isBreakTime
                      ? 'Rest well, little duck 🐥'
                      : _isRunning
                          ? (canFinishEarly ? 'Tap checkmark to finish session.' : 'Fokus berjalan (min. 1 menit)...')
                          : (_isPaused ? 'Timer dijeda. Tekan play untuk lanjut 🐥' : 'Ready when you are 🐥'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: duckGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskSelector() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        final List<DropdownMenuItem<String>> items = [];
        final Map<String, String> taskTitlesMap = {};

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final String title = data['title']?.toString() ?? 'Tanpa Judul';
            
            items.add(
              DropdownMenuItem<String>(
                value: doc.id,
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: duckBrown,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
            taskTitlesMap[doc.id] = title;
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7DEC5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.any((item) => item.value == _selectedTaskId)
                  ? _selectedTaskId
                  : null,
              hint: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: duckBrown, size: 20),
                  SizedBox(width: 9),
                  Text('Choose a task', style: TextStyle(color: duckGrey, fontSize: 14)),
                ],
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: duckBrown),
              isExpanded: true,
              items: items,
              onChanged: _isRunning
                  ? null
                  : (value) {
                      setState(() {
                        _selectedTaskId = value;
                        _selectedTaskTitle = taskTitlesMap[value];
                      });
                    },
            ),
          ),
        );
      },
    );
  }
}