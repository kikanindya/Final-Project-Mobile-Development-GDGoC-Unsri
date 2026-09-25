import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/ducky_ai_service.dart'; // Sesuaikan jika letak folder services Anda berbeda

class DuckyChatPage extends StatefulWidget {
  const DuckyChatPage({super.key});

  @override
  State<DuckyChatPage> createState() => _DuckyChatPageState();
}

class _DuckyChatPageState extends State<DuckyChatPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String _aiResponse = '';

  void _submitToDucky() async {
    if (_controller.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _aiResponse = '';
    });

    final result = await DuckyAIService.analyzeTaskHub(_controller.text);

    setState(() {
      _isLoading = false;
      _aiResponse = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Ducky AI Hub'),
            SizedBox(width: 6),
            Text('🦆', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner sapaan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade100.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Text('🐣', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Halo! Ketik target atau tugas besarmu di bawah. Ducky akan bantu buatkan rincian, jadwal, dan tipsnya sekaligus!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Input Text Field
            TextField(
              controller: _controller,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Contoh: Mau bikin laporan magang minggu depan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Eksekusi
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitToDucky,
              icon: _isLoading 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'Ducky sedang berpikir...' : 'Minta Bantuan Ducky AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),

            // Area Hasil Respon AI
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.nightCard : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.nightBorder : Colors.grey.shade300,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _aiResponse.isEmpty 
                        ? '✨ Hasil analisis dari Ducky akan muncul di sini...'
                        : _aiResponse,
                    style: TextStyle(
                      fontSize: 14, 
                      height: 1.4,
                      color: _aiResponse.isEmpty ? Colors.grey : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}