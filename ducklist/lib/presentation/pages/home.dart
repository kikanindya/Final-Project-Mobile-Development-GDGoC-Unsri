import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/home/task_item.dart';
import '../widgets/app_header.dart';
import '../widgets/home/stats.dart';
import '../widgets/home/duck.dart';
import '../widgets/home/focus_mode.dart';
import '../widgets/home/talk.dart';
import '../widgets/home/ducky_chat_page.dart'; // Import halaman Ducky Chat

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showTaskDetail(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(data['title'] ?? 'No Title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Deskripsi: ${data['description'] ?? 'Tidak ada'}"),
            const SizedBox(height: 10),
            Text("Kategori: ${data['category'] ?? '-'}"),
            Text("Status: ${data['isCompleted'] == true ? 'Selesai' : 'Belum Selesai'}"),
            Text("Prioritas: ${data['priority'] ?? 'Medium'}"),
            Text("Deadline: ${data['date'] ?? 'Tidak ada'}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Utama + Tombol Kepala Bebek "Tanya Ducky"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: AppHeader()),
                const SizedBox(width: 10),
                
                // Tombol Kepala Bebek / Ducky Chat Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DuckyChatPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade400),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🦆', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 6),
                        Text(
                          'Tanya Ducky',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Jarak setelah header
            
            const DailyPepTalk(),
            const SizedBox(height: 20), // Jarak setelah pep talk
            
            const HomeStats(),
            const SizedBox(height: 20), // Jarak setelah stats
            
            const HomeDuck(),
            const SizedBox(height: 25), // Jarak sebelum judul
            
            const Text(
              "Today's Journey", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 15), // Jarak setelah judul
            
            const HomeFocusMode(),
            const SizedBox(height: 20), // Jarak sebelum list tugas
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var docs = snapshot.data!.docs.toList();
                
                docs.sort((a, b) {
                  bool aDone = (a.data() as Map<String, dynamic>)['isCompleted'] ?? false;
                  bool bDone = (b.data() as Map<String, dynamic>)['isCompleted'] ?? false;
                  if (aDone == bDone) return 0;
                  return aDone ? 1 : -1;
                });

                return Column(
                  children: docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    bool isDone = data['isCompleted'] ?? false;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12), // Jarak antar task item
                      child: Opacity(
                        opacity: isDone ? 0.5 : 1.0,
                        child: HomeTaskItem(
                          key: ValueKey(doc.id),
                          title: data['title'] ?? 'No Title',
                          detail: "${data['category']} | ${data['time'] ?? ''}",
                          icon: Icons.task_alt,
                          isCompleted: isDone,
                          priority: data['priority'] ?? 'Medium',
                          onToggle: () => doc.reference.update({'isCompleted': !isDone}),
                          onDelete: () => doc.reference.delete(),
                          onTap: () => _showTaskDetail(context, data),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 100), // Ruang bawah agar tidak tertutup nav
          ],
        ),
      ),
    );
  }
}