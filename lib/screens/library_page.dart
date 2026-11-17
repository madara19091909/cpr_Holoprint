import 'package:flutter/material.dart';

import '../models/export_entry.dart';
import '../services/history_store.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<List<ExportEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = HistoryStore.load();
  }

  void _refresh() {
    setState(() => _entriesFuture = HistoryStore.load());
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}  ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مسح سجل الحزم؟'),
        content: const Text('سيتم حذف سجل الحزم من داخل التطبيق فقط. الملفات المحفوظة في جهازك لن تُحذف.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('مسح السجل')),
        ],
      ),
    );
    if (confirmed == true) {
      await HistoryStore.clear();
      if (mounted) _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExportEntry>>(
      future: _entriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('تعذر تحميل المكتبة: ${snapshot.error}'));
        }
        final entries = snapshot.data ?? const <ExportEntry>[];
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(color: const Color(0xFF172A31), borderRadius: BorderRadius.circular(24)),
                    child: const Icon(Icons.folder_open_rounded, size: 34, color: Color(0xFF71DDC9)),
                  ),
                  const SizedBox(height: 18),
                  const Text('مكتبتك فارغة حالياً', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  const Text('بعد إنشاء حزمة Holoprint وحفظها، سيظهر سجلها هنا.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, height: 1.5)),
                ],
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
          children: [
            Row(
              children: [
                Text('الحزم التي أنشأتها', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                Text('${entries.length} حزمة', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                IconButton(onPressed: _confirmClear, tooltip: 'مسح السجل', icon: const Icon(Icons.delete_sweep_outlined)),
              ],
            ),
            const SizedBox(height: 12),
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111A22),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 48,
                        decoration: BoxDecoration(color: const Color(0xFF173B3C), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF70E0CB)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            const SizedBox(height: 5),
                            Text('${_formatDate(entry.createdAt)} · ${_formatBytes(entry.bytes)}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                            const SizedBox(height: 4),
                            const Text('محفوظ بالموقع الذي اخترته', style: TextStyle(color: Color(0xFF6FD6C4), fontSize: 10)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'حذف من السجل',
                        onPressed: () async {
                          await HistoryStore.remove(entry.id);
                          if (mounted) _refresh();
                        },
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.white54, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'ملاحظة: المكتبة تحفظ سجل الحزم فقط، أما ملف MCpack نفسه فيبقى في المجلد الذي اخترته عند التصدير.',
              style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.45),
            ),
          ],
        );
      },
    );
  }
}
