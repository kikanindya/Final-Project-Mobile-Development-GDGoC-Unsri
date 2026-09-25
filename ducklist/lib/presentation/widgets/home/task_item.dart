import 'package:flutter/material.dart';

class HomeTaskItem extends StatelessWidget {
  final String title;
  final String detail;
  final IconData icon;
  final bool isCompleted;
  final String priority;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const HomeTaskItem({
    super.key,
    required this.title,
    required this.detail,
    required this.icon,
    this.isCompleted = false,
    required this.priority,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _getPriorityColor(priority), width: 2),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(isCompleted ? Icons.check_box : Icons.check_box_outline_blank, 
                         color: _getPriorityColor(priority)),
              onPressed: onToggle,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: theme.colorScheme.onSurface,
                      decoration: isCompleted ? TextDecoration.lineThrough : null, // Efek coret
                    )
                  ),
                  Text(detail, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Tugas?"),
        content: const Text("Yakin ingin menghapus tugas ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(onPressed: () { onDelete(); Navigator.pop(ctx); }, child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}