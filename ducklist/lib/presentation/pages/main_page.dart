import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'home.dart';
import 'calendar.dart';
import 'progress.dart'; // Pastikan file progress.dart mendefinisikan ProgressPage
import 'profile.dart';   // Pastikan file profile.dart mendefinisikan MePage
import '../widgets/app_bottom_nav.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;
  
  // State sederhana untuk tema dan bahasa jika belum memakai State Management global
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    _initPages();
  }

  void _initPages() {
    pages = [
      const HomePage(),
      const CalendarPage(),
      const ProgressPage(), // Diperbaiki dari ShopPage ke ProgressPage
      MePage(
        locale: _locale,
        onLocaleChanged: (newLocale) {
          setState(() {
            _locale = newLocale;
          });
        },
        themeMode: _themeMode,
        onThemeChanged: (newTheme) {
          setState(() {
            _themeMode = newTheme;
          });
        },
      ),
    ];
  }

  Future<void> _addTaskToFirestore(String title, String desc, String category, String priority, DateTime date, TimeOfDay time) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': title,
        'description': desc,
        'category': category,
        'priority': priority,
        'date': date.toIso8601String(),
        'time': "${time.hour}:${time.minute}",
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _showAddTaskModal(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final Color lightBg = const Color(0xFFFFFDF7);
    final Color darkBg = const Color(0xFF121212);
    final Color lightInput = Colors.white;
    final Color darkInput = const Color(0xFF1E1E1E);
    final Color accentColor = const Color(0xFFFFD54F);

    String selectedPriority = "Medium";
    String selectedCategory = "Wellness";
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isLight ? lightBg : darkBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isLight ? Colors.grey[300] : Colors.grey[700], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 15),
                Center(child: Text("New Task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isLight ? Colors.black : Colors.white))),
                
                _buildFieldLabel("TASK TITLE", isLight),
                _buildTextField(titleController, "What's your next waddle?", isLight, lightInput, darkInput),
                
                _buildFieldLabel("DESCRIPTION", isLight),
                _buildTextField(descController, "Add some tiny details here...", isLight, lightInput, darkInput, maxLines: 3),
                
                _buildFieldLabel("CATEGORY", isLight),
                _buildDropdown(selectedCategory, (val) => setModalState(() => selectedCategory = val!), isLight, lightInput, darkInput),
                
                Row(
                  children: [
                    Expanded(child: _buildDatePicker(context, selectedDate, (val) => setModalState(() => selectedDate = val), isLight, lightInput, darkInput)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTimePicker(context, selectedTime, (val) => setModalState(() => selectedTime = val), isLight, lightInput, darkInput)),
                  ],
                ),
                
                _buildFieldLabel("PRIORITY", isLight),
                Row(
                  children: ["Low", "Medium", "High"].map((p) => Expanded(
                    child: InkWell(
                      onTap: () => setModalState(() => selectedPriority = p),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: selectedPriority == p ? accentColor : (isLight ? Colors.white : darkInput), borderRadius: BorderRadius.circular(15)),
                        child: Center(child: Text(p, style: TextStyle(fontWeight: selectedPriority == p ? FontWeight.bold : FontWeight.normal, color: isLight ? Colors.black : Colors.white))),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () async {
                      await _addTaskToFirestore(titleController.text, descController.text, selectedCategory, selectedPriority, selectedDate, selectedTime);
                      
                      // Memaksa penutupan modal
                      if (mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    },
                    child: const Text("Create Task →", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, bool isLight) => Padding(padding: const EdgeInsets.only(top: 15, bottom: 5), child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isLight ? Colors.grey : Colors.grey[400])));

  Widget _buildTextField(TextEditingController? controller, String hint, bool isLight, Color light, Color dark, {int maxLines = 1, IconData? suffixIcon, bool enabled = true}) => TextField(
    controller: controller, enabled: enabled, maxLines: maxLines, style: TextStyle(color: isLight ? Colors.black : Colors.white),
    decoration: InputDecoration(hintText: hint, filled: true, fillColor: isLight ? light : dark, suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18, color: isLight ? Colors.black : Colors.white) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
  );

  Widget _buildDropdown(String current, ValueChanged<String?> onChanged, bool isLight, Color light, Color dark) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: isLight ? light : dark, borderRadius: BorderRadius.circular(15)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(isExpanded: true, value: current, dropdownColor: isLight ? light : dark, style: TextStyle(color: isLight ? Colors.black : Colors.white), items: ["Wellness", "Work", "Education", "Personal", "Health", "Finance"].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged)),
  );

  Widget _buildDatePicker(BuildContext context, DateTime d, Function(DateTime) onPick, bool isLight, Color l, Color dCol) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildFieldLabel("DUE DATE", isLight),
    InkWell(onTap: () async { DateTime? p = await showDatePicker(context: context, initialDate: d, firstDate: DateTime.now(), lastDate: DateTime(2030)); if (p != null) onPick(p); }, child: _buildTextField(null, d.toString().split(' ')[0], isLight, l, dCol, suffixIcon: Icons.calendar_today, enabled: false)),
  ]);

  Widget _buildTimePicker(BuildContext context, TimeOfDay t, Function(TimeOfDay) onPick, bool isLight, Color l, Color dCol) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildFieldLabel("DUE TIME", isLight),
    InkWell(onTap: () async { TimeOfDay? p = await showTimePicker(context: context, initialTime: t); if (p != null) onPick(p); }, child: _buildTextField(null, t.format(context), isLight, l, dCol, suffixIcon: Icons.access_time, enabled: false)),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: const Color(0xFFFFD54F),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        onAddPressed: () => _showAddTaskModal(context),
      ),
    );
  }
}