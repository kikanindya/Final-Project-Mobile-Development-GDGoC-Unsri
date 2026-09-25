import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import '../home/task_item.dart';

class AgendaList extends StatelessWidget {
  final DateTime selectedDate;

  const AgendaList({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        var filteredDocs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          DateTime taskDate = DateTime.parse(data['date']);
          return isSameDay(taskDate, selectedDate);
        }).toList();

        filteredDocs.sort((a, b) {
          bool aDone = (a.data() as Map<String, dynamic>)['isCompleted'] ?? false;
          bool bDone = (b.data() as Map<String, dynamic>)['isCompleted'] ?? false;
          return aDone == bDone ? 0 : (aDone ? 1 : -1);
        });

        if (filteredDocs.isEmpty) {
          return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Tidak ada agenda.")));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var doc = filteredDocs[index];
            var data = doc.data() as Map<String, dynamic>;
            bool isDone = data['isCompleted'] ?? false;

            return Opacity(
              opacity: isDone ? 0.5 : 1.0, // Efek samar
              child: HomeTaskItem(
                title: data['title'],
                detail: data['category'],
                icon: Icons.calendar_today,
                isCompleted: isDone,
                priority: data['priority'] ?? 'Medium',
                onToggle: () => doc.reference.update({'isCompleted': !isDone}),
                onDelete: () => doc.reference.delete(),
                onTap: () {}, 
              ),
            );
          },
        );
      },
    );
  }
}