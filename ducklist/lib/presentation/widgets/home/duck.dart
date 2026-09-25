import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeDuck extends StatelessWidget {
  const HomeDuck({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.brightness == Brightness.light 
        ? const Color(0xFFE3F2FD) 
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.2);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        double progress = 0.0;
        int percentage = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          int total = snapshot.data!.docs.length;
          int done = snapshot.data!.docs
              .where((doc) => (doc.data() as Map<String, dynamic>)['isCompleted'] == true)
              .length;
          
          progress = done / total;
          percentage = (progress * 100).toInt();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor, 
            borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Waddle Meter", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
                  Row(children: [
                    Text("$percentage%", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
                    const SizedBox(width: 4),
                    const Icon(Icons.emoji_nature, size: 16, color: Colors.amber),
                  ]),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}